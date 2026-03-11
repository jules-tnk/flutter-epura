import 'dart:io';

import 'package:flutter/material.dart';

import '../models/review_item.dart';
import '../models/review_session.dart';
import '../services/database_service.dart';
import 'settings_provider.dart';

class ReviewProvider extends ChangeNotifier {
  List<ReviewItem> _queue = [];
  int _currentIndex = 0;

  int _keptCount = 0;
  int _deletedCount = 0;
  int _skippedCount = 0;
  int _bytesFreed = 0;
  List<ReviewItem> _pendingDeletions = [];

  List<ReviewItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  int get keptCount => _keptCount;
  int get deletedCount => _deletedCount;
  int get skippedCount => _skippedCount;
  int get bytesFreed => _bytesFreed;

  ReviewItem? get currentItem =>
      isComplete ? null : _queue[_currentIndex];

  bool get isComplete => _currentIndex >= _queue.length;

  String get progress =>
      '${_currentIndex + (isComplete ? 0 : 1)}/${_queue.length}';

  void startReview(List<ReviewItem> items) {
    _queue = List.of(items);
    _currentIndex = 0;
    _keptCount = 0;
    _deletedCount = 0;
    _skippedCount = 0;
    _bytesFreed = 0;
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
    final item = _queue[_currentIndex];

    _pendingDeletions.add(item);
    _bytesFreed += item.size;
    _deletedCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<void> executePendingDeletions() async {
    final deletions = _pendingDeletions;
    _pendingDeletions = [];
    await Future.wait(deletions.map((item) async {
      try {
        await File(item.path).delete();
      } catch (_) {
        // Silently skip files that can't be deleted
      }
    }));
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
}
