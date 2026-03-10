import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/review_item.dart';

class ThumbnailCache {
  final Map<String, Uint8List> _cache = {};

  Uint8List? get(String id) => _cache[id];

  void clear() => _cache.clear();

  Future<void> prefetch(List<ReviewItem> items) async {
    for (final item in items) {
      if (item.type == FileItemType.download) continue;
      if (_cache.containsKey(item.id)) continue;

      final bytes = await _loadThumbnail(item);
      if (bytes != null && bytes.isNotEmpty) {
        _cache[item.id] = bytes;
      }
    }
  }

  Future<Uint8List?> _loadThumbnail(ReviewItem item) async {
    // Try photo_manager first (works for both photos and videos)
    try {
      final asset = await AssetEntity.fromId(item.id);
      if (asset != null) {
        final bytes = await asset.thumbnailDataWithSize(
          const ThumbnailSize(600, 600),
          quality: 80,
        );
        if (bytes != null && bytes.isNotEmpty) return bytes;
      }
    } catch (_) {}

    // Fallback for videos: use video_thumbnail package
    if (item.type == FileItemType.video) {
      try {
        final bytes = await VideoThumbnail.thumbnailData(
          video: item.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 600,
          quality: 80,
        );
        if (bytes != null && bytes.isNotEmpty) return bytes;
      } catch (_) {}
    }

    return null;
  }
}
