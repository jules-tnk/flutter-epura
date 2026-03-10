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
    notifyListeners();
  }

  void keepCurrent() {
    if (isComplete) return;
    _keptCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<void> deleteCurrent() async {
    if (isComplete) return;
    final item = _queue[_currentIndex];

    try {
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
        _bytesFreed += item.size;
      }
    } catch (_) {
      // If deletion fails, still advance the queue
    }

    _deletedCount++;
    _currentIndex++;
    notifyListeners();
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
