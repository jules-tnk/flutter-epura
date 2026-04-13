import 'dart:io';

import 'package:flutter/material.dart';

import '../models/review_item.dart';
import '../models/review_session.dart';
import '../services/database_service.dart';
import '../services/document_access_service.dart';
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
  final List<ReviewItem> failedItems;

  const _DeletionExecutionResult({
    required this.bytesFreed,
    required this.failedItems,
  });
}

class ReviewProvider extends ChangeNotifier {
  final DocumentAccessService _documentAccessService;

  ReviewProvider(this._documentAccessService);

  List<ReviewItem> _queue = [];
  int _currentIndex = 0;

  int _keptCount = 0;
  int _deletedCount = 0;
  int _skippedCount = 0;
  int _bytesFreed = 0;
  int _lastFailedDeletionCount = 0;
  List<ReviewItem> _pendingDeletions = [];

  List<ReviewItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  int get keptCount => _keptCount;
  int get deletedCount => _deletedCount;
  int get skippedCount => _skippedCount;
  int get bytesFreed => _bytesFreed;
  int get lastFailedDeletionCount => _lastFailedDeletionCount;
  int get pendingDeletionCount => _pendingDeletions.length;

  bool get isComplete => _currentIndex >= _queue.length;

  String get progress => '${_currentIndex + (isComplete ? 0 : 1)}/${_queue.length}';

  void startReview(List<ReviewItem> items) {
    _queue = List.of(items);
    _currentIndex = 0;
    _keptCount = 0;
    _deletedCount = 0;
    _skippedCount = 0;
    _bytesFreed = 0;
    _lastFailedDeletionCount = 0;
    _pendingDeletions = [];
    notifyListeners();
  }

  void keepCurrent() {
    if (isComplete) return;
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
    final failedItems = <ReviewItem>[];

    for (final item in deletions) {
      final deleted = await _deleteItem(item);
      if (deleted) {
        bytesFreed += item.size;
      } else {
        failedItems.add(item);
      }
      done++;
      onProgress?.call(done, total);
    }

    return _DeletionExecutionResult(
      bytesFreed: bytesFreed,
      failedItems: failedItems,
    );
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
    _skippedCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<ReviewCompletionResult> completeSession(
    DatabaseService db,
    SettingsProvider settings, {
    void Function(int done, int total)? onProgress,
  }) async {
    final reviewedItems = _queue.take(_currentIndex).toList();
    final remainingItems = _queue.skip(_currentIndex).toList();
    final deletionResult =
        await _executePendingDeletions(onProgress: onProgress);

    _bytesFreed = deletionResult.bytesFreed;
    _lastFailedDeletionCount = deletionResult.failedItems.length;
    notifyListeners();

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
    }

    return ReviewCompletionResult(
      reviewedItems: reviewedItems,
      remainingItems: remainingItems,
      failedDeletionItems: deletionResult.failedItems,
    );
  }
}
