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
  /// **'Epura'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @localOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnlyBadge;

  /// No description provided for @takeControlOfSpace.
  ///
  /// In en, this message translates to:
  /// **'Take control of your space'**
  String get takeControlOfSpace;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisSession.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get thisSession;

  /// No description provided for @daysInARow.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get daysInARow;

  /// No description provided for @readyToReview.
  ///
  /// In en, this message translates to:
  /// **'Ready to review'**
  String get readyToReview;

  /// No description provided for @reviewModesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review mode available} other{{count} review modes available}}'**
  String reviewModesAvailable(int count);

  /// No description provided for @resumeReview.
  ///
  /// In en, this message translates to:
  /// **'Resume review'**
  String get resumeReview;

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

  /// No description provided for @reviewModes.
  ///
  /// In en, this message translates to:
  /// **'Review modes'**
  String get reviewModes;

  /// No description provided for @reviewModeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get reviewModeRecent;

  /// No description provided for @reviewModeLargestFiles.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get reviewModeLargestFiles;

  /// No description provided for @reviewModeScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get reviewModeScreenshots;

  /// No description provided for @reviewModeLargeVideos.
  ///
  /// In en, this message translates to:
  /// **'Large videos'**
  String get reviewModeLargeVideos;

  /// No description provided for @reviewModeBursts.
  ///
  /// In en, this message translates to:
  /// **'Bursts'**
  String get reviewModeBursts;

  /// No description provided for @reviewModeDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get reviewModeDownloads;

  /// No description provided for @reviewModeSelectedFolders.
  ///
  /// In en, this message translates to:
  /// **'Selected folders'**
  String get reviewModeSelectedFolders;

  /// No description provided for @reviewModeFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder: {name}'**
  String reviewModeFolder(String name);

  /// No description provided for @reviewModeDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get reviewModeDuplicates;

  /// No description provided for @reviewModeSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get reviewModeSkipped;

  /// No description provided for @reviewModeMore.
  ///
  /// In en, this message translates to:
  /// **'More modes'**
  String get reviewModeMore;

  /// No description provided for @reviewModeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose review mode'**
  String get reviewModeSheetTitle;

  /// No description provided for @noFilesForMode.
  ///
  /// In en, this message translates to:
  /// **'No files found for this review mode.'**
  String get noFilesForMode;

  /// No description provided for @exactDuplicateGroups.
  ///
  /// In en, this message translates to:
  /// **'Exact duplicate groups'**
  String get exactDuplicateGroups;

  /// No description provided for @exactCopies.
  ///
  /// In en, this message translates to:
  /// **'{count} exact copies'**
  String exactCopies(int count);

  /// No description provided for @recoverableStorage.
  ///
  /// In en, this message translates to:
  /// **'{size} recoverable'**
  String recoverableStorage(String size);

  /// No description provided for @reviewGroup.
  ///
  /// In en, this message translates to:
  /// **'Review group'**
  String get reviewGroup;

  /// No description provided for @reviewGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String reviewGroupCount(int count);

  /// No description provided for @compareGroup.
  ///
  /// In en, this message translates to:
  /// **'Compare group'**
  String get compareGroup;

  /// No description provided for @comparePhotos.
  ///
  /// In en, this message translates to:
  /// **'Compare photos'**
  String get comparePhotos;

  /// No description provided for @compareShots.
  ///
  /// In en, this message translates to:
  /// **'Compare shots'**
  String get compareShots;

  /// No description provided for @groupComparePosition.
  ///
  /// In en, this message translates to:
  /// **'{index} of {count}'**
  String groupComparePosition(int index, int count);

  /// No description provided for @dismissGroup.
  ///
  /// In en, this message translates to:
  /// **'Dismiss group'**
  String get dismissGroup;

  /// No description provided for @groupDismissed.
  ///
  /// In en, this message translates to:
  /// **'Group dismissed.'**
  String get groupDismissed;

  /// No description provided for @noDuplicateGroups.
  ///
  /// In en, this message translates to:
  /// **'No exact duplicate groups found.'**
  String get noDuplicateGroups;

  /// No description provided for @photoBursts.
  ///
  /// In en, this message translates to:
  /// **'Photo bursts'**
  String get photoBursts;

  /// No description provided for @burstShots.
  ///
  /// In en, this message translates to:
  /// **'{count} shots'**
  String burstShots(int count);

  /// No description provided for @burstSpan.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s span'**
  String burstSpan(int seconds);

  /// No description provided for @burstTotalStorage.
  ///
  /// In en, this message translates to:
  /// **'{size} total'**
  String burstTotalStorage(String size);

  /// No description provided for @groupTotalStorage.
  ///
  /// In en, this message translates to:
  /// **'{size} total'**
  String groupTotalStorage(String size);

  /// No description provided for @reviewBurst.
  ///
  /// In en, this message translates to:
  /// **'Review burst'**
  String get reviewBurst;

  /// No description provided for @noBurstGroups.
  ///
  /// In en, this message translates to:
  /// **'No photo bursts found.'**
  String get noBurstGroups;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @neverAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Never ask again'**
  String get neverAskAgain;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String reviewProgress(int current, int total);

  /// No description provided for @filesMarkedForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String filesMarkedForDeletion(int count);

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

  /// No description provided for @openPreview.
  ///
  /// In en, this message translates to:
  /// **'Open preview'**
  String get openPreview;

  /// No description provided for @duplicateCandidate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate {index} of {count}'**
  String duplicateCandidate(int index, int count);

  /// No description provided for @duplicateCandidateHelp.
  ///
  /// In en, this message translates to:
  /// **'Same content fingerprint and size. Review each copy; Epura will not delete automatically.'**
  String get duplicateCandidateHelp;

  /// No description provided for @burstCandidate.
  ///
  /// In en, this message translates to:
  /// **'Burst {index} of {count}'**
  String burstCandidate(int index, int count);

  /// No description provided for @burstCandidateHelp.
  ///
  /// In en, this message translates to:
  /// **'Taken close together. Review each shot; Epura will not choose a best photo automatically.'**
  String get burstCandidateHelp;

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

  /// No description provided for @reviewPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Epura?'**
  String get reviewPromptTitle;

  /// No description provided for @reviewPromptBody.
  ///
  /// In en, this message translates to:
  /// **'A Play Store rating helps more people find a private cleanup app. Epura will only ask after successful sessions.'**
  String get reviewPromptBody;

  /// No description provided for @rateEpura.
  ///
  /// In en, this message translates to:
  /// **'Rate Epura'**
  String get rateEpura;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

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

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @filesReviewedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files reviewed'**
  String filesReviewedCount(int count);

  /// No description provided for @monthlyReviewProgress.
  ///
  /// In en, this message translates to:
  /// **'This month\'s review progress'**
  String get monthlyReviewProgress;

  /// No description provided for @storageFreedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Storage freed this month'**
  String get storageFreedThisMonth;

  /// No description provided for @storageInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage insight'**
  String get storageInsightTitle;

  /// No description provided for @storageInsightStatsEntryBody.
  ///
  /// In en, this message translates to:
  /// **'See what Epura can review and what Android manages.'**
  String get storageInsightStatsEntryBody;

  /// No description provided for @storageInsightEpuraCanReview.
  ///
  /// In en, this message translates to:
  /// **'Epura can review'**
  String get storageInsightEpuraCanReview;

  /// No description provided for @storageInsightEpuraCanReviewBody.
  ///
  /// In en, this message translates to:
  /// **'This is only storage from your scan choices: photos, videos, selected folders, and files you import.'**
  String get storageInsightEpuraCanReviewBody;

  /// No description provided for @storageInsightFilesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} files in scope'**
  String storageInsightFilesAvailable(int count);

  /// No description provided for @storageInsightAlreadyFreed.
  ///
  /// In en, this message translates to:
  /// **'Already freed'**
  String get storageInsightAlreadyFreed;

  /// No description provided for @storageInsightPhotosVideos.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get storageInsightPhotosVideos;

  /// No description provided for @storageInsightGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'What is taking space?'**
  String get storageInsightGuideTitle;

  /// No description provided for @storageInsightPhotosVideosBody.
  ///
  /// In en, this message translates to:
  /// **'Media usually grows fastest. Epura can help you review the photos and videos Android allows it to see.'**
  String get storageInsightPhotosVideosBody;

  /// No description provided for @storageInsightDownloadsBody.
  ///
  /// In en, this message translates to:
  /// **'Imported downloads and selected folders stay local and are only reviewed after you choose them.'**
  String get storageInsightDownloadsBody;

  /// No description provided for @storageInsightAppCache.
  ///
  /// In en, this message translates to:
  /// **'App cache'**
  String get storageInsightAppCache;

  /// No description provided for @storageInsightAppCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Android manages other apps\' caches. Epura does not clear them or inspect your installed apps.'**
  String get storageInsightAppCacheBody;

  /// No description provided for @storageInsightCloudCopies.
  ///
  /// In en, this message translates to:
  /// **'Cloud copies'**
  String get storageInsightCloudCopies;

  /// No description provided for @storageInsightCloudCopiesBody.
  ///
  /// In en, this message translates to:
  /// **'A file can look backed up while still using device storage. Check the original app before deleting anything important.'**
  String get storageInsightCloudCopiesBody;

  /// No description provided for @storageInsightSystemStorage.
  ///
  /// In en, this message translates to:
  /// **'System storage'**
  String get storageInsightSystemStorage;

  /// No description provided for @storageInsightSystemStorageBody.
  ///
  /// In en, this message translates to:
  /// **'System files and hidden app data belong in Android settings, not in Epura\'s review deck.'**
  String get storageInsightSystemStorageBody;

  /// No description provided for @storageInsightPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup plan'**
  String get storageInsightPlanTitle;

  /// No description provided for @storageInsightPlan2MinuteTitle.
  ///
  /// In en, this message translates to:
  /// **'2-minute cleanup'**
  String get storageInsightPlan2MinuteTitle;

  /// No description provided for @storageInsightPlan2MinuteBody.
  ///
  /// In en, this message translates to:
  /// **'Review recent screenshots and obvious one-off images.'**
  String get storageInsightPlan2MinuteBody;

  /// No description provided for @storageInsightPlan5MinuteTitle.
  ///
  /// In en, this message translates to:
  /// **'5-minute cleanup'**
  String get storageInsightPlan5MinuteTitle;

  /// No description provided for @storageInsightPlan5MinuteBody.
  ///
  /// In en, this message translates to:
  /// **'Review large videos and exact duplicate groups first.'**
  String get storageInsightPlan5MinuteBody;

  /// No description provided for @storageInsightPlanWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly cleanup'**
  String get storageInsightPlanWeeklyTitle;

  /// No description provided for @storageInsightPlanWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'Review new files since your last session before the queue grows.'**
  String get storageInsightPlanWeeklyBody;

  /// No description provided for @storageInsightPlanMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly cleanup'**
  String get storageInsightPlanMonthlyTitle;

  /// No description provided for @storageInsightPlanMonthlyBody.
  ///
  /// In en, this message translates to:
  /// **'Import downloaded files or rescan selected folders you no longer trust.'**
  String get storageInsightPlanMonthlyBody;

  /// No description provided for @openAndroidStorageSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Android storage settings'**
  String get openAndroidStorageSettings;

  /// No description provided for @androidStorageSettingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Android storage settings are not available on this device.'**
  String get androidStorageSettingsUnavailable;

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
  /// **'Epura helps you review and clean up photos, videos, files from folders you explicitly select, and downloaded files you manually import.'**
  String get helpWhatIsEpuraBody;

  /// No description provided for @helpHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get helpHowItWorks;

  /// No description provided for @helpHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to keep a file, left to delete it, or tap \"Skip\" to decide later. Photos and videos are scanned automatically, selected folders are rescanned with your permission, and downloaded files can be imported into the same review deck.'**
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

  /// No description provided for @scanningCustomFolders.
  ///
  /// In en, this message translates to:
  /// **'Scanning selected folders...'**
  String get scanningCustomFolders;

  /// No description provided for @cleaningUp.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up...'**
  String get cleaningUp;

  /// No description provided for @filesRemovalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} files processed'**
  String filesRemovalProgress(int done, int total);

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

  /// No description provided for @addDownloadedFiles.
  ///
  /// In en, this message translates to:
  /// **'Add downloaded files'**
  String get addDownloadedFiles;

  /// No description provided for @downloadsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads inbox'**
  String get downloadsInboxTitle;

  /// No description provided for @downloadsInboxSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file imported - {size}} other{{count} files imported - {size}}}'**
  String downloadsInboxSummary(int count, String size);

  /// No description provided for @downloadsInboxBody.
  ///
  /// In en, this message translates to:
  /// **'Android asks you to choose downloads manually. Epura only reviews files you picked.'**
  String get downloadsInboxBody;

  /// No description provided for @reviewDownloads.
  ///
  /// In en, this message translates to:
  /// **'Review downloads'**
  String get reviewDownloads;

  /// No description provided for @filterDownloads.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterDownloads;

  /// No description provided for @downloadFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Review downloads by type'**
  String get downloadFilterTitle;

  /// No description provided for @downloadFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All downloads'**
  String get downloadFilterAll;

  /// No description provided for @downloadFilterPdfs.
  ///
  /// In en, this message translates to:
  /// **'PDFs'**
  String get downloadFilterPdfs;

  /// No description provided for @downloadFilterArchives.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get downloadFilterArchives;

  /// No description provided for @downloadFilterApks.
  ///
  /// In en, this message translates to:
  /// **'APKs'**
  String get downloadFilterApks;

  /// No description provided for @downloadFilterAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get downloadFilterAudio;

  /// No description provided for @downloadFilterDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get downloadFilterDocuments;

  /// No description provided for @downloadFilterOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get downloadFilterOther;

  /// No description provided for @downloadFilterOption.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String downloadFilterOption(String label, int count);

  /// No description provided for @addMoreDownloads.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get addMoreDownloads;

  /// No description provided for @clearImportedFiles.
  ///
  /// In en, this message translates to:
  /// **'Clear imported files ({count})'**
  String clearImportedFiles(int count);

  /// No description provided for @importedFilesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file added to your review queue.} other{{count} files added to your review queue.}}'**
  String importedFilesAdded(int count);

  /// No description provided for @importedFilesCleared.
  ///
  /// In en, this message translates to:
  /// **'Imported files cleared from the review queue.'**
  String get importedFilesCleared;

  /// No description provided for @customFoldersToScan.
  ///
  /// In en, this message translates to:
  /// **'Custom folders to scan'**
  String get customFoldersToScan;

  /// No description provided for @addCustomFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addCustomFolder;

  /// No description provided for @customFoldersHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose folders you want Epura to rescan automatically. Access is limited to folders you explicitly select.'**
  String get customFoldersHelp;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @folderNickname.
  ///
  /// In en, this message translates to:
  /// **'Folder nickname'**
  String get folderNickname;

  /// No description provided for @folderLastReviewed.
  ///
  /// In en, this message translates to:
  /// **'Last reviewed {date}'**
  String folderLastReviewed(String date);

  /// No description provided for @noCustomFolders.
  ///
  /// In en, this message translates to:
  /// **'No custom folders selected. By default, Epura only scans photos and videos.'**
  String get noCustomFolders;

  /// No description provided for @folderAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to folder scans.'**
  String folderAdded(String name);

  /// No description provided for @folderRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from folder scans.'**
  String folderRemoved(String name);

  /// No description provided for @downloadFolderSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Android 11+ does not allow apps to select the Downloads folder as a reusable folder grant. Use \"Add downloaded files\" on the home screen for Downloads instead.'**
  String get downloadFolderSelectionHint;

  /// No description provided for @filesCouldNotBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} files could not be deleted and were kept on your device.'**
  String filesCouldNotBeDeleted(int count);

  /// No description provided for @filesMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file moved to Android Trash. You may be able to restore it from your gallery until Android removes trash.} other{{count} files moved to Android Trash. You may be able to restore them from your gallery until Android removes trash.}}'**
  String filesMovedToTrash(int count);

  /// No description provided for @filesPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file was permanently deleted.} other{{count} files were permanently deleted.}}'**
  String filesPermanentlyDeleted(int count);

  /// No description provided for @trashStorageFreedNote.
  ///
  /// In en, this message translates to:
  /// **'Storage freed only counts permanently deleted files. Trashed media may still use storage until the trash is emptied.'**
  String get trashStorageFreedNote;

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

  /// No description provided for @privacyAndControl.
  ///
  /// In en, this message translates to:
  /// **'Privacy and control'**
  String get privacyAndControl;

  /// No description provided for @privacyPermissions.
  ///
  /// In en, this message translates to:
  /// **'Privacy and permissions'**
  String get privacyPermissions;

  /// No description provided for @privacyPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See what Epura can access and clear local history.'**
  String get privacyPermissionsSubtitle;

  /// No description provided for @privacyReceipt.
  ///
  /// In en, this message translates to:
  /// **'Privacy receipt'**
  String get privacyReceipt;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get noAccount;

  /// No description provided for @noCloudSync.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync'**
  String get noCloudSync;

  /// No description provided for @noAnalyticsTracking.
  ///
  /// In en, this message translates to:
  /// **'No analytics or tracking'**
  String get noAnalyticsTracking;

  /// No description provided for @localOnlyProcessing.
  ///
  /// In en, this message translates to:
  /// **'All processing stays on this device'**
  String get localOnlyProcessing;

  /// No description provided for @permissionsEpuraUses.
  ///
  /// In en, this message translates to:
  /// **'Permissions Epura uses'**
  String get permissionsEpuraUses;

  /// No description provided for @mediaPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get mediaPermissionTitle;

  /// No description provided for @mediaPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Used only to show selected media in your review deck.'**
  String get mediaPermissionBody;

  /// No description provided for @selectedFoldersPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected folders and files'**
  String get selectedFoldersPermissionTitle;

  /// No description provided for @selectedFoldersPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Used only for folders or downloaded files you choose through the Android picker.'**
  String get selectedFoldersPermissionBody;

  /// No description provided for @notificationsPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPermissionTitle;

  /// No description provided for @notificationsPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Used only for reminders you turn on.'**
  String get notificationsPermissionBody;

  /// No description provided for @currentLocalAccess.
  ///
  /// In en, this message translates to:
  /// **'Current local access'**
  String get currentLocalAccess;

  /// No description provided for @selectedFolders.
  ///
  /// In en, this message translates to:
  /// **'Selected folders'**
  String get selectedFolders;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @selectedFolderCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedFolderCount(int count);

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @localHistory.
  ///
  /// In en, this message translates to:
  /// **'Local history'**
  String get localHistory;

  /// No description provided for @noLocalReviewHistory.
  ///
  /// In en, this message translates to:
  /// **'No local review history'**
  String get noLocalReviewHistory;

  /// No description provided for @localReviewSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 local review session} other{{count} local review sessions}}'**
  String localReviewSessionCount(int count);

  /// No description provided for @clearHistoryExplanation.
  ///
  /// In en, this message translates to:
  /// **'This clears Epura\'s review stats, last-review marker, skipped-file queue, never-ask-again decisions, dismissed group suggestions, and local file index. It does not delete files, revoke selected folders, or change your scan settings.'**
  String get clearHistoryExplanation;

  /// No description provided for @clearEpuraHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Epura history'**
  String get clearEpuraHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear local history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Epura will clear review sessions, stats, the last-review marker, skipped-file queue, never-ask-again decisions, dismissed group suggestions, and local file index. Your files and selected folders will stay unchanged.'**
  String get clearHistoryMessage;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistoryConfirm;

  /// No description provided for @historyClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'Epura history cleared. Your files were not changed.'**
  String get historyClearedMessage;

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
  /// **'Last updated: April 13, 2026'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Epura does not collect, transmit, or share any personal data.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyAccess.
  ///
  /// In en, this message translates to:
  /// **'The app requests access only to your device\'s media library and the folders or files you explicitly select through the Android system picker. Files are only deleted when you explicitly choose to delete them inside Epura.'**
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
  /// **'Storage Access Framework grants: Used only for custom folders and downloaded files you explicitly select through the system file picker.'**
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
