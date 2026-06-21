import 'dart:io';

import 'package:flutter/material.dart';
import '../models/review_decision.dart';
import '../models/review_item.dart';
import '../models/review_mode.dart';
import '../models/review_session.dart';
import '../services/database_service.dart';
import '../services/document_access_service.dart';
import '../services/file_identity_service.dart';
import '../services/media_library_deletion_service.dart';
import 'settings_provider.dart';

class ReviewCompletionResult {
  final List<ReviewItem> reviewedItems;
  final List<ReviewItem> remainingItems;
  final List<ReviewItem> failedDeletionItems;

  const ReviewCompletionResult({
    required this.reviewedItems,
    required this.remainingItems,
    required this.failedDeletionItems,
  });
}

class _DeletionExecutionResult {
  final int bytesFreed;
  final int trashedCount;
  final int permanentDeletionCount;
  final List<ReviewItem> failedItems;

  const _DeletionExecutionResult({
    required this.bytesFreed,
    required this.trashedCount,
    required this.permanentDeletionCount,
    required this.failedItems,
  });
}

class ReviewProvider extends ChangeNotifier {
  final DocumentAccessService _documentAccessService;
  final MediaLibraryDeletionService _mediaLibraryDeletionService;

  ReviewProvider(
    this._documentAccessService, {
    MediaLibraryDeletionService mediaLibraryDeletionService =
        const PhotoManagerMediaLibraryDeletionService(),
  }) : _mediaLibraryDeletionService = mediaLibraryDeletionService;

  List<ReviewItem> _queue = [];
  int _currentIndex = 0;

  int _keptCount = 0;
  int _deletedCount = 0;
  int _skippedCount = 0;
  int _bytesFreed = 0;
  int _lastFailedDeletionCount = 0;
  int _lastTrashedCount = 0;
  int _lastPermanentDeletionCount = 0;
  List<ReviewItem> _pendingDeletions = [];
  ReviewMode _reviewMode = const ReviewMode.recent();
  final List<ReviewItem> _keptItems = [];
  final List<ReviewItem> _skippedItems = [];
  final List<ReviewItem> _neverAskAgainItems = [];

  List<ReviewItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  int get keptCount => _keptCount;
  int get deletedCount => _deletedCount;
  int get skippedCount => _skippedCount;
  int get bytesFreed => _bytesFreed;
  int get lastFailedDeletionCount => _lastFailedDeletionCount;
  int get lastTrashedCount => _lastTrashedCount;
  int get lastPermanentDeletionCount => _lastPermanentDeletionCount;
  int get pendingDeletionCount => _pendingDeletions.length;

  bool get isComplete => _currentIndex >= _queue.length;

  String get progress =>
      '${_currentIndex + (isComplete ? 0 : 1)}/${_queue.length}';

  void startReview(
    List<ReviewItem> items, {
    ReviewMode reviewMode = const ReviewMode.recent(),
  }) {
    _queue = List.of(items);
    _reviewMode = reviewMode;
    _currentIndex = 0;
    _keptCount = 0;
    _deletedCount = 0;
    _skippedCount = 0;
    _bytesFreed = 0;
    _lastFailedDeletionCount = 0;
    _lastTrashedCount = 0;
    _lastPermanentDeletionCount = 0;
    _pendingDeletions = [];
    _keptItems.clear();
    _skippedItems.clear();
    _neverAskAgainItems.clear();
    notifyListeners();
  }

  void keepCurrent() {
    if (isComplete) return;
    _keptItems.add(_queue[_currentIndex]);
    _keptCount++;
    _currentIndex++;
    notifyListeners();
  }

  void deleteCurrent() {
    if (isComplete) return;
    _pendingDeletions.add(_queue[_currentIndex]);
    _deletedCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<_DeletionExecutionResult> _executePendingDeletions({
    void Function(int done, int total)? onProgress,
  }) async {
    final deletions = List.of(_pendingDeletions);
    _pendingDeletions = [];
    final total = deletions.length;
    var done = 0;
    var bytesFreed = 0;
    var trashedCount = 0;
    var permanentDeletionCount = 0;
    final failedItems = <ReviewItem>[];

    final mediaLibraryItems = deletions
        .where((item) => item.source == ReviewItemSource.mediaLibrary)
        .toList();
    final otherItems = deletions
        .where((item) => item.source != ReviewItemSource.mediaLibrary)
        .toList();

    if (mediaLibraryItems.isNotEmpty) {
      final mediaDeletionResult = await _deleteMediaLibraryItems(
        mediaLibraryItems,
      );
      bytesFreed += mediaDeletionResult.bytesFreed;
      trashedCount += mediaDeletionResult.trashedCount;
      permanentDeletionCount += mediaDeletionResult.permanentDeletionCount;
      failedItems.addAll(mediaDeletionResult.failedItems);
      done += mediaLibraryItems.length;
      onProgress?.call(done, total);
    }

    for (final item in otherItems) {
      final deleted = await _deleteItem(item);
      if (deleted) {
        bytesFreed += item.size;
        permanentDeletionCount++;
      } else {
        failedItems.add(item);
      }
      done++;
      onProgress?.call(done, total);
    }

    return _DeletionExecutionResult(
      bytesFreed: bytesFreed,
      trashedCount: trashedCount,
      permanentDeletionCount: permanentDeletionCount,
      failedItems: failedItems,
    );
  }

  Future<_DeletionExecutionResult> _deleteMediaLibraryItems(
    List<ReviewItem> items,
  ) async {
    try {
      final result = await _mediaLibraryDeletionService.removeFromLibrary(
        items,
      );
      var bytesFreed = 0;
      var trashedCount = 0;
      var permanentDeletionCount = 0;
      final failedItems = <ReviewItem>[];

      for (final item in items) {
        if (result.trashedIds.contains(item.id)) {
          trashedCount++;
        } else if (result.permanentlyDeletedIds.contains(item.id)) {
          bytesFreed += item.size;
          permanentDeletionCount++;
        } else {
          failedItems.add(item);
        }
      }

      return _DeletionExecutionResult(
        bytesFreed: bytesFreed,
        trashedCount: trashedCount,
        permanentDeletionCount: permanentDeletionCount,
        failedItems: failedItems,
      );
    } catch (_) {
      return _DeletionExecutionResult(
        bytesFreed: 0,
        trashedCount: 0,
        permanentDeletionCount: 0,
        failedItems: items,
      );
    }
  }

  Future<bool> _deleteItem(ReviewItem item) async {
    try {
      if (item.isUriBacked) {
        return await _documentAccessService.deleteDocument(item.contentUri!);
      }
      await File(item.path!).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  void discardSession() {
    startReview([]);
  }

  void skipCurrent() {
    if (isComplete) return;
    _skippedItems.add(_queue[_currentIndex]);
    _skippedCount++;
    _currentIndex++;
    notifyListeners();
  }

  void neverAskAgainCurrent() {
    if (isComplete) return;
    _neverAskAgainItems.add(_queue[_currentIndex]);
    _keptCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<void> _persistDecisionMemory(
    DatabaseService db, {
    required List<ReviewItem> pendingDeletionItems,
    required List<ReviewItem> failedDeletionItems,
  }) async {
    final now = DateTime.now();
    final decisionsToUpsert = <ReviewDecision>[];

    for (final item in _skippedItems) {
      final decision = _decisionForItem(item, ReviewDecisionType.later, now);
      if (decision != null) decisionsToUpsert.add(decision);
    }

    for (final item in _neverAskAgainItems) {
      final decision = _decisionForItem(
        item,
        ReviewDecisionType.neverAskAgain,
        now,
      );
      if (decision != null) decisionsToUpsert.add(decision);
    }

    final failedKeys = failedDeletionItems
        .map(FileIdentityService.keyFor)
        .whereType<String>()
        .toSet();
    final successfulDeletionKeys = pendingDeletionItems
        .map(FileIdentityService.keyFor)
        .whereType<String>()
        .where((key) => !failedKeys.contains(key));
    final clearKeys = {
      ..._keptItems.map(FileIdentityService.keyFor).whereType<String>(),
      ...successfulDeletionKeys,
      ...failedKeys,
    };

    if (clearKeys.isNotEmpty) {
      await db.clearReviewDecisionsForKeys(clearKeys);
    }
    if (decisionsToUpsert.isNotEmpty) {
      await db.upsertReviewDecisions(decisionsToUpsert);
    }
  }

  ReviewDecision? _decisionForItem(
    ReviewItem item,
    ReviewDecisionType type,
    DateTime decidedAt,
  ) {
    final key = FileIdentityService.keyFor(item);
    if (key == null) return null;
    return ReviewDecision(fileKey: key, type: type, decidedAt: decidedAt);
  }

  Future<ReviewCompletionResult> completeSession(
    DatabaseService db,
    SettingsProvider settings, {
    void Function(int done, int total)? onProgress,
  }) async {
    final reviewedItems = _queue.take(_currentIndex).toList();
    final remainingItems = _queue.skip(_currentIndex).toList();
    final pendingDeletionItems = List<ReviewItem>.of(_pendingDeletions);
    final deletionResult = await _executePendingDeletions(
      onProgress: onProgress,
    );

    final failedDeletionCount = deletionResult.failedItems.length;
    if (failedDeletionCount > 0) {
      _deletedCount -= failedDeletionCount;
      _keptCount += failedDeletionCount;
    }
    _bytesFreed = deletionResult.bytesFreed;
    _lastFailedDeletionCount = failedDeletionCount;
    _lastTrashedCount = deletionResult.trashedCount;
    _lastPermanentDeletionCount = deletionResult.permanentDeletionCount;
    notifyListeners();

    await _persistDecisionMemory(
      db,
      pendingDeletionItems: pendingDeletionItems,
      failedDeletionItems: deletionResult.failedItems,
    );

    final totalDecisions = _keptCount + _deletedCount + _skippedCount;
    if (totalDecisions > 0) {
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
      if (_reviewMode.type == ReviewModeType.folder &&
          _reviewMode.folderUri != null) {
        await settings.markFolderReviewed(_reviewMode.folderUri!, now);
      }
      await settings.recordSuccessfulReviewSession(
        hadFailedDeletions: failedDeletionCount > 0,
      );
    }

    return ReviewCompletionResult(
      reviewedItems: reviewedItems,
      remainingItems: remainingItems,
      failedDeletionItems: deletionResult.failedItems,
    );
  }
}
