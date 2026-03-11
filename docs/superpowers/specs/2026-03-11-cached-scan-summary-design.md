# Cached Scan Summary Design

## Problem

When the app opens, it runs a full file scan before showing anything. On devices with many files this takes several seconds, during which the user sees only a spinner. There is no way to show previous results while the scan runs.

## Solution

Cache the home screen summary (photo count, video count, download count, total size) in SharedPreferences. On launch, show cached values instantly with a non-blocking background scan indicator. When the scan completes, update the numbers in-place silently.

Additionally, change the home screen scan to always scan **all** supported files on the device (no `since` filter), so the summary reflects the full device state.

## Design

### ScanSummary data class

A simple value object holding the four cached values:

```dart
class ScanSummary {
  final int photoCount;
  final int videoCount;
  final int downloadCount;
  final int totalSize;
}
```

Defined in `lib/providers/file_service.dart` alongside `FileService`.

### FileService changes

**New state:**
- `ScanSummary? _cachedSummary` — loaded from SharedPreferences during `init()`
- `bool _isBackgroundScanning` — true when a scan is running and cached data is already available

**New method: `init()`**
- Reads 4 SharedPreferences keys: `cachedPhotoCount`, `cachedVideoCount`, `cachedDownloadCount`, `cachedTotalSize`
- If all keys exist, populates `_cachedSummary`
- Called at app startup in `main()`: create `FileService` before `runApp`, `await fileService.init()` (can run in parallel with `dbService.init()` and `notificationService.init()`), then register with `ChangeNotifierProvider.value`

**Modified `scanForNewFiles()` behavior:**
- New optional parameter: `updateCache` (default `false`)
- If `_cachedSummary != null` and items list is empty: sets `_isBackgroundScanning = true` instead of `_isLoading = true`
- If `_cachedSummary == null`: sets `_isLoading = true` as today (full spinner)
- On completion: if `updateCache` is true, computes `ScanSummary` from `_items`, writes to SharedPreferences, updates `_cachedSummary`
- Always sets `_isLoading = false` and `_isBackgroundScanning = false` on completion

Only the HomeScreen home-scan passes `updateCache: true`. The review-button scan does not, so review-filtered results never corrupt the cache.

**New getters:**
- `ScanSummary? get cachedSummary`
- `bool get isBackgroundScanning`

### HomeScreen changes

**Scan trigger:** `_scanFiles()` changes to pass `since: DateTime(1970)` so it always scans all files.

**Three display states:**

1. **No cache + scanning** (`isLoading && cachedSummary == null`): `CircularProgressIndicator` — same as today
2. **Has cache + background scanning** (`cachedSummary != null && isBackgroundScanning`): Summary card with cached counts + thin `LinearProgressIndicator` at top of card
3. **Scan complete** (`!isLoading && !isBackgroundScanning`): Summary card with fresh counts from `items`, no indicator

The summary card reads from `cachedSummary` when items are not yet available, and from the live `items` list once the scan completes. Numbers update in-place silently.

### SharedPreferences keys

| Key | Type | Description |
|-----|------|-------------|
| `cachedPhotoCount` | int | Number of photos on device |
| `cachedVideoCount` | int | Number of videos on device |
| `cachedDownloadCount` | int | Number of downloads on device |
| `cachedTotalSize` | int | Total size in bytes |

### Edge cases

- **First launch:** No cache exists, spinner shown as today
- **Permission denied:** No cache written, permission screen shown as today
- **Empty device:** Cache stores all zeros; HomeScreen treats an all-zero `cachedSummary` the same as `items.isEmpty` and shows `EmptyState`
- **App killed mid-scan:** Stale cache shown next launch, fresh scan corrects it

### No changes to

- LookbackPicker (still uses user-selected date range for reviews)
- Review flow, stats, notifications, settings
- The `since` parameter on `scanForNewFiles` — still accepted; only the HomeScreen home-scan call changes to pass `since: DateTime(1970)` and `updateCache: true`

## Files to modify

1. `lib/providers/file_service.dart` — `ScanSummary` class, `init()`, caching logic, new state
2. `lib/screens/home_screen.dart` — three-state display logic, `since: DateTime(1970)`, `LinearProgressIndicator`
3. `lib/main.dart` — call `FileService.init()` at startup
4. `lib/l10n/app_en.arb` — no new strings needed (reuses existing labels)
5. `lib/l10n/app_fr.arb` — no new strings needed
