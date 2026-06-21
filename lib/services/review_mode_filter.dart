import '../models/download_file_category.dart';
import '../models/review_item.dart';
import '../models/review_mode.dart';

List<ReviewItem> filterReviewItemsForMode(
  List<ReviewItem> items,
  ReviewMode mode,
) {
  final filtered = items.where((item) {
    switch (mode.type) {
      case ReviewModeType.recent:
        return true;
      case ReviewModeType.largestFiles:
        return true;
      case ReviewModeType.screenshots:
        return item.type == FileItemType.photo && _isScreenshot(item);
      case ReviewModeType.largeVideos:
        return item.type == FileItemType.video;
      case ReviewModeType.downloads:
        return item.source == ReviewItemSource.importedDocument &&
            (mode.downloadCategory == null ||
                downloadFileCategoryForItem(item) == mode.downloadCategory);
      case ReviewModeType.selectedFolders:
        return item.source == ReviewItemSource.customFolder;
      case ReviewModeType.folder:
        return item.source == ReviewItemSource.customFolder &&
            item.folderUri == mode.folderUri;
      case ReviewModeType.bursts:
        return true;
      case ReviewModeType.duplicates:
        return true;
      case ReviewModeType.skipped:
        return true;
    }
  }).toList();

  switch (mode.sortOrder) {
    case ReviewSortOrder.newestFirst:
      filtered.sort((a, b) => b.date.compareTo(a.date));
    case ReviewSortOrder.largestFirst:
      filtered.sort((a, b) {
        final bySize = b.size.compareTo(a.size);
        return bySize != 0 ? bySize : b.date.compareTo(a.date);
      });
  }

  return filtered;
}

bool _isScreenshot(ReviewItem item) {
  final name = item.name.toLowerCase();
  final path = item.path?.toLowerCase() ?? '';
  return name.contains('screenshot') ||
      name.contains('screen_shot') ||
      name.contains('screen shot') ||
      path.contains('/screenshots/') ||
      path.contains(r'\screenshots\');
}
