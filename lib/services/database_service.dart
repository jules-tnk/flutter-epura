import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/review_session.dart';

class DatabaseService {
  static const String _dbName = 'epura.db';
  static const String _tableName = 'review_sessions';
  static const int _dbVersion = 1;

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            keptCount INTEGER NOT NULL,
            deletedCount INTEGER NOT NULL,
            skippedCount INTEGER NOT NULL,
            bytesFreed INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Database get _database {
    if (_db == null) {
      throw StateError('DatabaseService has not been initialised. Call init() first.');
    }
    return _db!;
  }

  Future<int> insertSession(ReviewSession session) async {
    return _database.insert(
      _tableName,
      {
        'date': session.date.toIso8601String(),
        'keptCount': session.keptCount,
        'deletedCount': session.deletedCount,
        'skippedCount': session.skippedCount,
        'bytesFreed': session.bytesFreed,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReviewSession>> getSessions({int limit = 50}) async {
    final rows = await _database.query(
      _tableName,
      orderBy: 'date DESC',
      limit: limit,
    );

    return rows.map((row) {
      return ReviewSession(
        id: row['id'].toString(),
        date: DateTime.parse(row['date'] as String),
        keptCount: row['keptCount'] as int,
        deletedCount: row['deletedCount'] as int,
        skippedCount: row['skippedCount'] as int,
        bytesFreed: row['bytesFreed'] as int,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final result = await _database.rawQuery('''
      SELECT
        COALESCE(SUM(bytesFreed), 0) as totalBytesFreed,
        COALESCE(SUM(keptCount + deletedCount + skippedCount), 0) as totalFilesReviewed,
        COALESCE(SUM(deletedCount), 0) as totalDeleted,
        COALESCE(COUNT(*), 0) as sessionCount
      FROM $_tableName
    ''');

    final row = result.first;
    return {
      'totalBytesFreed': row['totalBytesFreed'] as int,
      'totalFilesReviewed': row['totalFilesReviewed'] as int,
      'totalDeleted': row['totalDeleted'] as int,
      'sessionCount': row['sessionCount'] as int,
    };
  }

  Future<int> getStreak() async {
    final rows = await _database.rawQuery(
      'SELECT DISTINCT date(date) as day FROM $_tableName ORDER BY day DESC',
    );

    if (rows.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final sessionDays = <DateTime>{};
    for (final row in rows) {
      final parts = (row['day'] as String).split('-');
      sessionDays.add(DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ));
    }

    DateTime cursor = todayDate;
    if (!sessionDays.contains(cursor)) {
      cursor = todayDate.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (sessionDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
