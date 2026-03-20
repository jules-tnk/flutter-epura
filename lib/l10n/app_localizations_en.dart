// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'epura';

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
  String get leaveReview => 'Leave review?';

  @override
  String get leaveReviewMessage =>
      'You can save your progress or discard all changes.';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get discardAndExit => 'Discard & Exit';

  @override
  String get skipForLater => 'Skip for later';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get download => 'Download';

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
  String get sessionHistory => 'Session history';

  @override
  String filesReviewedCount(int count) {
    return '$count files reviewed';
  }

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
      'Epura helps you review and clean up photos, videos, and downloads on your phone.';

  @override
  String get helpHowItWorks => 'How it works';

  @override
  String get helpHowItWorksBody =>
      'Swipe right to keep a file, left to delete it, or tap \"Skip\" to decide later.';

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
  String get scanningDownloads => 'Scanning downloads...';

  @override
  String get cleaningUp => 'Cleaning up...';

  @override
  String filesDeletedProgress(int done, int total) {
    return '$done / $total files deleted';
  }

  @override
  String get loadingStats => 'Loading stats...';

  @override
  String get startingReview => 'Starting review...';

  @override
  String get scanning => 'Scanning...';

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
  String get privacyPolicyLastUpdated => 'Last updated: March 11, 2026';

  @override
  String get privacyPolicyIntro =>
      'Epura does not collect, transmit, or share any personal data.';

  @override
  String get privacyPolicyAccess =>
      'The app requests access to your device\'s media files (photos, videos) and downloads folder solely to display them within the app for your review. Files are only deleted when you explicitly choose to delete them.';

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
      'MANAGE_EXTERNAL_STORAGE: Used to access your Downloads folder for review.';

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
