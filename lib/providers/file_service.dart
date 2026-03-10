import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/review_item.dart';
import 'settings_provider.dart';

class FileService extends ChangeNotifier {
  bool _isLoading = false;
  bool _permissionDenied = false;
  List<ReviewItem> _items = [];

  bool get isLoading => _isLoading;
  bool get permissionDenied => _permissionDenied;
  List<ReviewItem> get items => List.unmodifiable(_items);

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

  Future<void> scanForNewFiles(SettingsProvider settings, {DateTime? since}) async {
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
    }
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

    final List<ReviewItem> result = [];

    for (final album in albums) {
      final int count = await album.assetCountAsync;
      if (count == 0) continue;

      final assets = await album.getAssetListRange(start: 0, end: count);

      for (final asset in assets) {
        final assetDate = asset.createDateTime;
        if (since != null && !assetDate.isAfter(since)) continue;

        final file = await asset.file;
        if (file == null) continue;

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
    for (final entity in entities) {
      if (entity is! File) continue;

      final stat = entity.statSync();
      final modified = stat.modified;

      if (since != null && !modified.isAfter(since)) continue;

      final name = p.basename(entity.path);

      result.add(ReviewItem(
        id: entity.path,
        name: name,
        path: entity.path,
        size: stat.size,
        type: FileItemType.download,
        date: modified,
      ));
    }

    return result;
  }
}
