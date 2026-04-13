package com.epura.cleaner

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val REQUEST_PICK_FOLDER = 1001
        private const val REQUEST_PICK_DOCUMENTS = 1002
    }

    private val channelName = "com.epura.cleaner/document_access"
    private var pendingFolderResult: MethodChannel.Result? = null
    private var pendingDocumentsResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFolder" -> {
                        if (pendingFolderResult != null) {
                            result.error("in_progress", "Folder picker already active", null)
                            return@setMethodCallHandler
                        }

                        pendingFolderResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                            addFlags(
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                            )
                            putExtra(DocumentsContract.EXTRA_PROMPT, "Select a folder to scan")
                        }
                        startActivityForResult(intent, REQUEST_PICK_FOLDER)
                    }

                    "pickDocuments" -> {
                        if (pendingDocumentsResult != null) {
                            result.error("in_progress", "Document picker already active", null)
                            return@setMethodCallHandler
                        }

                        pendingDocumentsResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
                            putExtra(Intent.EXTRA_LOCAL_ONLY, true)
                            putExtra(DocumentsContract.EXTRA_PROMPT, "Select files to review")
                            addFlags(
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                            )
                        }
                        startActivityForResult(intent, REQUEST_PICK_DOCUMENTS)
                    }

                    "listFolderFiles" -> {
                        val treeUriValue = call.argument<String>("treeUri")
                        if (treeUriValue == null) {
                            result.error("missing_arg", "treeUri is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            result.success(listFolderFiles(Uri.parse(treeUriValue)))
                        } catch (error: Exception) {
                            result.error("list_failed", error.message, null)
                        }
                    }

                    "deleteDocument" -> {
                        val uriValue = call.argument<String>("uri")
                        if (uriValue == null) {
                            result.error("missing_arg", "uri is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            result.success(
                                DocumentsContract.deleteDocument(
                                    contentResolver,
                                    Uri.parse(uriValue),
                                ),
                            )
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }

                    "releasePersistedUriPermission" -> {
                        val uriValue = call.argument<String>("uri")
                        if (uriValue != null) {
                            releaseUriPermission(Uri.parse(uriValue))
                        }
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            REQUEST_PICK_FOLDER -> handleFolderResult(resultCode, data)
            REQUEST_PICK_DOCUMENTS -> handleDocumentsResult(resultCode, data)
        }
    }

    private fun handleFolderResult(resultCode: Int, data: Intent?) {
        val channelResult = pendingFolderResult ?: return
        pendingFolderResult = null

        val treeUri = data?.data
        if (resultCode != Activity.RESULT_OK || treeUri == null) {
            channelResult.success(null)
            return
        }

        persistUriPermission(treeUri, data.flags)
        val documentId = DocumentsContract.getTreeDocumentId(treeUri)
        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)
        val name = queryDisplayName(documentUri) ?: "Folder"
        channelResult.success(
            mapOf(
                "uri" to treeUri.toString(),
                "name" to name,
            ),
        )
    }

    private fun handleDocumentsResult(resultCode: Int, data: Intent?) {
        val channelResult = pendingDocumentsResult ?: return
        pendingDocumentsResult = null

        if (resultCode != Activity.RESULT_OK || data == null) {
            channelResult.success(emptyList<Map<String, Any?>>())
            return
        }

        val documents = mutableListOf<Map<String, Any?>>()
        val clipData = data.clipData
        if (clipData != null) {
            for (index in 0 until clipData.itemCount) {
                val uri = clipData.getItemAt(index)?.uri ?: continue
                persistUriPermission(uri, data.flags)
                queryDocument(uri)?.let(documents::add)
            }
        } else {
            val uri = data.data
            if (uri != null) {
                persistUriPermission(uri, data.flags)
                queryDocument(uri)?.let(documents::add)
            }
        }

        channelResult.success(documents)
    }

    private fun listFolderFiles(treeUri: Uri): List<Map<String, Any?>> {
        val results = mutableListOf<Map<String, Any?>>()
        val rootDocumentId = DocumentsContract.getTreeDocumentId(treeUri)
        val rootDocumentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, rootDocumentId)
        traverseTree(treeUri, rootDocumentUri, results)
        return results
    }

    private fun traverseTree(
        treeUri: Uri,
        documentUri: Uri,
        output: MutableList<Map<String, Any?>>,
    ) {
        val documentId = DocumentsContract.getDocumentId(documentUri)
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId)
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
            DocumentsContract.Document.COLUMN_SIZE,
        )

        contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
            while (cursor.moveToNext()) {
                val childDocumentId = cursor.getString(0) ?: continue
                val name = cursor.getString(1) ?: "Unnamed"
                val mimeType = cursor.getString(2)
                val lastModified = cursor.getLongOrZero(3)
                val size = cursor.getLongOrZero(4)
                val childUri =
                    DocumentsContract.buildDocumentUriUsingTree(treeUri, childDocumentId)

                if (mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
                    traverseTree(treeUri, childUri, output)
                } else {
                    output.add(
                        mapOf(
                            "uri" to childUri.toString(),
                            "name" to name,
                            "size" to size,
                            "modifiedAt" to lastModified,
                            "mimeType" to mimeType,
                        ),
                    )
                }
            }
        }
    }

    private fun queryDocument(uri: Uri): Map<String, Any?>? {
        val projection = arrayOf(
            OpenableColumns.DISPLAY_NAME,
            OpenableColumns.SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
        )

        contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (!cursor.moveToFirst()) return null
            return mapOf(
                "uri" to uri.toString(),
                "name" to (cursor.getString(0) ?: "Unnamed"),
                "size" to cursor.getLongOrZero(1),
                "modifiedAt" to cursor.getLongOrZero(2),
                "mimeType" to cursor.getString(3),
            )
        }

        return null
    }

    private fun queryDisplayName(uri: Uri): String? {
        contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                return cursor.getString(0)
            }
        }
        return null
    }

    private fun persistUriPermission(uri: Uri, flags: Int) {
        val persistFlags =
            flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        val permissionFlags =
            if (persistFlags != 0) persistFlags else Intent.FLAG_GRANT_READ_URI_PERMISSION

        try {
            contentResolver.takePersistableUriPermission(uri, permissionFlags)
        } catch (_: SecurityException) {
            // Ignore providers that do not support persistable permissions.
        }
    }

    private fun releaseUriPermission(uri: Uri) {
        try {
            contentResolver.releasePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
        } catch (_: SecurityException) {
            // Ignore permissions that are already released or not persisted.
        }
    }

    private fun Cursor.getLongOrZero(index: Int): Long {
        return if (isNull(index)) 0L else getLong(index)
    }
}
