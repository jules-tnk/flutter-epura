# Design: Notification Fixes & Release APK Naming

**Date:** 2026-03-11
**Status:** Approved

---

## Problem 1 — Notifications not working + no permission request

### Root causes

1. **Crash in `NotificationService.init()`**: `flutter_timezone` v5 returns a plain `String` from `getLocalTimezone()`, but the code calls `.identifier` on it. This crashes notification init silently — nothing ever schedules.
2. **No `POST_NOTIFICATIONS` permission request**: Android 13+ (API 33+) requires explicit runtime permission. The app never requests it, so all notifications are silently blocked.
3. **Wrong default**: `notificationsEnabled` defaults to `true` in `SettingsProvider` before any permission has been granted. This misleads the user into thinking notifications are active when they are not.

### Design

#### `NotificationService`

- Fix `tzInfo.identifier` → use `tzInfo` directly (already a `String` in v5).
- Add `requestPermission() → Future<bool>` method that calls the Android-native `requestNotificationsPermission()` from `flutter_local_notifications`. Returns the grant result.

#### `SettingsProvider`

- Change default `_notificationsEnabled` to `false` — permission state is unknown until asked.
- When user re-enables notifications in settings: call `requestPermission()` first.
  - If granted → schedule reminder.
  - If permanently denied → open system app settings via `permission_handler` (`openAppSettings()`).

#### `HomeScreen` — first-run permission gate

- In `initState`, read `hasAskedNotifPermission` from `SharedPreferences`.
- If key is absent (first run):
  - Call `notificationService.requestPermission()`.
  - Persist result into `settingsProvider` (enable/disable accordingly).
  - Set `hasAskedNotifPermission = true` to prevent re-asking.
- Asking happens once per install. Cleared storage or re-install will ask again — correct behavior.

#### `main.dart`

- Remove the startup scheduling block. Scheduling is now only triggered after permission is confirmed (either at first-run or when user re-enables in settings).

---

## Problem 2 — Release APK has a generic name

### Root cause

The Flutter build output is always `app-release.apk`. The GitHub Actions workflow attaches it as-is, giving every release an identical, non-descriptive filename.

### Design

Add a **Rename APK** shell step in `.github/workflows/build.yml` immediately after the build step:

```yaml
- name: Rename APK
  run: mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/epura-${{ github.ref_name }}.apk
```

Update both the artifact upload and the release attachment steps to use the new path.

**Result:** tag `v1.2.0` → release asset `epura-v1.2.0.apk`.

---

## Files changed

| File | Change |
|------|--------|
| `lib/services/notification_service.dart` | Fix timezone bug, add `requestPermission()` |
| `lib/providers/settings_provider.dart` | Default `notificationsEnabled = false`, handle denied permission |
| `lib/screens/home_screen.dart` | First-run permission gate in `initState` |
| `lib/main.dart` | Remove startup scheduling block |
| `.github/workflows/build.yml` | Add rename step, update paths |
