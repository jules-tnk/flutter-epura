import 'package:drift/drift.dart';

import '../models/indexed_file.dart';
import '../models/review_decision.dart';
import '../models/review_group_dismissal.dart';
import '../models/review_session.dart';
import 'epura_database.dart';

class DatabaseService {
  static const int _maxSqlVariablesPerQuery = 900;

  EpuraDatabase? _db;

  DatabaseService({EpuraDatabase? database}) : _db = database;

  Future<void> init() async {
    _db ??= EpuraDatabase();
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  EpuraDatabase get _database {
    final db = _db;
    if (db == null) {
      throw StateError(
        'DatabaseService has not been initialised. Call init() first.',
      );
    }
    return db;
  }

  Future<int> insertSession(ReviewSession session) async {
    final table = _database.reviewSessions;
    return _database
        .into(table)
        .insert(
          ReviewSessionsCompanion.insert(
            date: _encodeDate(session.date),
            keptCount: session.keptCount,
            deletedCount: session.deletedCount,
            skippedCount: session.skippedCount,
            bytesFreed: session.bytesFreed,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<List<ReviewSession>> getSessions({int limit = 50}) async {
    final table = _database.reviewSessions;
    final query = _database.select(table)
      ..orderBy([(table) => OrderingTerm.desc(table.date)])
      ..limit(limit);
    final rows = await query.get();

    return rows.map(_reviewSessionFromRow).toList();
  }

  Future<int> clearReviewSessions() async {
    return _database.delete(_database.reviewSessions).go();
  }

  Future<void> upsertReviewDecisions(List<ReviewDecision> decisions) async {
    if (decisions.isEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.reviewDecisions,
        decisions.map(_reviewDecisionToCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> clearReviewDecisionsForKeys(Iterable<String> fileKeys) async {
    final keys = fileKeys.toSet();
    if (keys.isEmpty) return;

    final table = _database.reviewDecisions;
    for (final chunk in _chunks(keys)) {
      final query = _database.delete(table)
        ..where((row) => row.fileKey.isIn(chunk));
      await query.go();
    }
  }

  Future<List<ReviewDecision>> getReviewDecisions() async {
    final table = _database.reviewDecisions;
    final query = _database.select(table)
      ..orderBy([(table) => OrderingTerm.desc(table.decidedAt)]);
    final rows = await query.get();

    return rows.map(_reviewDecisionFromRow).toList();
  }

  Future<Map<String, ReviewDecision>> getReviewDecisionsForKeys(
    Iterable<String> fileKeys,
  ) async {
    final keys = fileKeys.toSet();
    if (keys.isEmpty) return const {};

    final decisions = <String, ReviewDecision>{};
    final table = _database.reviewDecisions;
    for (final chunk in _chunks(keys)) {
      final query = _database.select(table)
        ..where((row) => row.fileKey.isIn(chunk));
      final rows = await query.get();
      for (final row in rows) {
        decisions[row.fileKey] = _reviewDecisionFromRow(row);
      }
    }
    return decisions;
  }

  Future<int> clearReviewDecisions() async {
    return _database.delete(_database.reviewDecisions).go();
  }

  Future<void> upsertIndexedFiles(List<IndexedFile> files) async {
    if (files.isEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.fileIndexEntries,
        files.map(_indexedFileToCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<IndexedFile>> getIndexedFilesForFolder(String folderUri) async {
    final table = _database.fileIndexEntries;
    final query = _database.select(table)
      ..where((row) => row.folderUri.equals(folderUri))
      ..orderBy([(table) => OrderingTerm.desc(table.modifiedAt)]);
    final rows = await query.get();

    return rows.map(_indexedFileFromRow).toList();
  }

  Future<int> clearFileIndexForFolder(String folderUri) async {
    final table = _database.fileIndexEntries;
    final query = _database.delete(table)
      ..where((row) => row.folderUri.equals(folderUri));
    return query.go();
  }

  Future<int> clearFileIndex() async {
    return _database.delete(_database.fileIndexEntries).go();
  }

  Future<void> upsertReviewGroupDismissal(
    ReviewGroupDismissal dismissal,
  ) async {
    final table = _database.dismissedReviewGroups;
    await _database
        .into(table)
        .insert(
          DismissedReviewGroupsCompanion.insert(
            groupKey: dismissal.groupKey,
            mode: dismissal.mode,
            dismissedAt: _encodeDate(dismissal.dismissedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<Set<String>> getDismissedReviewGroupKeys(String mode) async {
    final table = _database.dismissedReviewGroups;
    final query = _database.select(table)
      ..where((row) => row.mode.equals(mode));
    final rows = await query.get();

    return rows.map((row) => row.groupKey).toSet();
  }

  Future<int> clearReviewGroupDismissals() async {
    return _database.delete(_database.dismissedReviewGroups).go();
  }

  Future<Map<String, dynamic>> getStats() async {
    final rows = await _database.select(_database.reviewSessions).get();
    var totalBytesFreed = 0;
    var totalFilesReviewed = 0;
    var totalDeleted = 0;

    for (final row in rows) {
      totalBytesFreed += row.bytesFreed;
      totalFilesReviewed += row.keptCount + row.deletedCount + row.skippedCount;
      totalDeleted += row.deletedCount;
    }

    return {
      'totalBytesFreed': totalBytesFreed,
      'totalFilesReviewed': totalFilesReviewed,
      'totalDeleted': totalDeleted,
      'sessionCount': rows.length,
    };
  }

  Future<int> getStreak() async {
    final table = _database.reviewSessions;
    final query = _database.select(table)
      ..orderBy([(table) => OrderingTerm.desc(table.date)]);
    final rows = await query.get();

    if (rows.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final sessionDays = rows.map((row) {
      final date = _decodeDate(row.date);
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    var cursor = todayDate;
    if (!sessionDays.contains(cursor)) {
      cursor = todayDate.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (sessionDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  ReviewSession _reviewSessionFromRow(ReviewSessionRow row) {
    return ReviewSession(
      id: row.id.toString(),
      date: _decodeDate(row.date),
      keptCount: row.keptCount,
      deletedCount: row.deletedCount,
      skippedCount: row.skippedCount,
      bytesFreed: row.bytesFreed,
    );
  }

  ReviewDecisionsCompanion _reviewDecisionToCompanion(ReviewDecision decision) {
    return ReviewDecisionsCompanion.insert(
      fileKey: decision.fileKey,
      decision: decision.type.storageValue,
      decidedAt: _encodeDate(decision.decidedAt),
    );
  }

  ReviewDecision _reviewDecisionFromRow(ReviewDecisionRow row) {
    return ReviewDecision(
      fileKey: row.fileKey,
      type: ReviewDecisionType.fromStorage(row.decision),
      decidedAt: _decodeDate(row.decidedAt),
    );
  }

  FileIndexEntriesCompanion _indexedFileToCompanion(IndexedFile file) {
    return FileIndexEntriesCompanion.insert(
      fileKey: file.fileKey,
      source: file.source,
      fileType: file.fileType,
      size: file.size,
      modifiedAt: _encodeDate(file.modifiedAt),
      indexedAt: _encodeDate(file.indexedAt),
      folderUri: Value(file.folderUri),
      mimeType: Value(file.mimeType),
    );
  }

  IndexedFile _indexedFileFromRow(IndexedFileRow row) {
    return IndexedFile(
      fileKey: row.fileKey,
      source: row.source,
      fileType: row.fileType,
      size: row.size,
      modifiedAt: _decodeDate(row.modifiedAt),
      indexedAt: _decodeDate(row.indexedAt),
      folderUri: row.folderUri,
      mimeType: row.mimeType,
    );
  }

  String _encodeDate(DateTime date) => date.toIso8601String();

  DateTime _decodeDate(String value) => DateTime.parse(value);

  Iterable<List<T>> _chunks<T>(Iterable<T> values) sync* {
    var chunk = <T>[];
    for (final value in values) {
      chunk.add(value);
      if (chunk.length == _maxSqlVariablesPerQuery) {
        yield chunk;
        chunk = <T>[];
      }
    }
    if (chunk.isNotEmpty) yield chunk;
  }
}
