# Epura — App Design Spec

## Overview

Epura is an Android app that reminds users to review recently added photos, videos, and downloads, then decide whether to keep or delete each file. This prevents storage bloat from forgotten, unused files accumulating over time.

**Name meaning**: "Epura" suggests purity, cleanliness — reflected in the minimal visual design.

## Target Platform

- Android only (initial release)
- Flutter framework
- Minimum SDK: Android 21 (5.0)

## Screens

### 1. Home Screen
- App logo/title "epura"
- Summary card: count of new files since last review, broken down by type (photos, videos, downloads)
- "Start Review" primary action button
- "Stats" secondary button
- Settings gear icon (top-right)
- Empty state when no files to review

### 2. Review Screen (Core)
- **Info-First card layout**: file name, size, date, and source type displayed above the preview
- Large preview area (photo thumbnail, video thumbnail, file icon for downloads)
- Swipe left to delete, swipe right to keep
- Backup action buttons below the card (delete / keep) for accessibility
- "Skip for later" option — skipped files reappear next session
- Progress indicator: "3/12"
- Back arrow to abandon review (with confirmation)

### 3. Summary Screen
- Shown after all files in the queue are reviewed
- Stats: items kept, deleted, skipped
- Storage freed (in human-readable format: MB/GB)
- Motivational message
- "View Stats" and "Go Home" buttons

### 4. Settings Screen
- Reminder time picker (default: 20:00)
- File type toggles: Photos, Videos, Downloads (all on by default)
- About section with app version

### 5. Stats Screen
- Total storage freed (all time)
- This week's storage freed (bar/progress indicator)
- Review streak (consecutive days with a completed review)
- Total files reviewed (kept vs deleted breakdown)
- Review history list (date + file count per session)

## Visual Style

**Clean Minimalist**:
- Light backgrounds (#f8f9fa, white)
- Soft grays for secondary elements (#adb5bd, #495057)
- Gentle blue accent (#4dabf7) for primary actions
- Rounded pill buttons, generous spacing
- Thin, light typography (weight 200-400)
- Letter-spacing on the logo

## Architecture

### State Management: Provider
- `FileService` — scans device for photos/videos/downloads added since last review
- `ReviewProvider` — manages the review queue, swipe state, current session results
- `StatsProvider` — aggregates review history, computes streaks and totals
- `SettingsProvider` — manages user preferences and reminder scheduling

### Local Storage
- **SharedPreferences**: settings (reminder time, file type toggles, last review timestamp)
- **SQLite (sqflite)**: review history (session date, files kept/deleted/skipped, bytes freed)

### File Access
- **photo_manager**: access device photos and videos with thumbnails
- **path_provider**: locate Downloads directory for file scanning
- Files in Downloads scanned via `dart:io` Directory listing

### Notifications
- **flutter_local_notifications**: scheduled daily notification at user-configured time
- Notification taps open the app directly to Home screen

### Review Logic
- On "Start Review": query files added since `lastReviewTimestamp`
- Photos/videos via `photo_manager` filtered by creation date
- Downloads via directory listing filtered by modified date
- Queue is shuffled or sorted by date (newest first)
- On swipe-delete: file is actually deleted from device storage
- On swipe-keep: file is left untouched, marked as reviewed
- On skip: file is not marked, will reappear next session
- On session complete: update `lastReviewTimestamp`, write session to SQLite

## Key Packages

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `photo_manager` | Access photos/videos |
| `flutter_local_notifications` | Scheduled reminders |
| `sqflite` | Review history database |
| `shared_preferences` | User preferences |
| `path_provider` | Downloads folder access |
| `fl_chart` | Stats visualization |
| `flutter_card_swiper` | Swipe card interaction |

## Project Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, theme, routes
├── models/
│   ├── review_item.dart        # File to review (path, name, size, type, date)
│   └── review_session.dart     # Session result (kept, deleted, skipped, bytes)
├── providers/
│   ├── file_service.dart       # Scan device for new files
│   ├── review_provider.dart    # Review queue & swipe state
│   ├── stats_provider.dart     # History aggregation
│   └── settings_provider.dart  # Prefs & reminder scheduling
├── screens/
│   ├── home_screen.dart
│   ├── review_screen.dart
│   ├── summary_screen.dart
│   ├── settings_screen.dart
│   └── stats_screen.dart
├── widgets/
│   ├── review_card.dart        # Info-first swipe card
│   ├── file_preview.dart       # Photo/video/file preview
│   ├── stat_card.dart          # Stat display widget
│   └── empty_state.dart        # No files to review
├── services/
│   ├── notification_service.dart
│   └── database_service.dart
└── theme/
    └── app_theme.dart          # Clean minimalist theme
```

## Permissions (Android)

- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` (Android 13+)
- `MANAGE_EXTERNAL_STORAGE` (for Downloads access)
- `POST_NOTIFICATIONS` (Android 13+)
- `RECEIVE_BOOT_COMPLETED` (reschedule notifications after reboot)
