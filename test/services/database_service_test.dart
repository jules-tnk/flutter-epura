import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/indexed_file.dart';
import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_group_dismissal.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/services/database_service.dart';
import 'package:epura/services/epura_database.dart';

void main() {
  group('DatabaseService', () {
    test('stores and reads app persistence models through Drift', () async {
      final database = DatabaseService(
        database: EpuraDatabase(NativeDatabase.memory()),
      );
      await database.init();
      addTearDown(database.close);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 8);
      final yesterday = today.subtract(const Duration(days: 1));

      await database.insertSession(
        ReviewSession(
          id: 'ignored',
          date: today,
          keptCount: 2,
          deletedCount: 3,
          skippedCount: 1,
          bytesFreed: 4096,
        ),
      );
      await database.insertSession(
        ReviewSession(
          id: 'ignored-2',
          date: yesterday,
          keptCount: 1,
          deletedCount: 1,
          skippedCount: 0,
          bytesFreed: 2048,
        ),
      );

      await database.upsertReviewDecisions([
        ReviewDecision(
          fileKey: 'file-a',
          type: ReviewDecisionType.later,
          decidedAt: today,
        ),
        ReviewDecision(
          fileKey: 'file-b',
          type: ReviewDecisionType.neverAskAgain,
          decidedAt: yesterday,
        ),
      ]);
      await database.upsertIndexedFiles([
        IndexedFile(
          fileKey: 'file-a',
          source: 'folder',
          fileType: 'image',
          size: 1024,
          modifiedAt: today,
          indexedAt: today,
          folderUri: 'content://folder',
          mimeType: 'image/jpeg',
        ),
      ]);
      await database.upsertReviewGroupDismissal(
        ReviewGroupDismissal(
          groupKey: 'group-a',
          mode: 'duplicates',
          dismissedAt: today,
        ),
      );

      final stats = await database.getStats();
      expect(stats['totalBytesFreed'], 6144);
      expect(stats['totalFilesReviewed'], 8);
      expect(stats['totalDeleted'], 4);
      expect(stats['sessionCount'], 2);
      expect(await database.getStreak(), greaterThanOrEqualTo(2));

      expect(await database.getSessions(), hasLength(2));
      expect(
        await database.getReviewDecisionsForKeys(['file-a', 'file-b']),
        hasLength(2),
      );
      expect(
        await database.getIndexedFilesForFolder('content://folder'),
        hasLength(1),
      );
      expect(await database.getDismissedReviewGroupKeys('duplicates'), {
        'group-a',
      });
    });

    test(
      'migrates an existing version 1 database without losing sessions',
      () async {
        final database = DatabaseService(
          database: EpuraDatabase(
            NativeDatabase.memory(setup: _createLegacyVersionOneSchema),
          ),
        );
        await database.init();
        addTearDown(database.close);

        final sessions = await database.getSessions();
        expect(sessions, hasLength(1));
        expect(sessions.single.bytesFreed, 1234);

        await database.upsertReviewDecisions([
          ReviewDecision(
            fileKey: 'file-a',
            type: ReviewDecisionType.later,
            decidedAt: DateTime(2026, 5, 31),
          ),
        ]);
        await database.upsertIndexedFiles([
          IndexedFile(
            fileKey: 'file-a',
            source: 'folder',
            fileType: 'image',
            size: 10,
            modifiedAt: DateTime(2026, 5, 31),
            indexedAt: DateTime(2026, 5, 31),
            folderUri: 'content://folder',
          ),
        ]);

        expect(await database.getReviewDecisions(), hasLength(1));
        expect(
          await database.getIndexedFilesForFolder('content://folder'),
          hasLength(1),
        );
      },
    );

    test('opens an existing version 5 sqflite-shaped database', () async {
      final epuraDatabase = EpuraDatabase(
        NativeDatabase.memory(setup: _createLegacyVersionFiveSchema),
      );
      final database = DatabaseService(database: epuraDatabase);
      await database.init();
      addTearDown(database.close);

      final stats = await database.getStats();
      expect(stats['totalBytesFreed'], 1234);
      expect(stats['sessionCount'], 1);
      expect(await database.getReviewDecisions(), hasLength(1));
      expect(
        await database.getIndexedFilesForFolder('content://folder'),
        hasLength(1),
      );
      expect(await database.getDismissedReviewGroupKeys('duplicates'), {
        'group-a',
      });
      final mediaFingerprintTables = await epuraDatabase
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'media_fingerprints'",
          )
          .get();
      expect(mediaFingerprintTables, isEmpty);
    });
  });
}

void _createLegacyVersionOneSchema(dynamic database) {
  database.execute('''
    CREATE TABLE review_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      keptCount INTEGER NOT NULL,
      deletedCount INTEGER NOT NULL,
      skippedCount INTEGER NOT NULL,
      bytesFreed INTEGER NOT NULL
    )
  ''');
  database.execute('''
    INSERT INTO review_sessions (
      date,
      keptCount,
      deletedCount,
      skippedCount,
      bytesFreed
    ) VALUES ('2026-05-31T10:00:00.000', 1, 2, 0, 1234)
  ''');
  database.execute('PRAGMA user_version = 1');
}

void _createLegacyVersionFiveSchema(dynamic database) {
  _createLegacyVersionOneSchema(database);
  database.execute('''
    CREATE TABLE review_decisions (
      fileKey TEXT PRIMARY KEY,
      decision TEXT NOT NULL,
      decidedAt TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE INDEX idx_review_decisions_decision
    ON review_decisions(decision)
  ''');
  database.execute('''
    INSERT INTO review_decisions (fileKey, decision, decidedAt)
    VALUES ('file-a', 'later', '2026-05-31T10:00:00.000')
  ''');
  database.execute('''
    CREATE TABLE file_index (
      fileKey TEXT PRIMARY KEY,
      source TEXT NOT NULL,
      fileType TEXT NOT NULL,
      size INTEGER NOT NULL,
      modifiedAt TEXT NOT NULL,
      indexedAt TEXT NOT NULL,
      folderUri TEXT,
      mimeType TEXT
    )
  ''');
  database.execute('''
    CREATE INDEX idx_file_index_folder
    ON file_index(folderUri)
  ''');
  database.execute('''
    INSERT INTO file_index (
      fileKey,
      source,
      fileType,
      size,
      modifiedAt,
      indexedAt,
      folderUri,
      mimeType
    ) VALUES (
      'file-a',
      'folder',
      'image',
      10,
      '2026-05-31T10:00:00.000',
      '2026-05-31T10:00:00.000',
      'content://folder',
      'image/jpeg'
    )
  ''');
  database.execute('''
    CREATE TABLE dismissed_review_groups (
      groupKey TEXT PRIMARY KEY,
      mode TEXT NOT NULL,
      dismissedAt TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE INDEX idx_dismissed_review_groups_mode
    ON dismissed_review_groups(mode)
  ''');
  database.execute('''
    INSERT INTO dismissed_review_groups (groupKey, mode, dismissedAt)
    VALUES ('group-a', 'duplicates', '2026-05-31T10:00:00.000')
  ''');
  database.execute('PRAGMA user_version = 5');
}
