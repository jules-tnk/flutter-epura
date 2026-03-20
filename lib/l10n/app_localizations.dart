import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'epura'**
  String get appTitle;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to clean up!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have new files to review'**
  String get notificationBody;

  /// No description provided for @storageAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Storage access needed'**
  String get storageAccessNeeded;

  /// No description provided for @storageAccessExplanation.
  ///
  /// In en, this message translates to:
  /// **'Epura needs permission to access your files so you can review them.'**
  String get storageAccessExplanation;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get grantAccess;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @filesToReview.
  ///
  /// In en, this message translates to:
  /// **'{count} files to review'**
  String filesToReview(int count);

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get startReview;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave review?'**
  String get leaveReview;

  /// No description provided for @leaveReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'You can save your progress or discard all changes.'**
  String get leaveReviewMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// No description provided for @discardAndExit.
  ///
  /// In en, this message translates to:
  /// **'Discard & Exit'**
  String get discardAndExit;

  /// No description provided for @skipForLater.
  ///
  /// In en, this message translates to:
  /// **'Skip for later'**
  String get skipForLater;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get allDone;

  /// No description provided for @kept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get kept;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @storageFreed.
  ///
  /// In en, this message translates to:
  /// **'Storage freed'**
  String get storageFreed;

  /// No description provided for @motivationalMessage.
  ///
  /// In en, this message translates to:
  /// **'Great job keeping your device clean!'**
  String get motivationalMessage;

  /// No description provided for @viewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dailyCleanupReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily cleanup reminder'**
  String get dailyCleanupReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @fileTypesToScan.
  ///
  /// In en, this message translates to:
  /// **'File types to scan'**
  String get fileTypesToScan;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @totalStorageFreed.
  ///
  /// In en, this message translates to:
  /// **'Total storage freed'**
  String get totalStorageFreed;

  /// No description provided for @freedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Freed this week'**
  String get freedThisWeek;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @filesReviewed.
  ///
  /// In en, this message translates to:
  /// **'Files reviewed'**
  String get filesReviewed;

  /// No description provided for @totalReviewed.
  ///
  /// In en, this message translates to:
  /// **'Total reviewed'**
  String get totalReviewed;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @filesReviewedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files reviewed'**
  String filesReviewedCount(int count);

  /// No description provided for @allClean.
  ///
  /// In en, this message translates to:
  /// **'All clean!'**
  String get allClean;

  /// No description provided for @noFilesToReview.
  ///
  /// In en, this message translates to:
  /// **'No files to review right now. Check back later.'**
  String get noFilesToReview;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @howFarBack.
  ///
  /// In en, this message translates to:
  /// **'How far back?'**
  String get howFarBack;

  /// No description provided for @sinceLastReview.
  ///
  /// In en, this message translates to:
  /// **'Since last review'**
  String get sinceLastReview;

  /// No description provided for @nDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String nDays(int count);

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// No description provided for @cleanupReminder.
  ///
  /// In en, this message translates to:
  /// **'Cleanup reminder'**
  String get cleanupReminder;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @forever.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get forever;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpWhatIsEpura.
  ///
  /// In en, this message translates to:
  /// **'What is Epura?'**
  String get helpWhatIsEpura;

  /// No description provided for @helpWhatIsEpuraBody.
  ///
  /// In en, this message translates to:
  /// **'Epura helps you review and clean up photos, videos, and downloads on your phone.'**
  String get helpWhatIsEpuraBody;

  /// No description provided for @helpHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get helpHowItWorks;

  /// No description provided for @helpHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to keep a file, left to delete it, or tap \"Skip\" to decide later.'**
  String get helpHowItWorksBody;

  /// No description provided for @helpNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get helpNotifications;

  /// No description provided for @helpNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders to get notified daily or weekly to clean up your storage.'**
  String get helpNotificationsBody;

  /// No description provided for @helpLookback.
  ///
  /// In en, this message translates to:
  /// **'Lookback'**
  String get helpLookback;

  /// No description provided for @helpLookbackBody.
  ///
  /// In en, this message translates to:
  /// **'When you start a review, choose how far back to look — from 1 day to forever.'**
  String get helpLookbackBody;

  /// No description provided for @helpStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get helpStats;

  /// No description provided for @helpStatsBody.
  ///
  /// In en, this message translates to:
  /// **'See how much storage you\'ve freed and track your cleanup streak.'**
  String get helpStatsBody;

  /// No description provided for @preparingReview.
  ///
  /// In en, this message translates to:
  /// **'Preparing review'**
  String get preparingReview;

  /// No description provided for @filesScanned.
  ///
  /// In en, this message translates to:
  /// **'files scanned'**
  String get filesScanned;

  /// No description provided for @scanningPhotosAndVideos.
  ///
  /// In en, this message translates to:
  /// **'Scanning photos & videos...'**
  String get scanningPhotosAndVideos;

  /// No description provided for @scanningDownloads.
  ///
  /// In en, this message translates to:
  /// **'Scanning downloads...'**
  String get scanningDownloads;

  /// No description provided for @cleaningUp.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up...'**
  String get cleaningUp;

  /// No description provided for @filesDeletedProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} files deleted'**
  String filesDeletedProgress(int done, int total);

  /// No description provided for @loadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading stats...'**
  String get loadingStats;

  /// No description provided for @startingReview.
  ///
  /// In en, this message translates to:
  /// **'Starting review...'**
  String get startingReview;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @viewOnline.
  ///
  /// In en, this message translates to:
  /// **'View online'**
  String get viewOnline;

  /// No description provided for @welcomeToEpura.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Epura'**
  String get welcomeToEpura;

  /// No description provided for @termsBottomSheetSummary.
  ///
  /// In en, this message translates to:
  /// **'Epura works entirely on your device. No data is collected, transmitted, or shared. By continuing, you agree to our Privacy Policy and Terms of Service.'**
  String get termsBottomSheetSummary;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read Privacy Policy'**
  String get readPrivacyPolicy;

  /// No description provided for @readTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Read Terms of Service'**
  String get readTermsOfService;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 11, 2026'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Epura does not collect, transmit, or share any personal data.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyAccess.
  ///
  /// In en, this message translates to:
  /// **'The app requests access to your device\'s media files (photos, videos) and downloads folder solely to display them within the app for your review. Files are only deleted when you explicitly choose to delete them.'**
  String get privacyPolicyAccess;

  /// No description provided for @privacyPolicyNoData.
  ///
  /// In en, this message translates to:
  /// **'No data leaves your device. No analytics, no tracking, no accounts required.'**
  String get privacyPolicyNoData;

  /// No description provided for @privacyPolicyPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get privacyPolicyPermissions;

  /// No description provided for @privacyPolicyPermMedia.
  ///
  /// In en, this message translates to:
  /// **'READ_MEDIA_IMAGES / READ_MEDIA_VIDEO: Used to display your photos and videos for review.'**
  String get privacyPolicyPermMedia;

  /// No description provided for @privacyPolicyPermStorage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE_EXTERNAL_STORAGE: Used to access your Downloads folder for review.'**
  String get privacyPolicyPermStorage;

  /// No description provided for @privacyPolicyPermNotif.
  ///
  /// In en, this message translates to:
  /// **'POST_NOTIFICATIONS: Used to send periodic reminders.'**
  String get privacyPolicyPermNotif;

  /// No description provided for @privacyPolicyPermAlarm.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE_EXACT_ALARM / RECEIVE_BOOT_COMPLETED: Used to deliver reminders at chosen times.'**
  String get privacyPolicyPermAlarm;

  /// No description provided for @tosLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 20, 2026'**
  String get tosLastUpdated;

  /// No description provided for @tosIntro.
  ///
  /// In en, this message translates to:
  /// **'By using Epura, you agree to the following terms.'**
  String get tosIntro;

  /// No description provided for @tosLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Epura operates entirely on your device. No account is required and no data is transmitted.'**
  String get tosLocalOnly;

  /// No description provided for @tosDeletion.
  ///
  /// In en, this message translates to:
  /// **'When you choose to delete a file, it is permanently removed from your device. Epura is not responsible for any data loss resulting from your decisions.'**
  String get tosDeletion;

  /// No description provided for @tosNoWarranty.
  ///
  /// In en, this message translates to:
  /// **'Epura is provided \"as is\" without warranty of any kind.'**
  String get tosNoWarranty;

  /// No description provided for @tosChanges.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated from time to time. Continued use of the app constitutes acceptance of any changes.'**
  String get tosChanges;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
