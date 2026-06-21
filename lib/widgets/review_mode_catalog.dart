import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/review_mode.dart';
import '../providers/file_service.dart';
import '../providers/settings_provider.dart';

List<ReviewMode> availableReviewModes(
  FileService fileService,
  SettingsProvider settings,
) {
  return [
    const ReviewMode.recent(),
    const ReviewMode.largestFiles(),
    const ReviewMode.screenshots(),
    const ReviewMode.largeVideos(),
    const ReviewMode.bursts(),
    const ReviewMode.duplicates(),
    const ReviewMode.skipped(),
    if (fileService.hasImportedDocuments) const ReviewMode.downloads(),
    if (settings.customFolders.isNotEmpty) const ReviewMode.selectedFolders(),
    ...settings.customFolders.map(
      (folder) => ReviewMode.folder(
        folderUri: folder.uri,
        folderName: folder.displayName,
      ),
    ),
  ];
}

String reviewModeLabel(AppLocalizations l, ReviewMode mode) {
  switch (mode.type) {
    case ReviewModeType.recent:
      return l.reviewModeRecent;
    case ReviewModeType.largestFiles:
      return l.reviewModeLargestFiles;
    case ReviewModeType.screenshots:
      return l.reviewModeScreenshots;
    case ReviewModeType.largeVideos:
      return l.reviewModeLargeVideos;
    case ReviewModeType.bursts:
      return l.reviewModeBursts;
    case ReviewModeType.downloads:
      return l.reviewModeDownloads;
    case ReviewModeType.selectedFolders:
      return l.reviewModeSelectedFolders;
    case ReviewModeType.folder:
      return l.reviewModeFolder(mode.folderName ?? l.reviewModeSelectedFolders);
    case ReviewModeType.duplicates:
      return l.reviewModeDuplicates;
    case ReviewModeType.skipped:
      return l.reviewModeSkipped;
  }
}

IconData reviewModeIcon(ReviewMode mode) {
  switch (mode.type) {
    case ReviewModeType.recent:
      return Icons.schedule_outlined;
    case ReviewModeType.largestFiles:
      return Icons.folder_outlined;
    case ReviewModeType.screenshots:
      return Icons.screenshot_monitor_outlined;
    case ReviewModeType.largeVideos:
      return Icons.video_library_outlined;
    case ReviewModeType.bursts:
      return Icons.burst_mode_outlined;
    case ReviewModeType.downloads:
      return Icons.download_outlined;
    case ReviewModeType.selectedFolders:
      return Icons.folder_copy_outlined;
    case ReviewModeType.folder:
      return Icons.folder_open_outlined;
    case ReviewModeType.duplicates:
      return Icons.copy_all_outlined;
    case ReviewModeType.skipped:
      return Icons.visibility_off_outlined;
  }
}
