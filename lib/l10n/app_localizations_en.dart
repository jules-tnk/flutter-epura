// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Epura';

  @override
  String get home => 'Home';

  @override
  String get review => 'Review';

  @override
  String get localOnlyBadge => 'Local only';

  @override
  String get takeControlOfSpace => 'Take control of your space';

  @override
  String get allTime => 'All time';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisSession => 'This session';

  @override
  String get daysInARow => 'days in a row';

  @override
  String get readyToReview => 'Ready to review';

  @override
  String reviewModesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count review modes available',
      one: '1 review mode available',
    );
    return '$_temp0';
  }

  @override
  String get resumeReview => 'Resume review';

  @override
  String get notificationTitle => 'Time to clean up!';

  @override
  String get notificationBody => 'You have new files to review';

  @override
  String get storageAccessNeeded => 'Storage access needed';

  @override
  String get storageAccessExplanation =>
      'Epura needs permission to access your files so you can review them.';

  @override
  String get grantAccess => 'Grant Access';

  @override
  String get openSettings => 'Open Settings';

  @override
  String filesToReview(int count) {
    return '$count files to review';
  }

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get downloads => 'Downloads';

  @override
  String get startReview => 'Start Review';

  @override
  String get stats => 'Stats';

  @override
  String get reviewModes => 'Review modes';

  @override
  String get reviewModeRecent => 'Recent';

  @override
  String get reviewModeLargestFiles => 'Largest';

  @override
  String get reviewModeScreenshots => 'Screenshots';

  @override
  String get reviewModeLargeVideos => 'Large videos';

  @override
  String get reviewModeBursts => 'Bursts';

  @override
  String get reviewModeDownloads => 'Downloads';

  @override
  String get reviewModeSelectedFolders => 'Selected folders';

  @override
  String reviewModeFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get reviewModeDuplicates => 'Duplicates';

  @override
  String get reviewModeSkipped => 'Skipped';

  @override
  String get reviewModeMore => 'More modes';

  @override
  String get reviewModeSheetTitle => 'Choose review mode';

  @override
  String get noFilesForMode => 'No files found for this review mode.';

  @override
  String get exactDuplicateGroups => 'Exact duplicate groups';

  @override
  String exactCopies(int count) {
    return '$count exact copies';
  }

  @override
  String recoverableStorage(String size) {
    return '$size recoverable';
  }

  @override
  String get reviewGroup => 'Review group';

  @override
  String reviewGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get compareGroup => 'Compare group';

  @override
  String get comparePhotos => 'Compare photos';

  @override
  String get compareShots => 'Compare shots';

  @override
  String groupComparePosition(int index, int count) {
    return '$index of $count';
  }

  @override
  String get dismissGroup => 'Dismiss group';

  @override
  String get groupDismissed => 'Group dismissed.';

  @override
  String get noDuplicateGroups => 'No exact duplicate groups found.';

  @override
  String get photoBursts => 'Photo bursts';

  @override
  String burstShots(int count) {
    return '$count shots';
  }

  @override
  String burstSpan(int seconds) {
    return '${seconds}s span';
  }

  @override
  String burstTotalStorage(String size) {
    return '$size total';
  }

  @override
  String groupTotalStorage(String size) {
    return '$size total';
  }

  @override
  String get reviewBurst => 'Review burst';

  @override
  String get noBurstGroups => 'No photo bursts found.';

  @override
  String get leaveReview => 'Leave review?';

  @override
  String get leaveReviewMessage =>
      'You can save your progress or discard all changes.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get discardAndExit => 'Discard & Exit';

  @override
  String get skipForLater => 'Skip for later';

  @override
  String get neverAskAgain => 'Never ask again';

  @override
  String reviewProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String filesMarkedForDeletion(int count) {
    return 'Delete $count';
  }

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get download => 'Download';

  @override
  String get openPreview => 'Open preview';

  @override
  String duplicateCandidate(int index, int count) {
    return 'Duplicate $index of $count';
  }

  @override
  String get duplicateCandidateHelp =>
      'Same content fingerprint and size. Review each copy; Epura will not delete automatically.';

  @override
  String burstCandidate(int index, int count) {
    return 'Burst $index of $count';
  }

  @override
  String get burstCandidateHelp =>
      'Taken close together. Review each shot; Epura will not choose a best photo automatically.';

  @override
  String get delete => 'Delete';

  @override
  String get keep => 'Keep';

  @override
  String get allDone => 'All done!';

  @override
  String get kept => 'Kept';

  @override
  String get deleted => 'Deleted';

  @override
  String get skipped => 'Skipped';

  @override
  String get storageFreed => 'Storage freed';

  @override
  String get motivationalMessage => 'Great job keeping your device clean!';

  @override
  String get reviewPromptTitle => 'Enjoying Epura?';

  @override
  String get reviewPromptBody =>
      'A Play Store rating helps more people find a private cleanup app. Epura will only ask after successful sessions.';

  @override
  String get rateEpura => 'Rate Epura';

  @override
  String get notNow => 'Not now';

  @override
  String get viewStats => 'View Stats';

  @override
  String get goHome => 'Go Home';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyCleanupReminder => 'Daily cleanup reminder';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get fileTypesToScan => 'File types to scan';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get totalStorageFreed => 'Total storage freed';

  @override
  String get freedThisWeek => 'Freed this week';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get streak => 'Streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get filesReviewed => 'Files reviewed';

  @override
  String get totalReviewed => 'Total reviewed';

  @override
  String get sessions => 'Sessions';

  @override
  String get sessionHistory => 'Session history';

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String filesReviewedCount(int count) {
    return '$count files reviewed';
  }

  @override
  String get monthlyReviewProgress => 'This month\'s review progress';

  @override
  String get storageFreedThisMonth => 'Storage freed this month';

  @override
  String get storageInsightTitle => 'Storage insight';

  @override
  String get storageInsightStatsEntryBody =>
      'See what Epura can review and what Android manages.';

  @override
  String get storageInsightEpuraCanReview => 'Epura can review';

  @override
  String get storageInsightEpuraCanReviewBody =>
      'This is only storage from your scan choices: photos, videos, selected folders, and files you import.';

  @override
  String storageInsightFilesAvailable(int count) {
    return '$count files in scope';
  }

  @override
  String get storageInsightAlreadyFreed => 'Already freed';

  @override
  String get storageInsightPhotosVideos => 'Photos and videos';

  @override
  String get storageInsightGuideTitle => 'What is taking space?';

  @override
  String get storageInsightPhotosVideosBody =>
      'Media usually grows fastest. Epura can help you review the photos and videos Android allows it to see.';

  @override
  String get storageInsightDownloadsBody =>
      'Imported downloads and selected folders stay local and are only reviewed after you choose them.';

  @override
  String get storageInsightAppCache => 'App cache';

  @override
  String get storageInsightAppCacheBody =>
      'Android manages other apps\' caches. Epura does not clear them or inspect your installed apps.';

  @override
  String get storageInsightCloudCopies => 'Cloud copies';

  @override
  String get storageInsightCloudCopiesBody =>
      'A file can look backed up while still using device storage. Check the original app before deleting anything important.';

  @override
  String get storageInsightSystemStorage => 'System storage';

  @override
  String get storageInsightSystemStorageBody =>
      'System files and hidden app data belong in Android settings, not in Epura\'s review deck.';

  @override
  String get storageInsightPlanTitle => 'Cleanup plan';

  @override
  String get storageInsightPlan2MinuteTitle => '2-minute cleanup';

  @override
  String get storageInsightPlan2MinuteBody =>
      'Review recent screenshots and obvious one-off images.';

  @override
  String get storageInsightPlan5MinuteTitle => '5-minute cleanup';

  @override
  String get storageInsightPlan5MinuteBody =>
      'Review large videos and exact duplicate groups first.';

  @override
  String get storageInsightPlanWeeklyTitle => 'Weekly cleanup';

  @override
  String get storageInsightPlanWeeklyBody =>
      'Review new files since your last session before the queue grows.';

  @override
  String get storageInsightPlanMonthlyTitle => 'Monthly cleanup';

  @override
  String get storageInsightPlanMonthlyBody =>
      'Import downloaded files or rescan selected folders you no longer trust.';

  @override
  String get openAndroidStorageSettings => 'Open Android storage settings';

  @override
  String get androidStorageSettingsUnavailable =>
      'Android storage settings are not available on this device.';

  @override
  String get allClean => 'All clean!';

  @override
  String get noFilesToReview =>
      'No files to review right now. Check back later.';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get howFarBack => 'How far back?';

  @override
  String get sinceLastReview => 'Since last review';

  @override
  String nDays(int count) {
    return '$count days';
  }

  @override
  String get oneDay => '1 day';

  @override
  String get cleanupReminder => 'Cleanup reminder';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get forever => 'Forever';

  @override
  String get help => 'Help';

  @override
  String get helpWhatIsEpura => 'What is Epura?';

  @override
  String get helpWhatIsEpuraBody =>
      'Epura helps you review and clean up photos, videos, files from folders you explicitly select, and downloaded files you manually import.';

  @override
  String get helpHowItWorks => 'How it works';

  @override
  String get helpHowItWorksBody =>
      'Swipe right to keep a file, left to delete it, or tap \"Skip\" to decide later. Photos and videos are scanned automatically, selected folders are rescanned with your permission, and downloaded files can be imported into the same review deck.';

  @override
  String get helpNotifications => 'Notifications';

  @override
  String get helpNotificationsBody =>
      'Turn on reminders to get notified daily or weekly to clean up your storage.';

  @override
  String get helpLookback => 'Lookback';

  @override
  String get helpLookbackBody =>
      'When you start a review, choose how far back to look — from 1 day to forever.';

  @override
  String get helpStats => 'Stats';

  @override
  String get helpStatsBody =>
      'See how much storage you\'ve freed and track your cleanup streak.';

  @override
  String get preparingReview => 'Preparing review';

  @override
  String get filesScanned => 'files scanned';

  @override
  String get scanningPhotosAndVideos => 'Scanning photos & videos...';

  @override
  String get scanningCustomFolders => 'Scanning selected folders...';

  @override
  String get cleaningUp => 'Cleaning up...';

  @override
  String filesRemovalProgress(int done, int total) {
    return '$done / $total files processed';
  }

  @override
  String get loadingStats => 'Loading stats...';

  @override
  String get startingReview => 'Starting review...';

  @override
  String get scanning => 'Scanning...';

  @override
  String get addDownloadedFiles => 'Add downloaded files';

  @override
  String get downloadsInboxTitle => 'Downloads inbox';

  @override
  String downloadsInboxSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files imported - $size',
      one: '1 file imported - $size',
    );
    return '$_temp0';
  }

  @override
  String get downloadsInboxBody =>
      'Android asks you to choose downloads manually. Epura only reviews files you picked.';

  @override
  String get reviewDownloads => 'Review downloads';

  @override
  String get filterDownloads => 'Filter';

  @override
  String get downloadFilterTitle => 'Review downloads by type';

  @override
  String get downloadFilterAll => 'All downloads';

  @override
  String get downloadFilterPdfs => 'PDFs';

  @override
  String get downloadFilterArchives => 'Archives';

  @override
  String get downloadFilterApks => 'APKs';

  @override
  String get downloadFilterAudio => 'Audio';

  @override
  String get downloadFilterDocuments => 'Documents';

  @override
  String get downloadFilterOther => 'Other';

  @override
  String downloadFilterOption(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get addMoreDownloads => 'Add more';

  @override
  String clearImportedFiles(int count) {
    return 'Clear imported files ($count)';
  }

  @override
  String importedFilesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files added to your review queue.',
      one: '1 file added to your review queue.',
    );
    return '$_temp0';
  }

  @override
  String get importedFilesCleared =>
      'Imported files cleared from the review queue.';

  @override
  String get customFoldersToScan => 'Custom folders to scan';

  @override
  String get addCustomFolder => 'Add folder';

  @override
  String get customFoldersHelp =>
      'Choose folders you want Epura to rescan automatically. Access is limited to folders you explicitly select.';

  @override
  String get renameFolder => 'Rename folder';

  @override
  String get folderNickname => 'Folder nickname';

  @override
  String folderLastReviewed(String date) {
    return 'Last reviewed $date';
  }

  @override
  String get noCustomFolders =>
      'No custom folders selected. By default, Epura only scans photos and videos.';

  @override
  String folderAdded(String name) {
    return '$name added to folder scans.';
  }

  @override
  String folderRemoved(String name) {
    return '$name removed from folder scans.';
  }

  @override
  String get downloadFolderSelectionHint =>
      'Android 11+ does not allow apps to select the Downloads folder as a reusable folder grant. Use \"Add downloaded files\" on the home screen for Downloads instead.';

  @override
  String filesCouldNotBeDeleted(int count) {
    return '$count files could not be deleted and were kept on your device.';
  }

  @override
  String filesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count files moved to Android Trash. You may be able to restore them from your gallery until Android removes trash.',
      one:
          '1 file moved to Android Trash. You may be able to restore it from your gallery until Android removes trash.',
    );
    return '$_temp0';
  }

  @override
  String filesPermanentlyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were permanently deleted.',
      one: '1 file was permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get trashStorageFreedNote =>
      'Storage freed only counts permanently deleted files. Trashed media may still use storage until the trash is emptied.';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get viewOnline => 'View online';

  @override
  String get privacyAndControl => 'Privacy and control';

  @override
  String get privacyPermissions => 'Privacy and permissions';

  @override
  String get privacyPermissionsSubtitle =>
      'See what Epura can access and clear local history.';

  @override
  String get privacyReceipt => 'Privacy receipt';

  @override
  String get noAccount => 'No account';

  @override
  String get noCloudSync => 'No cloud sync';

  @override
  String get noAnalyticsTracking => 'No analytics or tracking';

  @override
  String get localOnlyProcessing => 'All processing stays on this device';

  @override
  String get permissionsEpuraUses => 'Permissions Epura uses';

  @override
  String get mediaPermissionTitle => 'Photos and videos';

  @override
  String get mediaPermissionBody =>
      'Used only to show selected media in your review deck.';

  @override
  String get selectedFoldersPermissionTitle => 'Selected folders and files';

  @override
  String get selectedFoldersPermissionBody =>
      'Used only for folders or downloaded files you choose through the Android picker.';

  @override
  String get notificationsPermissionTitle => 'Notifications';

  @override
  String get notificationsPermissionBody =>
      'Used only for reminders you turn on.';

  @override
  String get currentLocalAccess => 'Current local access';

  @override
  String get selectedFolders => 'Selected folders';

  @override
  String get noneSelected => 'None selected';

  @override
  String selectedFolderCount(int count) {
    return '$count selected';
  }

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get localHistory => 'Local history';

  @override
  String get noLocalReviewHistory => 'No local review history';

  @override
  String localReviewSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local review sessions',
      one: '1 local review session',
    );
    return '$_temp0';
  }

  @override
  String get clearHistoryExplanation =>
      'This clears Epura\'s review stats, last-review marker, skipped-file queue, never-ask-again decisions, dismissed group suggestions, and local file index. It does not delete files, revoke selected folders, or change your scan settings.';

  @override
  String get clearEpuraHistory => 'Clear Epura history';

  @override
  String get clearHistoryTitle => 'Clear local history?';

  @override
  String get clearHistoryMessage =>
      'Epura will clear review sessions, stats, the last-review marker, skipped-file queue, never-ask-again decisions, dismissed group suggestions, and local file index. Your files and selected folders will stay unchanged.';

  @override
  String get clearHistoryConfirm => 'Clear history';

  @override
  String get historyClearedMessage =>
      'Epura history cleared. Your files were not changed.';

  @override
  String get welcomeToEpura => 'Welcome to Epura';

  @override
  String get termsBottomSheetSummary =>
      'Epura works entirely on your device. No data is collected, transmitted, or shared. By continuing, you agree to our Privacy Policy and Terms of Service.';

  @override
  String get accept => 'Accept';

  @override
  String get readPrivacyPolicy => 'Read Privacy Policy';

  @override
  String get readTermsOfService => 'Read Terms of Service';

  @override
  String get privacyPolicyLastUpdated => 'Last updated: April 13, 2026';

  @override
  String get privacyPolicyIntro =>
      'Epura does not collect, transmit, or share any personal data.';

  @override
  String get privacyPolicyAccess =>
      'The app requests access only to your device\'s media library and the folders or files you explicitly select through the Android system picker. Files are only deleted when you explicitly choose to delete them inside Epura.';

  @override
  String get privacyPolicyNoData =>
      'No data leaves your device. No analytics, no tracking, no accounts required.';

  @override
  String get privacyPolicyPermissions => 'Permissions';

  @override
  String get privacyPolicyPermMedia =>
      'READ_MEDIA_IMAGES / READ_MEDIA_VIDEO: Used to display your photos and videos for review.';

  @override
  String get privacyPolicyPermStorage =>
      'Storage Access Framework grants: Used only for custom folders and downloaded files you explicitly select through the system file picker.';

  @override
  String get privacyPolicyPermNotif =>
      'POST_NOTIFICATIONS: Used to send periodic reminders.';

  @override
  String get privacyPolicyPermAlarm =>
      'SCHEDULE_EXACT_ALARM / RECEIVE_BOOT_COMPLETED: Used to deliver reminders at chosen times.';

  @override
  String get tosLastUpdated => 'Last updated: March 20, 2026';

  @override
  String get tosIntro => 'By using Epura, you agree to the following terms.';

  @override
  String get tosLocalOnly =>
      'Epura operates entirely on your device. No account is required and no data is transmitted.';

  @override
  String get tosDeletion =>
      'When you choose to delete a file, it is permanently removed from your device. Epura is not responsible for any data loss resulting from your decisions.';

  @override
  String get tosNoWarranty =>
      'Epura is provided \"as is\" without warranty of any kind.';

  @override
  String get tosChanges =>
      'These terms may be updated from time to time. Continued use of the app constitutes acceptance of any changes.';
}
