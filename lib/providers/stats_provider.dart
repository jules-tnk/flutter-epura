import 'package:flutter/material.dart';

import '../models/review_session.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  bool _isLoading = false;
  double _loadProgress = 0.0;
  List<ReviewSession> _sessions = [];
  int _totalBytesFreed = 0;
  int _totalFilesReviewed = 0;
  int _totalDeleted = 0;
  int _streak = 0;
  int _weeklyBytesFreed = 0;

  bool get isLoading => _isLoading;
  double get loadProgress => _loadProgress;
  List<ReviewSession> get sessions => List.unmodifiable(_sessions);
  int get totalBytesFreed => _totalBytesFreed;
  int get totalFilesReviewed => _totalFilesReviewed;
  int get totalDeleted => _totalDeleted;
  int get streak => _streak;
  int get weeklyBytesFreed => _weeklyBytesFreed;

  Future<void> loadStats(DatabaseService db) async {
    _isLoading = true;
    _loadProgress = 0.0;
    notifyListeners();

    try {
      int completed = 0;
      void step() {
        completed++;
        _loadProgress = completed / 3;
        notifyListeners();
      }

      _sessions = await db.getSessions();
      step();

      final stats = await db.getStats();
      step();

      _streak = await db.getStreak();
      step();

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
