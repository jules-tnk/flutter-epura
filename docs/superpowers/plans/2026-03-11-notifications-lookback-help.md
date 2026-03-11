# Notification Fix, Unified Notifications, Forever Lookback & Help Section — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix silent notification drops, merge daily reminders and alarms into one unified notification feature with daily/weekly interval + day-of-week selection, add a "Forever" lookback option, and add an in-app help section — all localized in EN and FR.

**Architecture:** Fix the missing `createNotificationChannel()` call in `NotificationService.init()`, replace `scheduleDailyReminder` with `scheduleReminder(time, interval, dayOfWeek)`, add new persisted fields to `SettingsProvider`, update `SettingsScreen` with interval/day-of-week UI + help bottom sheet, update `LookbackPicker` with a "Forever" chip using a sentinel date, and add all new strings to both ARB files.

**Tech Stack:** Flutter/Dart, `flutter_local_notifications` v21, `flutter_timezone` v5, `shared_preferences`, `permission_handler`, ARB-based l10n.

**Spec:** `docs/superpowers/specs/2026-03-11-notifications-lookback-help-design.md`

---

## Chunk 1: Localization strings (both ARB files)

All subsequent tasks depend on these strings existing. Adding them first ensures `flutter gen-l10n` produces the getters that other files import.

### Task 1: Add new ARB keys to both locale files

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_fr.arb`

Context: The app uses ARB files for English and French. Generated `AppLocalizations` class provides typed getters. All new UI text added below must exist in both files before any Dart file references them.

- [ ] **Step 1: Add new keys to `app_en.arb`**

Open `lib/l10n/app_en.arb`. Before the closing `}`, add the following entries (after `"oneDay": "1 day"`):

```json
,

  "cleanupReminder": "Cleanup reminder",
  "daily": "Daily",
  "weekly": "Weekly",
  "monday": "Monday",
  "tuesday": "Tuesday",
  "wednesday": "Wednesday",
  "thursday": "Thursday",
  "friday": "Friday",
  "saturday": "Saturday",
  "sunday": "Sunday",
  "forever": "Forever",
  "help": "Help",
  "helpWhatIsEpura": "What is Epura?",
  "helpWhatIsEpuraBody": "Epura helps you review and clean up photos, videos, and downloads on your phone.",
  "helpHowItWorks": "How it works",
  "helpHowItWorksBody": "Swipe right to keep a file, left to delete it, or tap \"Skip\" to decide later.",
  "helpNotifications": "Notifications",
  "helpNotificationsBody": "Turn on reminders to get notified daily or weekly to clean up your storage.",
  "helpLookback": "Lookback",
  "helpLookbackBody": "When you start a review, choose how far back to look — from 1 day to forever.",
  "helpStats": "Stats",
  "helpStatsBody": "See how much storage you've freed and track your cleanup streak."
```

- [ ] **Step 2: Add new keys to `app_fr.arb`**

Open `lib/l10n/app_fr.arb`. Before the closing `}`, add the following entries (after `"oneDay": "1 jour"`):

```json
,

  "cleanupReminder": "Rappel de nettoyage",
  "daily": "Quotidien",
  "weekly": "Hebdomadaire",
  "monday": "Lundi",
  "tuesday": "Mardi",
  "wednesday": "Mercredi",
  "thursday": "Jeudi",
  "friday": "Vendredi",
  "saturday": "Samedi",
  "sunday": "Dimanche",
  "forever": "Tout",
  "help": "Aide",
  "helpWhatIsEpura": "Qu'est-ce qu'Epura ?",
  "helpWhatIsEpuraBody": "Epura vous aide à examiner et nettoyer les photos, vidéos et téléchargements sur votre téléphone.",
  "helpHowItWorks": "Comment ça marche",
  "helpHowItWorksBody": "Glissez à droite pour garder un fichier, à gauche pour le supprimer, ou appuyez sur « Passer » pour décider plus tard.",
  "helpNotifications": "Notifications",
  "helpNotificationsBody": "Activez les rappels pour être notifié chaque jour ou chaque semaine de nettoyer votre stockage.",
  "helpLookback": "Période de recherche",
  "helpLookbackBody": "Quand vous commencez un examen, choisissez la période — de 1 jour à tout l'historique.",
  "helpStats": "Statistiques",
  "helpStatsBody": "Voyez combien d'espace vous avez libéré et suivez votre série de nettoyage."
```

- [ ] **Step 3: Regenerate localization files**

```bash
flutter gen-l10n
```

Expected: completes without errors. Generated files `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_fr.dart` are updated with new getters.

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/l10n/
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/
git commit -m "feat: add localization strings for unified notifications, forever lookback, and help section"
```

---

## Chunk 2: Fix notification channel + unified `scheduleReminder`

### Task 2: Fix channel registration and replace `scheduleDailyReminder` with `scheduleReminder`

**Files:**
- Modify: `lib/services/notification_service.dart`

Context: `flutter_local_notifications` v21 requires explicit `createNotificationChannel()` before posting. The current code never creates the channel, so all scheduled notifications are silently dropped on Android 8+. Additionally, `scheduleDailyReminder(TimeOfDay)` is replaced with `scheduleReminder(TimeOfDay, String interval, int dayOfWeek)` to support both daily and weekly intervals.

The `flutter_timezone` v5 API returns `TimezoneInfo` from `getLocalTimezone()`, so `.identifier` is correct — do NOT change the timezone code.

- [ ] **Step 1: Update constants and channel name**

In `lib/services/notification_service.dart`, change line 10:

```dart
static const String _channelName = 'Daily Reminders';
```

to:

```dart
static const String _channelName = 'Cleanup Reminders';
```

- [ ] **Step 2: Add channel creation to `init()`**

Replace the existing `init()` method (lines 17–26) with:

```dart
Future<void> init() async {
  tz.initializeTimeZones();
  final tzInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await _plugin.initialize(settings: initSettings);

  final androidPlugin =
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    ),
  );
}
```

- [ ] **Step 3: Replace `scheduleDailyReminder` with `scheduleReminder`**

Replace the entire `scheduleDailyReminder` method (lines 37–71) with:

```dart
Future<void> scheduleReminder(
  TimeOfDay time,
  String interval,
  int dayOfWeek,
) async {
  await cancelReminder();

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  final DateTimeComponents matchComponents;

  if (interval == 'weekly') {
    // Advance to next matching dayOfWeek (1=Mon .. 7=Sun)
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    // If that day/time already passed this week, jump to next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    matchComponents = DateTimeComponents.dayOfWeekAndTime;
  } else {
    // Daily
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    matchComponents = DateTimeComponents.time;
  }

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const notificationDetails = NotificationDetails(android: androidDetails);

  await _plugin.zonedSchedule(
    id: _reminderId,
    title: _title,
    body: _body,
    scheduledDate: scheduledDate,
    notificationDetails: notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: matchComponents,
  );
}
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/services/notification_service.dart
```

Expected: no errors. (Note: callers still reference `scheduleDailyReminder` — those will be fixed in Task 3.)

- [ ] **Step 5: Commit**

```bash
git add lib/services/notification_service.dart
git commit -m "fix: register notification channel in init() and replace scheduleDailyReminder with scheduleReminder"
```

---

## Chunk 3: Update SettingsProvider

### Task 3: Add interval/day fields and update all scheduling calls

**Files:**
- Modify: `lib/providers/settings_provider.dart`

Context: `SettingsProvider` currently calls `_notificationService.scheduleDailyReminder(_reminderTime)` in three places: `setNotificationsEnabled`, `applyNotificationPermissionResult`, and `setReminderTime`. All three must switch to `scheduleReminder(time, interval, dayOfWeek)`. Two new persisted fields (`_notificationInterval`, `_notificationDayOfWeek`) are added. `setReminderTime` also gains a guard so it only reschedules when notifications are enabled.

- [ ] **Step 1: Add new key constants**

After line 15 (`static const String _keyLocale = 'locale';`), add:

```dart
static const String _keyNotificationInterval = 'notificationInterval';
static const String _keyNotificationDayOfWeek = 'notificationDayOfWeek';
```

- [ ] **Step 2: Add new fields and getters**

After line 28 (`DateTime? _lastReviewTimestamp;`), add:

```dart
String _notificationInterval = 'daily';
int _notificationDayOfWeek = DateTime.monday;
```

After line 37 (`DateTime? get lastReviewTimestamp => _lastReviewTimestamp;`), add:

```dart
String get notificationInterval => _notificationInterval;
int get notificationDayOfWeek => _notificationDayOfWeek;
```

- [ ] **Step 3: Load new fields in `init()`**

After line 50 (`_localeCode = _prefs.getString(_keyLocale);`), add:

```dart
_notificationInterval = _prefs.getString(_keyNotificationInterval) ?? 'daily';
_notificationDayOfWeek = _prefs.getInt(_keyNotificationDayOfWeek) ?? DateTime.monday;
```

- [ ] **Step 4: Add helper method for scheduling**

After the `init()` method, add:

```dart
Future<void> _scheduleIfEnabled() async {
  if (_notificationsEnabled) {
    await _notificationService.scheduleReminder(
      _reminderTime,
      _notificationInterval,
      _notificationDayOfWeek,
    );
  }
}
```

- [ ] **Step 5: Update `setReminderTime`**

Replace the existing `setReminderTime` method with:

```dart
Future<void> setReminderTime(TimeOfDay time) async {
  if (_reminderTime == time) return;
  _reminderTime = time;
  await _prefs.setInt(_keyReminderHour, time.hour);
  await _prefs.setInt(_keyReminderMinute, time.minute);
  notifyListeners();
  await _scheduleIfEnabled();
}
```

- [ ] **Step 6: Update `setNotificationsEnabled`**

Replace line 99 (`await _notificationService.scheduleDailyReminder(_reminderTime);`) with:

```dart
await _notificationService.scheduleReminder(
  _reminderTime,
  _notificationInterval,
  _notificationDayOfWeek,
);
```

- [ ] **Step 7: Update `applyNotificationPermissionResult`**

Replace line 113 (`await _notificationService.scheduleDailyReminder(_reminderTime);`) with:

```dart
await _notificationService.scheduleReminder(
  _reminderTime,
  _notificationInterval,
  _notificationDayOfWeek,
);
```

- [ ] **Step 8: Add `setNotificationInterval` setter**

After `applyNotificationPermissionResult`, add:

```dart
Future<void> setNotificationInterval(String interval) async {
  if (_notificationInterval == interval) return;
  _notificationInterval = interval;
  await _prefs.setString(_keyNotificationInterval, interval);
  notifyListeners();
  await _scheduleIfEnabled();
}
```

- [ ] **Step 9: Add `setNotificationDayOfWeek` setter**

After `setNotificationInterval`, add:

```dart
Future<void> setNotificationDayOfWeek(int day) async {
  if (_notificationDayOfWeek == day) return;
  _notificationDayOfWeek = day;
  await _prefs.setInt(_keyNotificationDayOfWeek, day);
  notifyListeners();
  await _scheduleIfEnabled();
}
```

- [ ] **Step 10: Verify**

```bash
flutter analyze lib/providers/settings_provider.dart
```

Expected: no errors.

- [ ] **Step 11: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "feat: add notification interval/day-of-week fields, guard setReminderTime, update scheduling calls"
```

---

## Chunk 4: Update SettingsScreen UI

### Task 4: Unified notification section + help bottom sheet

**Files:**
- Modify: `lib/screens/settings_screen.dart`

Context: The existing notifications section has a toggle + time picker. We add interval chips (Daily/Weekly), day-of-week chips (Mon–Sun, visible only for weekly), change the subtitle from `l.dailyCleanupReminder` to `l.cleanupReminder`, and add a Help section after About.

- [ ] **Step 1: Update the notification subtitle**

In `lib/screens/settings_screen.dart`, change line 24:

```dart
subtitle: Text(l.dailyCleanupReminder),
```

to:

```dart
subtitle: Text(l.cleanupReminder),
```

- [ ] **Step 2: Add interval selector after the toggle**

After the existing `SwitchListTile` block (line 27), and inside the `if (settings.notificationsEnabled)` guard (before the `ListTile` for reminder time), add:

```dart
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceSM,
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l.daily),
                  selected: settings.notificationInterval == 'daily',
                  onSelected: (_) => settings.setNotificationInterval('daily'),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                ChoiceChip(
                  label: Text(l.weekly),
                  selected: settings.notificationInterval == 'weekly',
                  onSelected: (_) => settings.setNotificationInterval('weekly'),
                ),
              ],
            ),
          ),
```

- [ ] **Step 3: Add day-of-week selector (visible only for weekly)**

Immediately after the interval selector added above, add:

```dart
          if (settings.notificationInterval == 'weekly')
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceSM,
              ),
              child: Wrap(
                spacing: AppTheme.spaceSM,
                runSpacing: AppTheme.spaceSM,
                children: [
                  for (final entry in {
                    DateTime.monday: l.monday,
                    DateTime.tuesday: l.tuesday,
                    DateTime.wednesday: l.wednesday,
                    DateTime.thursday: l.thursday,
                    DateTime.friday: l.friday,
                    DateTime.saturday: l.saturday,
                    DateTime.sunday: l.sunday,
                  }.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: settings.notificationDayOfWeek == entry.key,
                      onSelected: (_) =>
                          settings.setNotificationDayOfWeek(entry.key),
                    ),
                ],
              ),
            ),
```

- [ ] **Step 4: Add Help section after About**

After the existing About `ListTile` (the last item in the `ListView`, around line 131), add:

```dart
          const Divider(),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l.help),
            onTap: () => _showHelp(context, l),
          ),
```

- [ ] **Step 5: Add `_showHelp` static method**

Since `SettingsScreen` is a `StatelessWidget`, add this as a top-level function at the bottom of the file (after the closing `}` of `SettingsScreen`), or convert to a private helper:

```dart
void _showHelp(BuildContext context, AppLocalizations l) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.helpWhatIsEpura,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpWhatIsEpuraBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(l.helpHowItWorks,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpHowItWorksBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(l.helpNotifications,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpNotificationsBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(l.helpLookback,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpLookbackBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(l.helpStats,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpStatsBody),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 6: Verify import exists**

Confirm `lib/screens/settings_screen.dart` already has `import '../l10n/app_localizations.dart';` at line 4. No change needed — it's already present.

- [ ] **Step 7: Verify**

```bash
flutter analyze lib/screens/settings_screen.dart
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: unified notification UI with interval/day-of-week selectors and help section"
```

---

## Chunk 5: LookbackPicker "Forever" + HomeScreen update

### Task 5: Add `LookbackResult` class and "Forever" chip

**Files:**
- Modify: `lib/widgets/lookback_picker.dart`

Context: `LookbackPicker.show()` currently returns `Future<DateTime?>`. We wrap the return in a `LookbackResult` class and add a "Forever" chip. "Forever" uses `DateTime(1970)` as a sentinel so that `FileService.scanForNewFiles(since: DateTime(1970))` passes all files through the date filter (every file is newer than 1970).

- [ ] **Step 1: Add `LookbackResult` class**

At the top of `lib/widgets/lookback_picker.dart`, after the imports and before `class LookbackPicker`, add:

```dart
class LookbackResult {
  static final DateTime _kForever = DateTime(1970);

  final DateTime since;
  LookbackResult({required this.since});
  LookbackResult.forever() : since = _kForever;

  bool get isForever => since.year == 1970;
}
```

- [ ] **Step 2: Update `show()` return type**

Change the `show` static method return type and `showModalBottomSheet` generic:

```dart
static Future<LookbackResult?> show(
  BuildContext context, {
  DateTime? lastReviewTimestamp,
}) {
  return showModalBottomSheet<LookbackResult>(
    context: context,
    builder: (_) => LookbackPicker(
      lastReviewTimestamp: lastReviewTimestamp,
    ),
  );
}
```

- [ ] **Step 3: Add `_forever` state and update `initState`**

In `_LookbackPickerState`, add a new field:

```dart
bool _forever = false;
```

- [ ] **Step 4: Update `_computeCutoff` to return `DateTime`**

Replace the existing `_computeCutoff` method with:

```dart
DateTime _computeCutoff() {
  if (_forever) {
    return DateTime(1970);
  }
  if (_sinceLastReview && widget.lastReviewTimestamp != null) {
    return widget.lastReviewTimestamp!;
  }
  return DateTime.now().subtract(Duration(days: _selectedDays ?? 7));
}
```

- [ ] **Step 5: Add "Forever" chip and localization import**

Add the import at the top of the file:

```dart
import '../l10n/app_localizations.dart';
```

In the `build` method, get the localization instance. Change the beginning of `build`:

```dart
@override
Widget build(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  final hasLastReview = widget.lastReviewTimestamp != null;
```

Also update the "Since last review" chip's `onTap` handler to reset `_forever`. Find the existing `_PickerChip` for "Since last review" (around line 67–76) and replace its `onTap`:

```dart
onTap: () => setState(() {
  _sinceLastReview = true;
  _forever = false;
  _selectedDays = null;
}),
```

Then, in the `Wrap` widget that contains the day chips (the `for (final days in [1, 3, 7, 14, 30])` section), replace the entire `Wrap` with:

```dart
            Wrap(
              spacing: AppTheme.spaceSM,
              runSpacing: AppTheme.spaceSM,
              children: [
                for (final days in [1, 3, 7, 14, 30])
                  _PickerChip(
                    label: days == 1 ? l.oneDay : l.nDays(days),
                    selected: !_sinceLastReview && !_forever && _selectedDays == days,
                    onTap: () => setState(() {
                      _sinceLastReview = false;
                      _forever = false;
                      _selectedDays = days;
                    }),
                  ),
                _PickerChip(
                  label: l.forever,
                  selected: _forever,
                  onTap: () => setState(() {
                    _sinceLastReview = false;
                    _selectedDays = null;
                    _forever = true;
                  }),
                ),
              ],
            ),
```

- [ ] **Step 6: Update `Navigator.pop` to return `LookbackResult`**

Change the `ElevatedButton` `onPressed` from:

```dart
onPressed: () => Navigator.pop(context, _computeCutoff()),
```

to:

```dart
onPressed: () => Navigator.pop(
  context,
  LookbackResult(since: _computeCutoff()),
),
```

- [ ] **Step 7: Verify**

```bash
flutter analyze lib/widgets/lookback_picker.dart
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add lib/widgets/lookback_picker.dart
git commit -m "feat: add LookbackResult class and Forever chip to lookback picker"
```

---

### Task 6: Update HomeScreen to use `LookbackResult`

**Files:**
- Modify: `lib/screens/home_screen.dart`

Context: `LookbackPicker.show()` now returns `Future<LookbackResult?>` instead of `Future<DateTime?>`. The `Start Review` button handler needs to unwrap `result.since`. The initial `_scanFiles()` call on line 40 is unaffected.

- [ ] **Step 1: Update the Start Review handler**

In `lib/screens/home_screen.dart`, in the `ElevatedButton` `onPressed` callback (around line 195), change:

```dart
final cutoff = await LookbackPicker.show(
  context,
  lastReviewTimestamp: settings.lastReviewTimestamp,
);
if (cutoff == null || !mounted) return;
```

to:

```dart
final result = await LookbackPicker.show(
  context,
  lastReviewTimestamp: settings.lastReviewTimestamp,
);
if (result == null || !mounted) return;
```

And change:

```dart
await fs.scanForNewFiles(settings, since: cutoff);
```

to:

```dart
await fs.scanForNewFiles(settings, since: result.since);
```

- [ ] **Step 2: Remove unused import if present**

The `lookback_picker.dart` import should already be present (line 17). No change needed.

- [ ] **Step 3: Verify the full project**

```bash
flutter analyze
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: update HomeScreen to use LookbackResult from picker"
```

---

## Chunk 6: Final verification

### Task 7: Full build and final check

- [ ] **Step 1: Run full analysis**

```bash
flutter analyze
```

Expected: no issues.

- [ ] **Step 2: Regenerate l10n (confirm clean)**

```bash
flutter gen-l10n
```

Expected: completes without errors.

- [ ] **Step 3: Build APK**

```bash
flutter build apk
```

Expected: builds without errors.
