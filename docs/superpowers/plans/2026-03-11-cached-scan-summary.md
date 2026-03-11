# Cached Scan Summary Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show cached file counts instantly on app launch while a background scan refreshes the data.

**Architecture:** Store photo/video/download counts and total size in SharedPreferences. FileService loads them synchronously on init, then the home screen scan updates them. HomeScreen shows cached data with a subtle progress indicator during background refresh.

**Tech Stack:** Flutter/Dart, SharedPreferences, existing FileService/HomeScreen

**Spec:** `docs/superpowers/specs/2026-03-11-cached-scan-summary-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/providers/file_service.dart` | Modify | Add `ScanSummary` class, `init()`, `_cachedSummary`, `_isBackgroundScanning`, `updateCache` param |
| `lib/main.dart` | Modify | Create `FileService` before `runApp`, `await init()`, use `ChangeNotifierProvider.value` |
| `lib/screens/home_screen.dart` | Modify | Three-state display logic, pass `since: DateTime(1970)` + `updateCache: true` |

---

## Chunk 1: Implementation

### Task 1: Add ScanSummary and caching to FileService

**Files:**
- Modify: `lib/providers/file_service.dart`

- [ ] **Step 1: Add ScanSummary class and new state fields**

At the top of `lib/providers/file_service.dart`, before the `FileService` class, add:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ScanSummary {
  final int photoCount;
  final int videoCount;
  final int downloadCount;
  final int totalSize;

  const ScanSummary({
    required this.photoCount,
    required this.videoCount,
    required this.downloadCount,
    required this.totalSize,
  });

  bool get isEmpty => photoCount == 0 && videoCount == 0 && downloadCount == 0;
  int get totalCount => photoCount + videoCount + downloadCount;
}
```

Inside `FileService`, add new fields after the existing ones:

```dart
ScanSummary? _cachedSummary;
bool _isBackgroundScanning = false;

ScanSummary? get cachedSummary => _cachedSummary;
bool get isBackgroundScanning => _isBackgroundScanning;
```

- [ ] **Step 2: Add init() method**

Add to `FileService`:

```dart
static const String _keyCachedPhotoCount = 'cachedPhotoCount';
static const String _keyCachedVideoCount = 'cachedVideoCount';
static const String _keyCachedDownloadCount = 'cachedDownloadCount';
static const String _keyCachedTotalSize = 'cachedTotalSize';

late final SharedPreferences _prefs;

Future<void> init() async {
  _prefs = await SharedPreferences.getInstance();
  final photo = _prefs.getInt(_keyCachedPhotoCount);
  final video = _prefs.getInt(_keyCachedVideoCount);
  final download = _prefs.getInt(_keyCachedDownloadCount);
  final size = _prefs.getInt(_keyCachedTotalSize);

  if (photo != null && video != null && download != null && size != null) {
    _cachedSummary = ScanSummary(
      photoCount: photo,
      videoCount: video,
      downloadCount: download,
      totalSize: size,
    );
  }
}
```

- [ ] **Step 3: Modify scanForNewFiles() to support background scanning and cache writes**

Replace the opening of `scanForNewFiles` (lines 40-42) with:

```dart
Future<void> scanForNewFiles(SettingsProvider settings, {DateTime? since, bool updateCache = false}) async {
  if (_cachedSummary != null && _items.isEmpty) {
    _isBackgroundScanning = true;
  } else {
    _isLoading = true;
  }
  notifyListeners();
```

Replace the `finally` block (lines 66-69) with:

```dart
} finally {
  if (updateCache) {
    _cachedSummary = _computeSummary();
    await _prefs.setInt(_keyCachedPhotoCount, _cachedSummary!.photoCount);
    await _prefs.setInt(_keyCachedVideoCount, _cachedSummary!.videoCount);
    await _prefs.setInt(_keyCachedDownloadCount, _cachedSummary!.downloadCount);
    await _prefs.setInt(_keyCachedTotalSize, _cachedSummary!.totalSize);
  }
  _isLoading = false;
  _isBackgroundScanning = false;
  notifyListeners();
}
```

- [ ] **Step 4: Add _computeSummary() helper**

Add to `FileService`:

```dart
ScanSummary _computeSummary() {
  var photoCount = 0;
  var videoCount = 0;
  var downloadCount = 0;
  var totalSize = 0;
  for (final i in _items) {
    totalSize += i.size;
    switch (i.type) {
      case FileItemType.photo:
        photoCount++;
      case FileItemType.video:
        videoCount++;
      case FileItemType.download:
        downloadCount++;
    }
  }
  return ScanSummary(
    photoCount: photoCount,
    videoCount: videoCount,
    downloadCount: downloadCount,
    totalSize: totalSize,
  );
}
```

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/providers/file_service.dart
git commit -m "feat: add ScanSummary caching to FileService"
```

---

### Task 2: Wire up FileService.init() in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Create FileService before runApp, init in parallel, use Provider.value**

In `lib/main.dart`, change:

```dart
// Before (line 16-20):
final dbService = DatabaseService();
final notificationService = NotificationService();
await Future.wait([dbService.init(), notificationService.init()]);
```

To:

```dart
final dbService = DatabaseService();
final notificationService = NotificationService();
final fileService = FileService();
await Future.wait([dbService.init(), notificationService.init(), fileService.init()]);
```

Then change the provider registration (line 29):

```dart
// Before:
ChangeNotifierProvider(create: (_) => FileService()),

// After:
ChangeNotifierProvider.value(value: fileService),
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: initialize FileService with cached summary at startup"
```

---

### Task 3: Update HomeScreen for three-state display

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Change _scanFiles() to scan all files with cache update**

In `lib/screens/home_screen.dart`, replace `_scanFiles()` (lines 36-41):

```dart
Future<void> _scanFiles() async {
  final fileService = context.read<FileService>();
  final settings = context.read<SettingsProvider>();
  await fileService.requestPermissions();
  await fileService.scanForNewFiles(settings, since: DateTime(1970), updateCache: true);
}
```

- [ ] **Step 2: Update build() to use three-state display logic**

Replace the counting logic (lines 64-77) and the `Expanded` content section.

The counting logic should resolve from either live items or cached summary:

```dart
final hasFreshData = !fileService.isLoading && !fileService.isBackgroundScanning;
final summary = hasFreshData
    ? null  // use live items below
    : fileService.cachedSummary;

int photoCount, videoCount, downloadCount, totalSize;
if (summary != null) {
  photoCount = summary.photoCount;
  videoCount = summary.videoCount;
  downloadCount = summary.downloadCount;
  totalSize = summary.totalSize;
} else {
  photoCount = 0;
  videoCount = 0;
  downloadCount = 0;
  totalSize = 0;
  for (final i in items) {
    totalSize += i.size;
    switch (i.type) {
      case FileItemType.photo:
        photoCount++;
      case FileItemType.video:
        videoCount++;
      case FileItemType.download:
        downloadCount++;
    }
  }
}
final totalCount = photoCount + videoCount + downloadCount;
```

Replace the `Expanded` child's ternary logic. The three states:

1. **No cache + loading** → spinner (same as today)
2. **Has data (cached or fresh)** → summary card (with optional progress indicator)
3. **Permission denied** → permission screen (same as today)
4. **Empty** → EmptyState (same as today)

```dart
Expanded(
  child: fileService.permissionDenied
      ? Center(/* ...existing permission denied UI unchanged... */)
      : (fileService.isLoading && summary == null)
          ? const Center(child: CircularProgressIndicator())
          : totalCount == 0 && !fileService.isBackgroundScanning
              ? const EmptyState()
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fileService.isBackgroundScanning)
                          const Padding(
                            padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
                            child: LinearProgressIndicator(),
                          ),
                        Text(
                          l.filesToReview(totalCount),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        Text(
                          formatBytes(totalSize),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Divider(height: AppTheme.spaceLG),
                        _SummaryRow(
                          icon: Icons.photo_outlined,
                          label: l.photos,
                          count: photoCount,
                        ),
                        _SummaryRow(
                          icon: Icons.videocam_outlined,
                          label: l.videos,
                          count: videoCount,
                        ),
                        _SummaryRow(
                          icon: Icons.download_outlined,
                          label: l.downloads,
                          count: downloadCount,
                        ),
                      ],
                    ),
                  ),
                ),
),
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: show cached scan summary on launch with background refresh"
```

---

### Task 4: Final verification

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: Build APK**

Run: `flutter build apk --release`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit any remaining changes**

If any fixups were needed, commit them.
