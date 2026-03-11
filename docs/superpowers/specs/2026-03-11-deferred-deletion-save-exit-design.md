# Deferred Deletion & Save/Exit Design

## Problem

1. File deletions happen immediately when the user swipes left during review. If the user leaves mid-review, deleted files are gone but the session isn't saved — an inconsistent state.
2. The leave dialog message ("Your progress will be lost") is misleading since deletions are already permanent.
3. There is no way to leave a review mid-session while preserving progress (stats saved to DB).

## Solution

Defer all file deletions until the session ends. During review, "delete" marks a file for deletion but doesn't touch the filesystem. Deletions are only executed when the session completes (all files reviewed) or when the user explicitly chooses "Save & Exit." If the user discards, nothing happens — no deletions, no session saved.

## Design

### ReviewProvider changes

**New state:**
- `List<ReviewItem> _pendingDeletions` — files marked for deletion during review, not yet deleted from disk

**Modified `deleteCurrent()`:**
- No longer calls `File(path).delete()` — instead adds the current item to `_pendingDeletions`
- Still increments `_deletedCount`, `_bytesFreed`, and `_currentIndex`
- `_bytesFreed` is accumulated eagerly at swipe time (using `item.size`), so the summary screen shows correct totals immediately. If a file no longer exists when `executePendingDeletions()` runs, the count stays — it reflects user intent, not filesystem confirmation.
- Still calls `notifyListeners()`

**New method: `executePendingDeletions()`**
- Returns `Future<void>`
- Iterates `_pendingDeletions` and deletes each file from disk (same logic as current `deleteCurrent`)
- Silently skips files that no longer exist
- Called by `completeSession()` and by the review screen's "Save & Exit" handler

**New method: `discardSession()`**
- Clears `_pendingDeletions` without executing them
- Resets all counters (`_keptCount`, `_deletedCount`, `_skippedCount`, `_bytesFreed`, `_currentIndex`)
- Called by the review screen's "Discard & Exit" handler

**Modified `completeSession()`:**
- Calls `executePendingDeletions()` before saving the session to the database
- Otherwise unchanged (still creates `ReviewSession`, inserts to DB, updates `lastReviewTimestamp`)

**Modified `startReview()`:**
- Clears `_pendingDeletions` alongside existing counter resets

### Review screen dialog changes

**New enum:**
```dart
enum LeaveReviewChoice { cancel, saveAndExit, discardAndExit }
```

The dialog return type changes from `bool?` to `LeaveReviewChoice?`. The `_onWillPop` method returns `LeaveReviewChoice` instead of `bool`.

The leave dialog gets three buttons instead of two:

1. **"Cancel"** — dismiss dialog, stay in review (unchanged)
2. **"Save & Exit"** — calls `executePendingDeletions()` then `completeSession()` (saves session to DB), then navigates home
3. **"Discard & Exit"** — calls `discardSession()` (clears pending deletions, no session saved), then navigates home

**Dialog message changes** from "Your progress in this session will be lost" to "You can save your progress or discard all changes."

**Loading guard during Save & Exit:**
When the user taps "Save & Exit", a `_isSaving` flag is set to `true` and the dialog buttons are disabled (or replaced with a progress indicator) until `executePendingDeletions()` and `completeSession()` finish. This prevents double-triggers and gives feedback that deletions are executing.

### Session completion flow (all files reviewed)

Unchanged behavior: when `isComplete` becomes true, `completeSession()` is called which now executes pending deletions before saving the session. The summary screen shows final stats as before.

### Edge cases

- **App killed mid-review:** Same as "Discard & Exit" — pending deletions are lost (in-memory only), no session saved. No files deleted.
- **User makes 0 decisions then exits:** If `_keptCount + _deletedCount + _skippedCount == 0`, "Save & Exit" behaves the same as "Discard & Exit" — no session saved, no deletions executed. The button is still available (no special disabling) but the handler checks the total count and skips the DB insert if zero.
- **File moved/deleted externally before session ends:** `executePendingDeletions()` silently skips files that no longer exist (same error handling as current `deleteCurrent`).

## Localization

**Updated keys:**
- `leaveReviewMessage` — new message for leave dialog
- `saveAndExit` — "Save & Exit" / "Enregistrer et quitter"
- `discardAndExit` — "Discard & Exit" / "Abandonner et quitter"

**Removed keys:**
- `leave` — replaced by the two new options above

## Files to modify

1. `lib/providers/review_provider.dart` — deferred deletion logic, `_pendingDeletions`, `executePendingDeletions()`, `discardSession()`
2. `lib/screens/review_screen.dart` — `LeaveReviewChoice` enum, three-button leave dialog, `_isSaving` loading guard, updated message
3. `lib/l10n/app_en.arb` — new/updated strings
4. `lib/l10n/app_fr.arb` — French translations
