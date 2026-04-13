import 'dart:io';

import 'package:flutter/services.dart';

import '../models/scan_folder_grant.dart';
import '../models/storage_document.dart';

abstract interface class DocumentAccessService {
  Future<ScanFolderGrant?> pickFolder();
  Future<List<StorageDocument>> pickDocuments();
  Future<List<StorageDocument>> listFolderFiles(String treeUri);
  Future<bool> deleteDocument(String uri);
  Future<void> releasePersistedUriPermission(String uri);
}

class MethodChannelDocumentAccessService implements DocumentAccessService {
  static const MethodChannel _channel =
      MethodChannel('com.epura.cleaner/document_access');

  const MethodChannelDocumentAccessService();

  @override
  Future<ScanFolderGrant?> pickFolder() async {
    final raw = await _invokeMapMethod('pickFolder');
    if (raw == null) return null;
    return ScanFolderGrant.fromJson(raw);
  }

  @override
  Future<List<StorageDocument>> pickDocuments() async {
    return _invokeDocumentsMethod('pickDocuments');
  }

  @override
  Future<List<StorageDocument>> listFolderFiles(String treeUri) async {
    return _invokeDocumentsMethod(
      'listFolderFiles',
      arguments: {'treeUri': treeUri},
    );
  }

  @override
  Future<bool> deleteDocument(String uri) async {
    if (!Platform.isAndroid) return false;
    final result = await _channel.invokeMethod<bool>(
      'deleteDocument',
      {'uri': uri},
    );
    return result ?? false;
  }

  @override
  Future<void> releasePersistedUriPermission(String uri) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>(
      'releasePersistedUriPermission',
      {'uri': uri},
    );
  }

  List<StorageDocument> _parseDocuments(List<Object?>? raw) {
    if (raw == null) return const [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((entry) => StorageDocument.fromJson(_normalizeMap(entry)))
        .toList();
  }

  Map<String, dynamic> _normalizeMap(Map<Object?, Object?> raw) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  Future<Map<String, dynamic>?> _invokeMapMethod(
    String method, {
    Map<String, Object?>? arguments,
  }) async {
    if (!Platform.isAndroid) return null;
    final raw =
        await _channel.invokeMethod<Map<Object?, Object?>>(method, arguments);
    return raw == null ? null : _normalizeMap(raw);
  }

  Future<List<StorageDocument>> _invokeDocumentsMethod(
    String method, {
    Map<String, Object?>? arguments,
  }) async {
    if (!Platform.isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<Object?>>(method, arguments);
    return _parseDocuments(raw);
  }
}
