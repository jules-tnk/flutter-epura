import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/review_item.dart';
import 'settings_provider.dart';

enum ScanPhase { idle, scanningMedia, scanningDownloads }

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

  bool get isEmpty => photoCount == 0 && videoCount == 0 && downloadCount == 0;
  int get totalCount => photoCount + videoCount + downloadCount;
}

class FileService extends ChangeNotifier {
  static const String _keyCachedPhotoCount = 'cachedPhotoCount';
  static const String _keyCachedVideoCount = 'cachedVideoCount';
  static const String _keyCachedDownloadCount = 'cachedDownloadCount';
  static const String _keyCachedTotalSize = 'cachedTotalSize';

  bool _isLoading = false;
  bool _permissionDenied = false;
  List<ReviewItem> _items = [];
  ScanSummary? _cachedSummary;
  bool _isBackgroundScanning = false;
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
  double get scanProgress => _scanProgress;
  ScanPhase get scanPhase => _scanPhase;
  int get processedAssets => _processedAssets;
  int get totalEstimatedAssets => _totalEstimatedAssets;

  void _updateProgress() {
    _scanProgress = _totalEstimatedAssets > 0
        ? _processedAssets / _totalEstimatedAssets
        : 0.0;
    if (_processedAssets >= _totalEstimatedAssets ||
        !_throttle.isRunning ||
        _throttle.elapsedMilliseconds >= 66) {
      _throttle.reset();
      _throttle.start();
      notifyListeners();
    }
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
  }

  Future<bool> requestPermissions() async {
    final results = await [
      Permission.photos.request(),
      Permission.videos.request(),
      Permission.storage.request(),
    ].wait;

    final anyGranted = results.any((s) => s.isGranted);
    _permissionDenied = !anyGranted;
    notifyListeners();
    return anyGranted;
  }

  Future<bool> requestManageStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> scanForNewFiles(SettingsProvider settings, {DateTime? since, bool updateCache = false}) async {
    if (_cachedSummary != null && _items.isEmpty) {
      _isBackgroundScanning = true;
    } else {
      _isLoading = true;
    }

    _scanProgress = 0.0;
    _scanPhase = ScanPhase.idle;
    _processedAssets = 0;
    _totalEstimatedAssets = 0;
    _throttle.stop();
    _throttle.reset();
    notifyListeners();

    final List<ReviewItem> found = [];
    since ??= settings.lastReviewTimestamp;

    try {
      final scanMedia = (settings.scanPhotos || settings.scanVideos)
          ? _scanMediaAssets(settings, since)
          : Future.value(<ReviewItem>[]);

      final scanDownloads = settings.scanDownloads
          ? requestManageStoragePermission()
              .then((_) => _scanDownloadsDirectory(since))
          : Future.value(<ReviewItem>[]);

      final results = await Future.wait([scanMedia, scanDownloads]);
      for (final items in results) {
        found.addAll(items);
      }

      found.sort((a, b) => b.date.compareTo(a.date));
      _items = found;
    } catch (_) {
      _items = found;
    } finally {
      if (updateCache) {
        _cachedSummary = _computeSummary();
        await _prefs.setInt(_keyCachedPhotoCount, _cachedSummary!.photoCount);
        await _prefs.setInt(_keyCachedVideoCount, _cachedSummary!.videoCount);
        await _prefs.setInt(_keyCachedDownloadCount, _cachedSummary!.downloadCount);
        await _prefs.setInt(_keyCachedTotalSize, _cachedSummary!.totalSize);
      }
      _isLoading = false;
      _isBackgroundScanning = false;
      _scanProgress = 0.0;
      _scanPhase = ScanPhase.idle;
      _processedAssets = 0;
      _totalEstimatedAssets = 0;
      _throttle.stop();
      notifyListeners();
    }
  }

  ScanSummary _computeSummary() {
    var photoCount = 0;
    var videoCount = 0;
    var downloadCount = 0;
    var totalSize = 0;
    for (final i in _items) {
      totalSize += i.size;
      switch (i.type) {
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

  Future<List<ReviewItem>> _scanMediaAssets(
    SettingsProvider settings,
    DateTime? since,
  ) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth && !ps.hasAccess) return [];

    final RequestType requestType;
    if (settings.scanPhotos && settings.scanVideos) {
      requestType = RequestType.common;
    } else if (settings.scanPhotos) {
      requestType = RequestType.image;
    } else {
      requestType = RequestType.video;
    }

    final albums = await PhotoManager.getAssetPathList(type: requestType);

    // Count total media assets for progress tracking
    int mediaTotal = 0;
    for (final album in albums) {
      mediaTotal += await album.assetCountAsync;
    }
    _totalEstimatedAssets += mediaTotal;
    _scanPhase = ScanPhase.scanningMedia;
    _updateProgress();

    final List<ReviewItem> result = [];

    for (final album in albums) {
      final int count = await album.assetCountAsync;
      if (count == 0) continue;

      final assets = await album.getAssetListRange(start: 0, end: count);

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

        final fileSize = await file.length();

        final FileItemType itemType =
            asset.type == AssetType.video ? FileItemType.video : FileItemType.photo;

        result.add(ReviewItem(
          id: asset.id,
          name: asset.title ?? asset.id,
          path: file.path,
          size: fileSize,
          type: itemType,
          date: assetDate,
        ));

        _processedAssets++;
        _updateProgress();
      }
    }

    final seen = <String>{};
    return result.where((item) => seen.add(item.id)).toList();
  }

  Future<List<ReviewItem>> _scanDownloadsDirectory(DateTime? since) async {
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      downloadsDir = Directory('${docs.path}/Downloads');
    } else {
      return [];
    }

    if (!downloadsDir.existsSync()) return [];

    final List<ReviewItem> result = [];

    final entities = downloadsDir.listSync(recursive: false);

    // Add download count for progress tracking
    _totalEstimatedAssets += entities.length;
    _scanPhase = ScanPhase.scanningDownloads;
    _updateProgress();

    for (final entity in entities) {
      if (entity is! File) {
        _processedAssets++;
        _updateProgress();
        continue;
      }

      final stat = entity.statSync();
      final modified = stat.modified;

      if (since != null && !modified.isAfter(since)) {
        _processedAssets++;
        _updateProgress();
        continue;
      }

      final name = p.basename(entity.path);

      result.add(ReviewItem(
        id: entity.path,
        name: name,
        path: entity.path,
        size: stat.size,
        type: FileItemType.download,
        date: modified,
      ));

      _processedAssets++;
      _updateProgress();
    }

    return result;
  }
}
