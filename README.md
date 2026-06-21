# Epura

Epura is a local-first Android cleanup app for reviewing photos, videos,
selected folders, and manually imported downloads before they become clutter.
It keeps the user in control: every file is reviewed through the keep, delete,
skip, or never-ask-again flow, and actual deletion is confirmed at the end of
the session.

Epura has no account system, no analytics SDK, no ads, and no cloud sync. The
core app works offline and keeps its state on the device.

## Install

<a href="https://play.google.com/store/apps/details?id=com.epura.cleaner">
  <img
    src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
    width="180"
    alt="Get it on Google Play"
  />
</a>

## Features

- **Swipe review**: swipe right to keep, left to delete, skip for later, or
  keep a file out of future review.
- **Review modes**: review recent files, largest files, screenshots, large
  videos, downloads, selected folders, exact duplicates, bursts, or skipped
  items.
- **Smart local scanning**: photos and videos are scanned through Android media
  access, selected folders through Android Storage Access Framework grants, and
  downloads only after the user manually imports files.
- **Duplicate and burst review**: Epura groups candidates locally but does not
  auto-delete or choose the best item for the user.
- **Deletion safety**: media deletion prefers Android trash where available,
  falls back to system deletion requests, and reports failed deletions instead
  of hiding them.
- **Storage insight**: explains what Epura can review and what belongs in
  Android settings or other apps.
- **Privacy and permissions center**: shows what Epura can access, confirms the
  local-only privacy receipt, and clears Epura history without deleting files.
- **Downloads inbox**: imports user-selected documents, offers type filters,
  and explains Android's Downloads restrictions.
- **Daily or weekly reminders**: configurable local notifications.
- **Stats and streaks**: local session history, storage freed, monthly progress,
  and review streaks.
- **Bilingual UI**: English and French, following device locale with manual
  override.

See [docs/features.md](docs/features.md) for the feature reference and links to
the feature-flow diagrams.

## Screenshots

<p align="center">
  <img src="img/image-1.png" width="30%" alt="Screenshot 1" />
  <img src="img/image-2.png" width="30%" alt="Screenshot 2" />
</p>

## Documentation

The documentation is intentionally small and diagram-led:

- [docs/README.md](docs/README.md): documentation index.
- [docs/features.md](docs/features.md): user-facing capabilities and feature
  flow context.
- [docs/architecture.md](docs/architecture.md): Flutter, provider, service, and
  native Android boundaries.
- [docs/data-and-persistence.md](docs/data-and-persistence.md): Drift database,
  shared preferences, and local cache policy.
- [docs/android-integration.md](docs/android-integration.md): Android
  permissions, SAF, MediaStore/photo-manager behavior, and deletion boundaries.
- [docs/diagrams/tech-stack.mmd](docs/diagrams/tech-stack.mmd): stack map.
- [docs/diagrams/release-validation-flow.mmd](docs/diagrams/release-validation-flow.mmd):
  release validation path.

Markdown pages reference the Mermaid source files and add maintenance context;
the diagrams remain canonical in `docs/diagrams/*.mmd`.

## Engineering

### Tech Stack

The current stack is summarized in
[docs/diagrams/tech-stack.mmd](docs/diagrams/tech-stack.mmd). Keep that diagram
updated when adding dependencies, native channels, generated files, or release
tooling.

- **Framework**: Flutter and Dart.
- **State management**: Provider with `ChangeNotifier` providers.
- **Routing**: named routes in `EpuraApp`.
- **Persistence**: Drift over local SQLite through `drift_sqflite`, plus
  `SharedPreferences` for settings and small user preferences.
- **Android media access**: `photo_manager` for gallery assets and media
  deletion/trash requests.
- **Android document access**: Storage Access Framework through a Kotlin
  `MethodChannel` bridge.
- **Notifications**: `flutter_local_notifications`, `flutter_timezone`, and
  `timezone`.
- **Localization**: Flutter generated localization from ARB files.
- **Charts and UI helpers**: `fl_chart`, `flutter_card_swiper`, and standard
  Material components.

### Project Structure

```text
lib/
  main.dart              # App bootstrap and provider wiring
  app.dart               # MaterialApp, routes, theme, and localization
  l10n/                  # English/French ARB files and generated localizations
  models/                # Review, grouping, folder, index, and persistence models
  providers/             # File, review, settings, and stats state
  screens/               # Home, review, settings, stats, privacy, and group flows
  services/              # Drift DB, Android channels, scanning helpers, deletion
  theme/                 # AppTheme and color extensions
  utils/                 # Formatting helpers
  widgets/               # Reusable review, preview, picker, and stats widgets

android/
  app/src/main/AndroidManifest.xml
  app/src/main/kotlin/com/epura/cleaner/MainActivity.kt

docs/
  diagrams/              # Canonical Mermaid source files
```

### Development Workflow

1. Install Flutter stable and the Android SDK.
2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Regenerate generated code after changing Drift tables, ARB files, or other
   generated sources:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

4. Run locally on an Android device or emulator:

   ```bash
   flutter run
   ```

5. Keep documentation changes aligned with the diagrams in `docs/diagrams/`.

### Testing

Use the validation path in
[docs/diagrams/release-validation-flow.mmd](docs/diagrams/release-validation-flow.mmd)
when preparing user-facing changes.

```bash
flutter analyze
flutter test
git diff --check
```

For storage, deletion, permissions, notifications, or Android-channel changes,
also validate on an attached Android device. Device validation should cover the
specific user flow touched by the change before moving to the next milestone.

### Release

1. Bump `version:` in `pubspec.yaml` using `<major>.<minor>.<patch>+<build>`.
   The build number must increase for every Play Store upload.
2. Run the testing commands above.
3. Build a release APK:

   ```bash
   flutter build apk --release
   ```

4. Tag releases with `v*`. The GitHub Actions workflow runs `flutter analyze`,
   builds the release APK, and publishes a GitHub Release artifact named
   `epura-<tag>.apk`.

## Permissions

- `READ_EXTERNAL_STORAGE` up to Android 12: legacy media access.
- `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO`: show photos and videos in the
  review deck.
- Storage Access Framework grants: scan only folders or files explicitly chosen
  through Android system pickers.
- `POST_NOTIFICATIONS`: reminder notifications.
- `RECEIVE_BOOT_COMPLETED`: restore scheduled reminders after reboot.
- `SCHEDULE_EXACT_ALARM`: schedule reminder timing where the device allows it.
- `VIBRATE`: notification feedback.

Epura does not request `INTERNET`, `MANAGE_EXTERNAL_STORAGE`,
`QUERY_ALL_PACKAGES`, usage access, accessibility services, or notification
listener access.

## Trust And Legal

- Public trust center: [web/trust/index.html](web/trust/index.html)
- Privacy policy: [web/privacy-policy/index.html](web/privacy-policy/index.html)
- Terms of service: [web/terms-of-service/index.html](web/terms-of-service/index.html)

## License

MIT
