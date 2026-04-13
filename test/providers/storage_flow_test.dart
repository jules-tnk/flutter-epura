import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/models/storage_document.dart';

import '../test_helpers.dart';

void main() {
  test('custom folder grants are persisted and removable', () async {
    final context = await createTestContext();
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/custom',
      name: 'Receipts',
    );

    expect(context.settings.customFolders, isEmpty);

    final addedFolder = await context.settings.addCustomFolder();

    expect(addedFolder?.name, 'Receipts');
    expect(context.settings.customFolders, hasLength(1));

    final restored = await createTestContext(
      prefs: {
        'customFolders': [
          jsonEncode(
            const ScanFolderGrant(
              uri: 'content://tree/custom',
              name: 'Receipts',
            ).toJson(),
          ),
        ],
      },
    );
    expect(restored.settings.customFolders, hasLength(1));
    expect(restored.settings.customFolders.first.name, 'Receipts');

    await context.settings.removeCustomFolder(context.settings.customFolders.first);

    expect(context.settings.customFolders, isEmpty);
    expect(context.documents.releasedUris, contains('content://tree/custom'));
  });

  test('imported documents merge into scans and failed SAF deletions stay queued', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);

    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/work',
      name: 'Work',
    );
    await context.settings.addCustomFolder();

    final folderDocument = StorageDocument(
      uri: 'content://doc/work-note',
      name: 'note.txt',
      size: 50,
      modifiedAt: DateTime(2026, 4, 11),
      mimeType: 'text/plain',
    );
    context.documents.folderFilesByUri['content://tree/work'] = [folderDocument];

    final importedDocument = StorageDocument(
      uri: 'content://doc/imported-report',
      name: 'report.pdf',
      size: 120,
      modifiedAt: DateTime(2026, 4, 12),
      mimeType: 'application/pdf',
    );
    context.documents.nextPickedDocuments = [importedDocument];
    await context.fileService.importDownloadDocuments();

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      updateCache: true,
    );

    expect(context.fileService.items, hasLength(2));
    expect(
      context.fileService.items.map((item) => item.source),
      containsAll([
        ReviewItemSource.customFolder,
        ReviewItemSource.importedDocument,
      ]),
    );

    context.reviewProvider.startReview(context.fileService.items);
    context.reviewProvider.deleteCurrent();
    context.reviewProvider.deleteCurrent();

    context.documents.deleteFailures.add(importedDocument.uri);

    final result = await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );
    await context.fileService.resolveImportedDocumentsAfterReview(result);

    expect(context.reviewProvider.bytesFreed, 50);
    expect(result.failedDeletionItems, hasLength(1));
    expect(result.failedDeletionItems.first.contentUri, importedDocument.uri);
    expect(context.fileService.importedDocumentCount, 1);
    expect(context.documents.releasedUris, isNot(contains(importedDocument.uri)));
  });

  test('imported documents do not allow processed count to exceed total count', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);

    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/work',
      name: 'Work',
    );
    await context.settings.addCustomFolder();

    context.documents.folderFilesByUri['content://tree/work'] = [
      StorageDocument(
        uri: 'content://doc/one',
        name: 'one.txt',
        size: 10,
        modifiedAt: DateTime(2026, 4, 13),
      ),
      StorageDocument(
        uri: 'content://doc/two',
        name: 'two.txt',
        size: 20,
        modifiedAt: DateTime(2026, 4, 13),
      ),
    ];

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
    );

    expect(
      context.fileService.processedAssets <= context.fileService.totalEstimatedAssets,
      isTrue,
    );
  });
}
