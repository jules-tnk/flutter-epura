# Epura

A minimal Android app that reminds you to periodically review recently added photos, videos, and downloads. Decide whether to keep or delete each file via a swipe-card interface to prevent storage bloat from forgotten files.

## Features

- **Swipe to decide** — swipe right to keep, left to delete, or skip for later
- **Smart scanning** — scans photos, videos, and downloads filtered by a configurable lookback period
- **Daily reminders** — configurable notification time with option to disable
- **Stats & streaks** — track total storage freed, weekly progress, and review streaks
- **Bilingual** — English and French, follows device locale with manual override
- **Lookback picker** — choose how far back to scan (1, 3, 7, 14, or 30 days) before each review

## Screenshots

<!-- Add screenshots here -->

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android SDK with minimum API level 21

### Build & Run

```bash
flutter pub get
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Architecture

- **State management**: Provider (ChangeNotifier)
- **Database**: SQLite via sqflite (review session history)
- **Notifications**: flutter_local_notifications with timezone support
- **Media access**: photo_manager
- **Localization**: Flutter's built-in ARB/intl system

### Project Structure

```
lib/
  main.dart              # App bootstrap
  app.dart               # MaterialApp with routes and i18n
  l10n/                  # ARB translation files (en, fr)
  models/                # ReviewItem, ReviewSession
  providers/             # FileService, ReviewProvider, SettingsProvider, StatsProvider
  screens/               # Home, Review, Summary, Settings, Stats
  services/              # DatabaseService, NotificationService, ThumbnailCache
  theme/                 # AppTheme (colors, spacing, typography)
  utils/                 # formatBytes utility
  widgets/               # ReviewCard, FilePreview, EmptyState, LookbackPicker, StatCard
```

## CI/CD

Push a tag like `v1.0.0` to trigger the GitHub Actions workflow which builds a release APK and creates a GitHub Release with the artifact attached.

## Permissions

- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` — access device gallery
- `MANAGE_EXTERNAL_STORAGE` — scan Downloads folder
- `POST_NOTIFICATIONS` — daily reminder notifications
- `SCHEDULE_EXACT_ALARM` — schedule notifications at specific times

## License

MIT
