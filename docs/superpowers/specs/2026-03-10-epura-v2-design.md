# Epura v2 — Feature Update Design

## Overview

Four new features added to the Epura storage cleanup app:

1. **Notification bug fix** — timezone misconfiguration causing notifications to never fire
2. **Disable notifications** — toggle to turn off daily reminders entirely
3. **i18n** — French and English support with language switcher
4. **Lookback period picker** — choose how far back to scan before each review

## 1. Notification Bug Fix

**Problem:** `tz.local` defaulted to UTC because `tz.setLocalLocation()` was never called. Notifications scheduled for 20:00 local time were actually scheduled for 20:00 UTC.

**Solution:** Added `flutter_timezone` package. In `NotificationService.init()`, after initializing timezone data, we now detect the device timezone and set it as the local location. Also bumped notification importance/priority to `high`.

**Files changed:** `lib/services/notification_service.dart`, `pubspec.yaml`

## 2. Disable Notifications Toggle

Added `notificationsEnabled` boolean to `SettingsProvider` (persisted via SharedPreferences, default `true`). When toggled off, the scheduled notification is cancelled and the time picker is hidden in Settings. When toggled on, the notification is rescheduled. The startup scheduler in `main.dart` respects this setting.

**Files changed:** `lib/providers/settings_provider.dart`, `lib/screens/settings_screen.dart`, `lib/main.dart`

## 3. i18n (French/English)

Uses Flutter's official localization system:
- `flutter_localizations` SDK dependency
- `l10n.yaml` config pointing to ARB files in `lib/l10n/`
- `app_en.arb` (template) and `app_fr.arb` with ~45 keys each
- Auto-generated `AppLocalizations` class

Language selection: follows device locale by default. User can override in Settings via a dropdown (System / English / Francais). The `locale` setting is stored in SharedPreferences as a language code string (or null for system default).

All hardcoded strings across all screens and widgets have been replaced with `AppLocalizations.of(context)!.keyName` calls.

**Files changed:** All screens, all widgets with user-facing text, `lib/app.dart`, `lib/providers/settings_provider.dart`
**Files added:** `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

## 4. Lookback Period Picker

A bottom sheet (`LookbackPicker`) shown every time the user taps "Start Review". Presents preset buttons: 1 day, 3 days, 7 days, 14 days, 30 days. If a previous review exists, a "Since last review" option appears at the top and is pre-selected. For first-time users (no history), 7 days is the default.

The picker returns a `DateTime` cutoff. `FileService.scanForNewFiles` now accepts an optional `since` parameter that overrides the default `lastReviewTimestamp`. The home screen orchestrates: show picker, scan with chosen cutoff, start review.

**Files changed:** `lib/screens/home_screen.dart`, `lib/providers/file_service.dart`
**Files added:** `lib/widgets/lookback_picker.dart`
