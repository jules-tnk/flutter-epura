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
      'Your progress in this session will be lost.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

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
}
