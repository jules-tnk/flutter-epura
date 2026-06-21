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
  int _monthlyBytesFreed = 0;
  int _monthlyFilesReviewed = 0;
  int _monthlyDeleted = 0;

  bool get isLoading => _isLoading;
  double get loadProgress => _loadProgress;
  List<ReviewSession> get sessions => List.unmodifiable(_sessions);
  int get totalBytesFreed => _totalBytesFreed;
  int get totalFilesReviewed => _totalFilesReviewed;
  int get totalDeleted => _totalDeleted;
  int get streak => _streak;
  int get weeklyBytesFreed => _weeklyBytesFreed;
  int get monthlyBytesFreed => _monthlyBytesFreed;
  int get monthlyFilesReviewed => _monthlyFilesReviewed;
  int get monthlyDeleted => _monthlyDeleted;

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

      final now = DateTime.now();
      final monthlySessions = _sessions
          .where((s) => s.date.year == now.year && s.date.month == now.month)
          .toList(growable: false);
      _monthlyBytesFreed = monthlySessions.fold(
        0,
        (sum, session) => sum + session.bytesFreed,
      );
      _monthlyFilesReviewed = monthlySessions.fold(
        0,
        (sum, session) => sum + session.totalReviewed,
      );
      _monthlyDeleted = monthlySessions.fold(
        0,
        (sum, session) => sum + session.deletedCount,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
