import 'download_file_category.dart';

enum ReviewModeType {
  recent,
  largestFiles,
  screenshots,
  largeVideos,
  downloads,
  selectedFolders,
  folder,
  bursts,
  duplicates,
  skipped,
}

enum ReviewSortOrder { newestFirst, largestFirst }

class ReviewMode {
  final ReviewModeType type;
  final ReviewSortOrder sortOrder;
  final bool usesLookback;
  final String? folderUri;
  final String? folderName;
  final DownloadFileCategory? downloadCategory;

  const ReviewMode._({
    required this.type,
    required this.sortOrder,
    required this.usesLookback,
    this.folderUri,
    this.folderName,
    this.downloadCategory,
  });

  const ReviewMode.recent()
    : this._(
        type: ReviewModeType.recent,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: true,
      );

  const ReviewMode.largestFiles()
    : this._(
        type: ReviewModeType.largestFiles,
        sortOrder: ReviewSortOrder.largestFirst,
        usesLookback: true,
      );

  const ReviewMode.screenshots()
    : this._(
        type: ReviewModeType.screenshots,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: true,
      );

  const ReviewMode.largeVideos()
    : this._(
        type: ReviewModeType.largeVideos,
        sortOrder: ReviewSortOrder.largestFirst,
        usesLookback: true,
      );

  const ReviewMode.downloads({DownloadFileCategory? category})
    : this._(
        type: ReviewModeType.downloads,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: false,
        downloadCategory: category,
      );

  const ReviewMode.selectedFolders()
    : this._(
        type: ReviewModeType.selectedFolders,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: true,
      );

  const ReviewMode.folder({
    required String folderUri,
    required String folderName,
  }) : this._(
         type: ReviewModeType.folder,
         sortOrder: ReviewSortOrder.newestFirst,
         usesLookback: true,
         folderUri: folderUri,
         folderName: folderName,
       );

  const ReviewMode.bursts()
    : this._(
        type: ReviewModeType.bursts,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: true,
      );

  const ReviewMode.duplicates()
    : this._(
        type: ReviewModeType.duplicates,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: false,
      );

  const ReviewMode.skipped()
    : this._(
        type: ReviewModeType.skipped,
        sortOrder: ReviewSortOrder.newestFirst,
        usesLookback: false,
      );
}
