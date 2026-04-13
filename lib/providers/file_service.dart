import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/review_item.dart';
import '../models/scan_folder_grant.dart';
import '../models/storage_document.dart';
import '../services/document_access_service.dart';
import 'review_provider.dart';
import 'settings_provider.dart';

enum ScanPhase { idle, scanningMedia, scanningCustomFolders }

class ScanSummary {
  final int photoCount;
  final int videoCount;
  final int downloadCount;
  final int totalSize;

  const ScanSummary({
    required this.photoCount,
    required this.videoCount,
    required this.downloadCount,
    required this.totalSize,
  });
}

class FileService extends ChangeNotifier {
  static const String _keyCachedPhotoCount = 'cachedPhotoCount';
  static const String _keyCachedVideoCount = 'cachedVideoCount';
  static const String _keyCachedDownloadCount = 'cachedDownloadCount';
  static const String _keyCachedTotalSize = 'cachedTotalSize';
  static const String _keyImportedDocuments = 'importedDocuments';

  final DocumentAccessService _documentAccessService;

  FileService(this._documentAccessService);

  bool _isLoading = false;
  bool _permissionDenied = false;
  List<ReviewItem> _items = [];
  ScanSummary? _cachedSummary;
  bool _isBackgroundScanning = false;
  List<StorageDocument> _importedDocuments = const [];
  late final SharedPreferences _prefs;

  double _scanProgress = 0.0;
  ScanPhase _scanPhase = ScanPhase.idle;
  int _processedAssets = 0;
  int _totalEstimatedAssets = 0;
  final Stopwatch _throttle = Stopwatch();

  bool get isLoading => _isLoading;
  bool get permissionDenied => _permissionDenied;
  List<ReviewItem> get items => List.unmodifiable(_items);
  ScanSummary? get cachedSummary => _cachedSummary;
  bool get isBackgroundScanning => _isBackgroundScanning;
  int get importedDocumentCount => _importedDocuments.length;
  bool get hasImportedDocuments => _importedDocuments.isNotEmpty;
  double get scanProgress => _scanProgress;
  ScanPhase get scanPhase => _scanPhase;
  int get processedAssets => math.min(_processedAssets, _totalEstimatedAssets);
  int get totalEstimatedAssets => _totalEstimatedAssets;

  Future<void> refreshAllFiles(
    SettingsProvider settings, {
    bool updateCache = true,
  }) {
    return scanForNewFiles(
      settings,
      since: DateTime.fromMillisecondsSinceEpoch(0),
      updateCache: updateCache,
    );
  }

  void _updateProgress() {
    final processedCount = processedAssets;
    _scanProgress = _totalEstimatedAssets > 0
        ? processedCount / _totalEstimatedAssets
        : 0.0;
    if (processedCount >= _totalEstimatedAssets ||
        !_throttle.isRunning ||
        _throttle.elapsedMilliseconds >= 66) {
      _throttle.reset();
      _throttle.start();
      notifyListeners();
    }
  }

  void _resetTransientScanState() {
    _scanProgress = 0.0;
    _scanPhase = ScanPhase.idle;
    _processedAssets = 0;
    _totalEstimatedAssets = 0;
    _throttle.stop();
    _throttle.reset();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final photo = _prefs.getInt(_keyCachedPhotoCount);
    final video = _prefs.getInt(_keyCachedVideoCount);
    final download = _prefs.getInt(_keyCachedDownloadCount);
    final size = _prefs.getInt(_keyCachedTotalSize);

    if (photo != null && video != null && download != null && size != null) {
      _cachedSummary = ScanSummary(
        photoCount: photo,
        videoCount: video,
        downloadCount: download,
        totalSize: size,
      );
    }

    _importedDocuments = (_prefs.getStringList(_keyImportedDocuments) ?? const [])
        .map((raw) => StorageDocument.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<bool> requestPermissions(SettingsProvider settings) async {
    final permissions = <Permission>[];
    if (settings.scanPhotos) permissions.add(Permission.photos);
    if (settings.scanVideos) permissions.add(Permission.videos);
    if (Platform.isAndroid && (settings.scanPhotos || settings.scanVideos)) {
      permissions.add(Permission.storage);
    }

    if (permissions.isEmpty) {
      _permissionDenied = false;
      notifyListeners();
      return true;
    }

    final results = await Future.wait(
      permissions.map((permission) => permission.request()),
    );

    final anyGranted =
        results.any((status) => status.isGranted || status.isLimited);
    _permissionDenied = !anyGranted;
    notifyListeners();
    return anyGranted;
  }

  Future<int> importDownloadDocuments() async {
    final pickedDocuments = await _documentAccessService.pickDocuments();
    if (pickedDocuments.isEmpty) return 0;

    final newDocuments = _filterNewImportedDocuments(pickedDocuments);
    if (newDocuments.isEmpty) return 0;

    _importedDocuments = [..._importedDocuments, ...newDocuments];
    await _persistImportedDocuments();
    notifyListeners();
    return newDocuments.length;
  }

  Future<void> clearImportedDocuments() async {
    await _releasePersistedPermissions(
      _importedDocuments.map((document) => document.uri),
    );

    _importedDocuments = const [];
    _items = _items
        .where((item) => item.source != ReviewItemSource.importedDocument)
        .toList();
    await _persistImportedDocuments();
    _cachedSummary = _computeSummary();
    await _persistSummary(_cachedSummary!);
    notifyListeners();
  }

  Future<void> resolveImportedDocumentsAfterReview(
    ReviewCompletionResult result,
  ) async {
    final retainedUris = {
      ...result.remainingItems
          .where((item) => item.source == ReviewItemSource.importedDocument)
          .map((item) => item.contentUri),
      ...result.failedDeletionItems
          .where((item) => item.source == ReviewItemSource.importedDocument)
          .map((item) => item.contentUri),
    }.whereType<String>().toSet();

    final removed = _importedDocuments
        .where((document) => !retainedUris.contains(document.uri))
        .toList();

    await _releasePersistedPermissions(
      removed.map((document) => document.uri),
    );

    _importedDocuments = _importedDocuments
        .where((document) => retainedUris.contains(document.uri))
        .toList();
    await _persistImportedDocuments();
    notifyListeners();
  }

  Future<void> scanForNewFiles(
    SettingsProvider settings, {
    DateTime? since,
    bool updateCache = false,
  }) async {
    if (_cachedSummary != null && _items.isEmpty) {
      _isBackgroundScanning = true;
    } else {
      _isLoading = true;
    }

    _resetTransientScanState();
    notifyListeners();

    final found = <ReviewItem>[];
    since ??= settings.lastReviewTimestamp;

    try {
      final scanMedia = (settings.scanPhotos || settings.scanVideos)
          ? _scanMediaAssets(settings, since)
          : Future.value(<ReviewItem>[]);

      final scanCustomFolders = settings.customFolders.isNotEmpty
          ? _scanCustomFolders(settings.customFolders, since)
          : Future.value(<ReviewItem>[]);

      final results = await Future.wait([scanMedia, scanCustomFolders]);
      for (final items in results) {
        found.addAll(items);
      }
      found.addAll(
        _importedDocuments.map((document) {
          return _reviewItemFromDocument(
            document,
            source: ReviewItemSource.importedDocument,
          );
        }),
      );

      found.sort((a, b) => b.date.compareTo(a.date));
      _items = _dedupe(found);
    } catch (_) {
      _items = found;
    } finally {
      if (updateCache) {
        _cachedSummary = _computeSummary();
        await _persistSummary(_cachedSummary!);
      }
      _isLoading = false;
      _isBackgroundScanning = false;
      _resetTransientScanState();
      notifyListeners();
    }
  }

  Future<void> _persistImportedDocuments() async {
    await _prefs.setStringList(
      _keyImportedDocuments,
      _importedDocuments
          .map((document) => jsonEncode(document.toJson()))
          .toList(),
    );
  }

  Future<void> _persistSummary(ScanSummary summary) async {
    await _prefs.setInt(_keyCachedPhotoCount, summary.photoCount);
    await _prefs.setInt(_keyCachedVideoCount, summary.videoCount);
    await _prefs.setInt(_keyCachedDownloadCount, summary.downloadCount);
    await _prefs.setInt(_keyCachedTotalSize, summary.totalSize);
  }

  List<ReviewItem> _dedupe(List<ReviewItem> items) {
    final seen = <String>{};
    return items.where((item) => seen.add(_dedupeKey(item))).toList();
  }

  String _dedupeKey(ReviewItem item) {
    return [
      item.type.name,
      item.name.toLowerCase(),
      item.size,
      item.date.millisecondsSinceEpoch,
    ].join('|');
  }

  Future<void> _releasePersistedPermissions(Iterable<String> uris) async {
    for (final uri in uris) {
      await _documentAccessService.releasePersistedUriPermission(uri);
    }
  }

  List<StorageDocument> _filterNewImportedDocuments(
    List<StorageDocument> documents,
  ) {
    final existingUris = _importedDocuments.map((entry) => entry.uri).toSet();
    final newDocuments = <StorageDocument>[];

    for (final document in documents) {
      if (existingUris.add(document.uri)) {
        newDocuments.add(document);
      }
    }

    return newDocuments;
  }

  ScanSummary _computeSummary() {
    var photoCount = 0;
    var videoCount = 0;
    var downloadCount = 0;
    var totalSize = 0;
    for (final item in _items) {
      totalSize += item.size;
      switch (item.type) {
        case FileItemType.photo:
          photoCount++;
        case FileItemType.video:
          videoCount++;
        case FileItemType.download:
          downloadCount++;
      }
    }
    return ScanSummary(
      photoCount: photoCount,
      videoCount: videoCount,
      downloadCount: downloadCount,
      totalSize: totalSize,
    );
  }

  ReviewItem _reviewItemFromDocument(
    StorageDocument document, {
    required ReviewItemSource source,
  }) {
    return ReviewItem(
      id: document.uri,
      name: document.name,
      contentUri: document.uri,
      size: document.size,
      type: _classifyDocument(document),
      date: document.modifiedAt,
      source: source,
      mimeType: document.mimeType,
    );
  }

  FileItemType _classifyDocument(StorageDocument document) {
    final mimeType = document.mimeType?.toLowerCase() ?? '';
    if (mimeType.startsWith('image/')) return FileItemType.photo;
    if (mimeType.startsWith('video/')) return FileItemType.video;

    final extension = p.extension(document.name).toLowerCase();
    if (const {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'}
        .contains(extension)) {
      return FileItemType.photo;
    }
    if (const {'.mp4', '.mov', '.mkv', '.webm', '.avi'}
        .contains(extension)) {
      return FileItemType.video;
    }
    return FileItemType.download;
  }

  Future<List<ReviewItem>> _scanMediaAssets(
    SettingsProvider settings,
    DateTime? since,
  ) async {
    final permissionState = await PhotoManager.requestPermissionExtend();
    if (!permissionState.isAuth && !permissionState.hasAccess) return [];

    final RequestType requestType;
    if (settings.scanPhotos && settings.scanVideos) {
      requestType = RequestType.common;
    } else if (settings.scanPhotos) {
      requestType = RequestType.image;
    } else {
      requestType = RequestType.video;
    }

    final albums = await PhotoManager.getAssetPathList(type: requestType);
    final assets = await _loadUniqueMediaAssets(albums);

    _totalEstimatedAssets += assets.length;
    _scanPhase = ScanPhase.scanningMedia;
    _updateProgress();

    final result = <ReviewItem>[];

    for (final asset in assets) {
      final assetDate = asset.createDateTime;
      if (since != null && !assetDate.isAfter(since)) {
        _processedAssets++;
        _updateProgress();
        continue;
      }

      final file = await asset.file;
      if (file == null) {
        _processedAssets++;
        _updateProgress();
        continue;
      }

      final itemType =
          asset.type == AssetType.video ? FileItemType.video : FileItemType.photo;

      result.add(
        ReviewItem(
          id: asset.id,
          name: asset.title ?? asset.id,
          path: file.path,
          size: await file.length(),
          type: itemType,
          date: assetDate,
          source: ReviewItemSource.mediaLibrary,
        ),
      );

      _processedAssets++;
      _updateProgress();
    }

    return result;
  }

  Future<List<AssetEntity>> _loadUniqueMediaAssets(
    List<AssetPathEntity> albums,
  ) async {
    final uniqueAssets = <String, AssetEntity>{};

    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count == 0) continue;

      final assets = await album.getAssetListRange(start: 0, end: count);
      for (final asset in assets) {
        uniqueAssets.putIfAbsent(asset.id, () => asset);
      }
    }

    return uniqueAssets.values.toList();
  }

  Future<List<ReviewItem>> _scanCustomFolders(
    List<ScanFolderGrant> folders,
    DateTime? since,
  ) async {
    final result = <ReviewItem>[];
    _scanPhase = ScanPhase.scanningCustomFolders;
    _updateProgress();

    for (final folder in folders) {
      final documents = await _documentAccessService.listFolderFiles(folder.uri);
      _totalEstimatedAssets += documents.length;
      _updateProgress();

      for (final document in documents) {
        if (since != null && !document.modifiedAt.isAfter(since)) {
          _processedAssets++;
          _updateProgress();
          continue;
        }

        result.add(
          _reviewItemFromDocument(
            document,
            source: ReviewItemSource.customFolder,
          ),
        );
        _processedAssets++;
        _updateProgress();
      }
    }

    return result;
  }
}
