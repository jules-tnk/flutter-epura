# Notification Fixes & Release APK Naming Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix broken notifications (timezone crash + missing Android 13 permission request at first run) and rename the release APK to include the app name and version tag.

**Architecture:** Fix the `NotificationService` timezone bug, add a `requestPermission()` method, gate scheduling behind an actual grant, request permission on first `HomeScreen` mount via `SharedPreferences` flag, and add a `mv` step in the GitHub Actions workflow to rename the APK before release upload.

**Tech Stack:** Flutter/Dart, `flutter_local_notifications` v21, `flutter_timezone` v5, `permission_handler`, `shared_preferences`, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-03-11-notifications-and-release-naming-design.md`

---

## Chunk 1: Fix `NotificationService`

### Task 1: Fix timezone bug and add `requestPermission()`

**Files:**
- Modify: `lib/services/notification_service.dart`

Context: `flutter_timezone` v5's `getLocalTimezone()` returns `Future<String>`, not an object. The current code calls `.identifier` on it which crashes. Also need a `requestPermission()` method for Android 13+.

- [ ] **Step 1: Fix the timezone crash**

In `lib/services/notification_service.dart`, change the `init()` method:

```dart
Future<void> init() async {
  tz.initializeTimeZones();
  final String tzName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzName));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await _plugin.initialize(settings: initSettings);
}
```

- [ ] **Step 2: Add `requestPermission()` method**

Add this method to `NotificationService`, after `init()`:

```dart
Future<bool> requestPermission() async {
  final androidPlugin =
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return true; // non-Android, assume granted
  final granted = await androidPlugin.requestNotificationsPermission();
  return granted ?? false;
}
```

- [ ] **Step 3: Verify the file compiles**

```bash
flutter analyze lib/services/notification_service.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/services/notification_service.dart
git commit -m "fix: fix timezone crash and add requestPermission() in NotificationService"
```

---

## Chunk 2: Fix `SettingsProvider` default and re-enable flow

### Task 2: Change default, handle denied permission on re-enable

**Files:**
- Modify: `lib/providers/settings_provider.dart`

Context: `notificationsEnabled` currently defaults to `true` which is wrong — permission hasn't been asked yet. Also, when the user re-enables notifications in settings after a previous denial, we must re-request (or open app settings if permanently denied).

Add `permission_handler` import for `openAppSettings()`.

- [ ] **Step 1: Change the default to `false` — both the field initializer and the `init()` fallback**

In `lib/providers/settings_provider.dart`, change the field declaration:

```dart
bool _notificationsEnabled = true;
```

to:

```dart
bool _notificationsEnabled = false;
```

Also change the fallback inside `init()` (the field declaration change alone has no effect on first run because `init()` overwrites it):

```dart
_notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? true;
```

to:

```dart
_notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? false;
```

- [ ] **Step 2: Add `permission_handler` import**

At the top of `lib/providers/settings_provider.dart`, add:

```dart
import 'package:permission_handler/permission_handler.dart';
```

- [ ] **Step 3: Update `setNotificationsEnabled` to handle re-enable with denied permission**

Replace the existing `setNotificationsEnabled` method:

```dart
Future<void> setNotificationsEnabled(bool value) async {
  if (_notificationsEnabled == value) return;
  if (value) {
    final granted = await _notificationService.requestPermission();
    if (!granted) {
      // Permission denied — open system settings so user can grant manually
      await openAppSettings();
      return; // don't flip the toggle
    }
    _notificationsEnabled = true;
    await _prefs.setBool(_keyNotificationsEnabled, true);
    notifyListeners();
    await _notificationService.scheduleDailyReminder(_reminderTime);
  } else {
    _notificationsEnabled = false;
    await _prefs.setBool(_keyNotificationsEnabled, false);
    notifyListeners();
    await _notificationService.cancelReminder();
  }
}
```

- [ ] **Step 4: Add a method to set the enabled state directly (used by first-run flow)**

Add after `setNotificationsEnabled`:

```dart
Future<void> applyNotificationPermissionResult(bool granted) async {
  _notificationsEnabled = granted;
  await _prefs.setBool(_keyNotificationsEnabled, granted);
  notifyListeners();
  if (granted) {
    await _notificationService.scheduleDailyReminder(_reminderTime);
  }
}
```

- [ ] **Step 5: Verify the file compiles**

```bash
flutter analyze lib/providers/settings_provider.dart
```

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "fix: default notificationsEnabled to false, handle denied permission on re-enable"
```

---

## Chunk 3: First-run permission gate in `HomeScreen`

### Task 3: Request notification permission on first app launch

**Files:**
- Modify: `lib/screens/home_screen.dart`

Context: `HomeScreen.initState` already uses `addPostFrameCallback` for `_scanFiles`. We extend this pattern to also request notification permission on first run, gated by a `SharedPreferences` key.

- [ ] **Step 1: Add imports to `home_screen.dart`**

Add these imports at the top of `lib/screens/home_screen.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
```

- [ ] **Step 2: Add `_requestNotifPermissionIfFirstRun()` method**

Add this method to `_HomeScreenState`:

```dart
Future<void> _requestNotifPermissionIfFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'hasAskedNotifPermission';
  if (prefs.getBool(key) == true) return;

  await prefs.setBool(key, true);

  if (!mounted) return;
  final notifService = context.read<NotificationService>();
  final settings = context.read<SettingsProvider>();
  final granted = await notifService.requestPermission();
  if (!mounted) return;
  await settings.applyNotificationPermissionResult(granted);
}
```

- [ ] **Step 3: Call the method from `initState`**

Update the `initState` `addPostFrameCallback` to also call the new method:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scanFiles();
    _requestNotifPermissionIfFirstRun();
  });
}
```

- [ ] **Step 4: Verify the file compiles**

```bash
flutter analyze lib/screens/home_screen.dart
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: request notification permission at first app launch"
```

---

## Chunk 4: Clean up `main.dart`

### Task 4: Remove stale startup scheduling block

**Files:**
- Modify: `lib/main.dart`

**Depends on:** Chunk 2 (Task 2) must be complete — `applyNotificationPermissionResult` must exist in `SettingsProvider` and `setNotificationsEnabled` must call `scheduleDailyReminder` when enabled.

Context: `main.dart` currently schedules notifications at startup based on the old `notificationsEnabled` default of `true`. With the new flow, scheduling only happens in two places:
1. `applyNotificationPermissionResult(true)` — called on first run after the OS dialog grants permission (added in Chunk 2)
2. `setNotificationsEnabled(true)` — called when the user re-enables via settings (updated in Chunk 2)

Removing the startup block is safe only after those two paths are in place.

- [ ] **Step 1: Pre-condition check — verify both scheduling paths exist**

Before touching `main.dart`, confirm the two required scheduling entry points are present:

```bash
grep -n "scheduleDailyReminder" lib/providers/settings_provider.dart
```

Expected: at least 2 hits — one inside `applyNotificationPermissionResult`, one inside `setNotificationsEnabled`. If either is missing, complete Chunk 2 first before proceeding.

Also confirm the method exists:

```bash
grep -n "applyNotificationPermissionResult" lib/providers/settings_provider.dart
```

Expected: the method definition is present.

- [ ] **Step 2: Remove the startup scheduling block**

In `lib/main.dart`, remove these lines:

```dart
if (settingsProvider.notificationsEnabled) {
  await notificationService.scheduleDailyReminder(settingsProvider.reminderTime);
}
```

- [ ] **Step 3: Confirm `scheduleDailyReminder` is gone from `main.dart`**

```bash
grep "scheduleDailyReminder" lib/main.dart
```

Expected: no output (the call no longer exists in main.dart).

- [ ] **Step 4: Run full analysis**

```bash
flutter analyze
```

Expected: no issues (or only pre-existing warnings unrelated to this change).

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart
git commit -m "fix: remove premature notification scheduling from main.dart"
```

---

## Chunk 5: Rename release APK in GitHub Actions

### Task 5: Add `mv` step to rename APK before release

**Files:**
- Modify: `.github/workflows/build.yml`

Context: Flutter always outputs `app-release.apk`. We add a named `Rename APK` shell `mv` step immediately after the existing `Build APK` step (and before `Upload APK artifact`) to rename the file to `epura-<tag>.apk` using `${{ github.ref_name }}` (e.g. `v1.0.0`). Both the artifact upload and release attachment then reference the renamed path.

Current step order in the file:
1. `uses: actions/checkout@v4`
2. `uses: subosito/flutter-action@v2`
3. `name: Install dependencies`
4. `name: Run analysis`
5. `name: Build APK`  ← insert **Rename APK** here
6. `name: Upload APK artifact`
7. `name: Create GitHub Release`

- [ ] **Step 1: Add rename step and update paths in `build.yml`**

Replace the current upload/release section (steps 6–7 above):

```yaml
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: epura-apk
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          generate_release_notes: true
```

with:

```yaml
      - name: Rename APK
        run: mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/epura-${{ github.ref_name }}.apk

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: epura-apk
          path: build/app/outputs/flutter-apk/epura-${{ github.ref_name }}.apk

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/epura-${{ github.ref_name }}.apk
          generate_release_notes: true
```

- [ ] **Step 2: Verify YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build.yml')); print('YAML OK')"
```

Expected output: `YAML OK`. If `python3` or `pyyaml` is unavailable, open the file in an editor and confirm indentation is consistent (2 spaces, same as existing steps).

- [ ] **Step 3: Acceptance check — verify renamed paths and no stale references**

Confirm 3 lines reference the new name:

```bash
grep "epura-" .github/workflows/build.yml
```

Expected: 3 lines — one in `Rename APK` `run:`, one in `Upload APK artifact` `path:`, one in `Create GitHub Release` `files:`.

Confirm no stale references remain:

```bash
grep "app-release.apk" .github/workflows/build.yml
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/build.yml
git commit -m "feat: rename release APK to epura-<tag>.apk in CI workflow"
```
