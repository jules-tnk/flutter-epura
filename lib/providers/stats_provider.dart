import 'package:flutter/material.dart';

import '../models/review_session.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<ReviewSession> _sessions = [];
  int _totalBytesFreed = 0;
  int _totalFilesReviewed = 0;
  int _totalDeleted = 0;
  int _streak = 0;
  int _weeklyBytesFreed = 0;

  bool get isLoading => _isLoading;
  List<ReviewSession> get sessions => List.unmodifiable(_sessions);
  int get totalBytesFreed => _totalBytesFreed;
  int get totalFilesReviewed => _totalFilesReviewed;
  int get totalDeleted => _totalDeleted;
  int get streak => _streak;
  int get weeklyBytesFreed => _weeklyBytesFreed;

  Future<void> loadStats(DatabaseService db) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        db.getSessions(),
        db.getStats(),
        db.getStreak(),
      ]);

      _sessions = results[0] as List<ReviewSession>;
      final stats = results[1] as Map<String, dynamic>;
      _streak = results[2] as int;

      _totalBytesFreed = (stats['totalBytesFreed'] as int?) ?? 0;
      _totalFilesReviewed = (stats['totalFilesReviewed'] as int?) ?? 0;
      _totalDeleted = (stats['totalDeleted'] as int?) ?? 0;

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      _weeklyBytesFreed = _sessions
          .where((s) => s.date.isAfter(weekAgo))
          .fold(0, (sum, s) => sum + s.bytesFreed);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
