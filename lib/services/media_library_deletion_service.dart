import 'package:photo_manager/photo_manager.dart';

import '../models/review_item.dart';

class MediaLibraryDeletionResult {
  final Set<String> trashedIds;
  final Set<String> permanentlyDeletedIds;

  const MediaLibraryDeletionResult({
    this.trashedIds = const {},
    this.permanentlyDeletedIds = const {},
  });
}

abstract class MediaLibraryDeletionService {
  Future<MediaLibraryDeletionResult> removeFromLibrary(List<ReviewItem> items);
}

class PhotoManagerMediaLibraryDeletionService
    implements MediaLibraryDeletionService {
  const PhotoManagerMediaLibraryDeletionService();

  @override
  Future<MediaLibraryDeletionResult> removeFromLibrary(
    List<ReviewItem> items,
  ) async {
    if (items.isEmpty) return const MediaLibraryDeletionResult();

    final ids = items.map((item) => item.id).toSet();
    try {
      final trashedIds = (await PhotoManager.editor.android.moveToTrash(
        items.map(_assetEntityForItem).toList(),
      )).toSet();

      return MediaLibraryDeletionResult(trashedIds: trashedIds);
    } catch (_) {
      try {
        final deletedIds = (await PhotoManager.editor.deleteWithIds(
          ids.toList(),
        )).toSet();

        return MediaLibraryDeletionResult(permanentlyDeletedIds: deletedIds);
      } catch (_) {
        return const MediaLibraryDeletionResult();
      }
    }
  }

  AssetEntity _assetEntityForItem(ReviewItem item) {
    final type = item.type == FileItemType.video
        ? AssetType.video
        : AssetType.image;
    final timestampSeconds = item.date.millisecondsSinceEpoch ~/ 1000;

    return AssetEntity(
      id: item.id,
      typeInt: type.index,
      width: 0,
      height: 0,
      duration: item.durationSeconds ?? 0,
      title: item.name,
      createDateSecond: timestampSeconds,
      modifiedDateSecond: timestampSeconds,
      mimeType: item.mimeType,
    );
  }
}
