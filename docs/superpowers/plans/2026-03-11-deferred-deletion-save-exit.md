# Deferred Deletion & Save/Exit Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Defer file deletions until session ends and give users three exit options: Cancel, Save & Exit, Discard & Exit.

**Architecture:** `ReviewProvider.deleteCurrent()` stops deleting files immediately and instead adds them to a `_pendingDeletions` list. Actual file deletion happens in `executePendingDeletions()`, called either when all files are reviewed or on "Save & Exit." A new `discardSession()` clears everything without touching disk. The review screen's leave dialog changes from a two-button `bool?` dialog to a three-button `LeaveReviewChoice` enum dialog with a loading guard.

**Tech Stack:** Flutter/Dart, Provider, existing ReviewProvider/ReviewScreen

**Spec:** `docs/superpowers/specs/2026-03-11-deferred-deletion-save-exit-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/providers/review_provider.dart` | Modify | Add `_pendingDeletions`, defer deletions in `deleteCurrent()`, add `executePendingDeletions()` and `discardSession()` |
| `lib/screens/review_screen.dart` | Modify | Add `LeaveReviewChoice` enum, three-button dialog, `_isSaving` loading guard |
| `lib/l10n/app_en.arb` | Modify | Add `saveAndExit`, `discardAndExit`, update `leaveReviewMessage` |
| `lib/l10n/app_fr.arb` | Modify | French translations for above |

---

## Chunk 1: Implementation

### Task 1: Deferred deletion logic in ReviewProvider

**Files:**
- Modify: `lib/providers/review_provider.dart`

- [ ] **Step 1: Add `_pendingDeletions` field and clear it in `startReview()`**

In `lib/providers/review_provider.dart`, add a new field after the existing counters (line 17):

```dart
List<ReviewItem> _pendingDeletions = [];
```

In `startReview()` (line 34), add a clear after `_bytesFreed = 0;`:

```dart
_pendingDeletions = [];
```

- [ ] **Step 2: Replace immediate deletion in `deleteCurrent()` with deferred logic**

Replace the entire `deleteCurrent()` method (lines 51–68) with:

```dart
void deleteCurrent() {
  if (isComplete) return;
  final item = _queue[_currentIndex];

  _pendingDeletions.add(item);
  _bytesFreed += item.size;
  _deletedCount++;
  _currentIndex++;
  notifyListeners();
}
```

Note: method signature changes from `Future<void>` to `void` (no longer async — no filesystem I/O).

- [ ] **Step 3: Add `executePendingDeletions()` method**

Add after `deleteCurrent()`:

```dart
Future<void> executePendingDeletions() async {
  for (final item in _pendingDeletions) {
    try {
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently skip files that can't be deleted
    }
  }
  _pendingDeletions = [];
}
```

- [ ] **Step 4: Add `discardSession()` method**

Add after `executePendingDeletions()`:

```dart
void discardSession() {
  _pendingDeletions = [];
  _queue = [];
  _currentIndex = 0;
  _keptCount = 0;
  _deletedCount = 0;
  _skippedCount = 0;
  _bytesFreed = 0;
  notifyListeners();
}
```

- [ ] **Step 5: Modify `completeSession()` to execute pending deletions first**

In `completeSession()` (line 77), add as the first line of the method body:

```dart
await executePendingDeletions();
```

Also add the 0-decisions guard. The full method becomes:

```dart
Future<void> completeSession(
  DatabaseService db,
  SettingsProvider settings,
) async {
  await executePendingDeletions();

  final totalDecisions = _keptCount + _deletedCount + _skippedCount;
  if (totalDecisions == 0) return;

  final now = DateTime.now();
  final session = ReviewSession(
    id: now.millisecondsSinceEpoch.toString(),
    date: now,
    keptCount: _keptCount,
    deletedCount: _deletedCount,
    skippedCount: _skippedCount,
    bytesFreed: _bytesFreed,
  );

  await db.insertSession(session);
  await settings.setLastReviewTimestamp(now);
}
```

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 7: Commit**

```bash
git add lib/providers/review_provider.dart
git commit -m "feat: defer file deletions until session ends"
```

---

### Task 2: Localization updates

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_fr.arb`

- [ ] **Step 1: Update English strings**

In `lib/l10n/app_en.arb`:

Replace:
```json
"leaveReviewMessage": "Your progress in this session will be lost.",
```
With:
```json
"leaveReviewMessage": "You can save your progress or discard all changes.",
```

Replace:
```json
"leave": "Leave",
```
With:
```json
"saveAndExit": "Save & Exit",
"discardAndExit": "Discard & Exit",
```

- [ ] **Step 2: Update French strings**

In `lib/l10n/app_fr.arb`:

Replace:
```json
"leaveReviewMessage": "Votre progression dans cette session sera perdue.",
```
With:
```json
"leaveReviewMessage": "Vous pouvez enregistrer votre progression ou abandonner toutes les modifications.",
```

Replace:
```json
"leave": "Quitter",
```
With:
```json
"saveAndExit": "Enregistrer et quitter",
"discardAndExit": "Abandonner et quitter",
```

- [ ] **Step 3: Run flutter gen-l10n**

Run: `flutter gen-l10n`
Expected: generates updated localization files without errors

- [ ] **Step 4: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_fr.arb lib/l10n/app_localizations*.dart
git commit -m "feat: add Save & Exit / Discard & Exit localization strings"
```

---

### Task 3: Three-button leave dialog in ReviewScreen

**Files:**
- Modify: `lib/screens/review_screen.dart`

- [ ] **Step 1: Add `LeaveReviewChoice` enum and `_isSaving` state**

At the top of `lib/screens/review_screen.dart`, after the imports and before the `ReviewScreen` class (line 12), add:

```dart
enum LeaveReviewChoice { cancel, saveAndExit, discardAndExit }
```

Inside `_ReviewScreenState`, add after the `_completing` field (line 22):

```dart
bool _isSaving = false;
```

- [ ] **Step 2: Replace `_onWillPop()` with three-button dialog**

Replace the entire `_onWillPop()` method (lines 30–50) with:

```dart
Future<LeaveReviewChoice> _showLeaveDialog() async {
  final l = AppLocalizations.of(context)!;
  final result = await showDialog<LeaveReviewChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.leaveReview),
      content: Text(l.leaveReviewMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, LeaveReviewChoice.cancel),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, LeaveReviewChoice.discardAndExit),
          child: Text(l.discardAndExit),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, LeaveReviewChoice.saveAndExit),
          child: Text(l.saveAndExit),
        ),
      ],
    ),
  );
  return result ?? LeaveReviewChoice.cancel;
}
```

- [ ] **Step 3: Add `_handleLeaveChoice()` method**

Add after `_showLeaveDialog()`:

```dart
Future<void> _handleLeaveChoice(LeaveReviewChoice choice) async {
  if (choice == LeaveReviewChoice.cancel || _isSaving) return;

  final review = context.read<ReviewProvider>();
  final navigator = Navigator.of(context);

  if (choice == LeaveReviewChoice.saveAndExit) {
    setState(() => _isSaving = true);
    final db = context.read<DatabaseService>();
    final settings = context.read<SettingsProvider>();
    await review.completeSession(db, settings);
    if (!mounted) return;
    navigator.pop();
  } else {
    review.discardSession();
    navigator.pop();
  }
}
```

- [ ] **Step 4: Update `PopScope` and back button to use new dialog**

Replace the `onPopInvokedWithResult` callback (lines 83–89) with:

```dart
onPopInvokedWithResult: (didPop, result) async {
  if (didPop) return;
  final choice = await _showLeaveDialog();
  await _handleLeaveChoice(choice);
},
```

Replace the back button `onPressed` (lines 95–100) with:

```dart
onPressed: () async {
  final choice = await _showLeaveDialog();
  await _handleLeaveChoice(choice);
},
```

- [ ] **Step 5: Update swipe handler for sync `deleteCurrent()`**

In the `onSwipe` callback (line 133), `review.deleteCurrent()` is now synchronous (no longer returns a Future). The existing code already calls it without `await`, so no change is needed here. Verify the call at line 134 is just `review.deleteCurrent();` (no `await`).

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 7: Commit**

```bash
git add lib/screens/review_screen.dart
git commit -m "feat: three-button leave dialog with Save & Exit / Discard & Exit"
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
