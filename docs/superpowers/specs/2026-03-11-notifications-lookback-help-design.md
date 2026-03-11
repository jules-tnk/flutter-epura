# Notification Fix, Unified Notifications, Forever Lookback & Help Section — Design Spec

## Problem

1. **Notifications never appear** on Android despite `POST_NOTIFICATIONS` being granted. Root cause: `NotificationService.init()` never calls `createNotificationChannel()`. Android 8+ silently drops notifications posted to unregistered channels.
2. **No periodic alarm option** — users can only set a daily reminder but want configurable intervals (daily or weekly with day-of-week selection).
3. **No "Forever" lookback** — the lookback picker only offers fixed day ranges (1–30 days) and "since last review". Users want to review all files on the device.
4. **No in-app help** — confused users have no way to learn what the app does or how to use it.

## Design

### Part 1: Fix notification channel (bug fix)

**File:** `lib/services/notification_service.dart`

In `init()`, after `_plugin.initialize()`, resolve `AndroidFlutterLocalNotificationsPlugin` and call `createNotificationChannel()` for channel `'epura_reminders'` with `Importance.high`. This is a one-line fix that unblocks all scheduled notifications on Android 8+.

### Part 2: Unified Notifications

The existing "daily reminder" and the new periodic alarm concept are merged into one **Notifications** feature. Users configure one notification schedule with three parameters: interval (daily/weekly), time of day, and day of week (when weekly).

#### NotificationService (`lib/services/notification_service.dart`)

- Replace `scheduleDailyReminder(TimeOfDay time)` with `scheduleReminder(TimeOfDay time, String interval, int dayOfWeek)`.
- `interval = 'daily'`: use `zonedSchedule` with `DateTimeComponents.time` (same behavior as today).
- `interval = 'weekly'`: compute `scheduledDate` advanced to the next matching `dayOfWeek`, then use `zonedSchedule` with `DateTimeComponents.dayOfWeekAndTime`.
- Rename `_channelName` from `'Daily Reminders'` to `'Cleanup Reminders'` to be interval-agnostic.
- Single channel `'epura_reminders'` for both intervals.
- `cancelReminder()` unchanged.

#### SettingsProvider (`lib/providers/settings_provider.dart`)

- New persisted fields: `_notificationInterval` (String, default `'daily'`), `_notificationDayOfWeek` (int, default `DateTime.monday`).
- New SharedPreferences keys: `_keyNotificationInterval`, `_keyNotificationDayOfWeek`.
- New setters: `setNotificationInterval(String)`, `setNotificationDayOfWeek(int)` — both reschedule if notifications are currently enabled.
- All existing schedule-triggering methods (`applyNotificationPermissionResult`, `setNotificationsEnabled`, `setReminderTime`) updated to call `scheduleReminder(time, interval, dayOfWeek)` instead of `scheduleDailyReminder(time)`.
- Fix pre-existing bug: `setReminderTime` must guard scheduling with `if (_notificationsEnabled)` — currently it schedules unconditionally even when notifications are disabled.

#### SettingsScreen (`lib/screens/settings_screen.dart`)

Notifications section becomes (all items visible only when toggle is on):
1. On/off toggle (existing `SwitchListTile`), subtitle changed from `l.dailyCleanupReminder` to `l.cleanupReminder`
2. Interval selector: Daily / Weekly using `SegmentedButton` or `ChoiceChip` row
3. Day-of-week chips Mon–Sun (visible only when interval = weekly)
4. Time picker (existing `ListTile` with `showTimePicker`)

### Part 3: "Forever" in LookbackPicker

**File:** `lib/widgets/lookback_picker.dart`

#### Approach: sentinel date

`FileService.scanForNewFiles(since: null)` falls back to `settings.lastReviewTimestamp` via `since ??= settings.lastReviewTimestamp`, so passing `null` does NOT mean "all files." To avoid modifying FileService, "Forever" uses a sentinel date `DateTime(1970)` — every file on the device will be newer than 1970, so all files pass the filter.

#### LookbackResult class

```dart
class LookbackResult {
  static final DateTime _kForever = DateTime(1970);

  final DateTime since;
  const LookbackResult({required this.since});
  LookbackResult.forever() : since = _kForever;

  bool get isForever => since.year == 1970;
}
```

- `LookbackPicker.show()` return type changes from `Future<DateTime?>` to `Future<LookbackResult?>`.
- `null` return = user dismissed the sheet (no action taken).
- `LookbackResult.forever()` = all files.
- `LookbackResult(since: someDate)` = specific cutoff date.

#### Widget changes

- Add a "Forever" `_PickerChip` alongside the existing day chips.
- New state: `_forever = false`. When selected, sets `_sinceLastReview = false`, `_selectedDays = null`, `_forever = true`.
- `_computeCutoff()` returns `DateTime(1970)` when `_forever` is true.
- `Navigator.pop(context, LookbackResult(since: _computeCutoff()))` for all cases; `LookbackResult.forever()` when `_forever` is true.

#### HomeScreen (`lib/screens/home_screen.dart`)

- Update `Start Review` handler to work with `LookbackResult`:
  ```dart
  final result = await LookbackPicker.show(context, ...);
  if (result == null || !mounted) return; // dismissed
  await fs.scanForNewFiles(settings, since: result.since); // DateTime(1970) = all files
  ```
- The initial `_scanFiles()` call (line 40) does not use the picker and is unaffected.
- No changes needed in `FileService` — the sentinel date bypasses the filter naturally.

### Part 4: Help section in Settings

**File:** `lib/screens/settings_screen.dart`

After the About section, add a `Divider()`, then a `ListTile` with `Icons.help_outline` as leading icon and `l.help` as title. Tapping it opens a `showModalBottomSheet` with scrollable content containing 5 short sections:

1. **What is Epura?** — Epura helps you review and clean up photos, videos, and downloads on your phone.
2. **How it works** — Swipe right to keep a file, left to delete it, or tap "Skip" to decide later.
3. **Notifications** — Turn on reminders to get notified daily or weekly to clean up your storage.
4. **Lookback** — When you start a review, choose how far back to look — from 1 day to forever.
5. **Stats** — See how much storage you've freed and track your cleanup streak.

Simple, jargon-free language. All text localized in EN and FR.

### Part 5: Localization

**Files:** `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

New ARB keys:

| Key | English | French |
|-----|---------|--------|
| `cleanupReminder` | Cleanup reminder | Rappel de nettoyage |
| `daily` | Daily | Quotidien |
| `weekly` | Weekly | Hebdomadaire |
| `monday` | Monday | Lundi |
| `tuesday` | Tuesday | Mardi |
| `wednesday` | Wednesday | Mercredi |
| `thursday` | Thursday | Jeudi |
| `friday` | Friday | Vendredi |
| `saturday` | Saturday | Samedi |
| `sunday` | Sunday | Dimanche |
| `forever` | Forever | Tout |
| `help` | Help | Aide |
| `helpWhatIsEpura` | What is Epura? | Qu'est-ce qu'Epura ? |
| `helpWhatIsEpuraBody` | Epura helps you review and clean up photos, videos, and downloads on your phone. | Epura vous aide à examiner et nettoyer les photos, vidéos et téléchargements sur votre téléphone. |
| `helpHowItWorks` | How it works | Comment ça marche |
| `helpHowItWorksBody` | Swipe right to keep a file, left to delete it, or tap "Skip" to decide later. | Glissez à droite pour garder un fichier, à gauche pour le supprimer, ou appuyez sur « Passer » pour décider plus tard. |
| `helpNotifications` | Notifications | Notifications |
| `helpNotificationsBody` | Turn on reminders to get notified daily or weekly to clean up your storage. | Activez les rappels pour être notifié chaque jour ou chaque semaine de nettoyer votre stockage. |
| `helpLookback` | Lookback | Période de recherche |
| `helpLookbackBody` | When you start a review, choose how far back to look — from 1 day to forever. | Quand vous commencez un examen, choisissez la période — de 1 jour à tout l'historique. |
| `helpStats` | Stats | Statistiques |
| `helpStatsBody` | See how much storage you've freed and track your cleanup streak. | Voyez combien d'espace vous avez libéré et suivez votre série de nettoyage. |

Run `flutter gen-l10n` after updating ARB files.

## Files to modify

1. `lib/services/notification_service.dart` — channel creation + unified `scheduleReminder`
2. `lib/providers/settings_provider.dart` — new interval/day fields + updated scheduling calls
3. `lib/screens/settings_screen.dart` — unified notification UI + help section
4. `lib/widgets/lookback_picker.dart` — `LookbackResult` class + "Forever" chip
5. `lib/screens/home_screen.dart` — adapt to `LookbackResult` return type
6. `lib/l10n/app_en.arb` — new English strings
7. `lib/l10n/app_fr.arb` — new French strings

## Verification

1. `flutter analyze` — no errors
2. `flutter gen-l10n` — regenerates localization files successfully
3. `flutter build apk` — builds without errors
4. Manual: enable notifications → verify Android system shows the `epura_reminders` channel → notification fires at scheduled time
5. Manual: set weekly interval + pick a day → notification fires on the correct day
6. Manual: start review → pick "Forever" → all files on device are scanned
7. Manual: open Help from settings → content displays correctly in both EN and FR
