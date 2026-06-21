import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

part 'epura_database.g.dart';

const String epuraDatabaseName = 'epura.db';
const int epuraDatabaseSchemaVersion = 6;

@DataClassName('ReviewSessionRow')
class ReviewSessions extends Table {
  @override
  String get tableName => 'review_sessions';

  late final id = integer().autoIncrement()();
  late final date = text()();
  late final keptCount = integer().named('keptCount')();
  late final deletedCount = integer().named('deletedCount')();
  late final skippedCount = integer().named('skippedCount')();
  late final bytesFreed = integer().named('bytesFreed')();
}

@DataClassName('ReviewDecisionRow')
@TableIndex(name: 'idx_review_decisions_decision', columns: {#decision})
class ReviewDecisions extends Table {
  @override
  String get tableName => 'review_decisions';

  late final fileKey = text().named('fileKey')();
  late final decision = text()();
  late final decidedAt = text().named('decidedAt')();

  @override
  Set<Column<Object>> get primaryKey => {fileKey};
}

@DataClassName('IndexedFileRow')
@TableIndex(name: 'idx_file_index_folder', columns: {#folderUri})
class FileIndexEntries extends Table {
  @override
  String get tableName => 'file_index';

  late final fileKey = text().named('fileKey')();
  late final source = text()();
  late final fileType = text().named('fileType')();
  late final size = integer()();
  late final modifiedAt = text().named('modifiedAt')();
  late final indexedAt = text().named('indexedAt')();
  late final folderUri = text().named('folderUri').nullable()();
  late final mimeType = text().named('mimeType').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {fileKey};
}

@DataClassName('DismissedReviewGroupRow')
@TableIndex(name: 'idx_dismissed_review_groups_mode', columns: {#mode})
class DismissedReviewGroups extends Table {
  @override
  String get tableName => 'dismissed_review_groups';

  late final groupKey = text().named('groupKey')();
  late final mode = text()();
  late final dismissedAt = text().named('dismissedAt')();

  @override
  Set<Column<Object>> get primaryKey => {groupKey};
}

@DriftDatabase(
  tables: [
    ReviewSessions,
    ReviewDecisions,
    FileIndexEntries,
    DismissedReviewGroups,
  ],
)
class EpuraDatabase extends _$EpuraDatabase {
  EpuraDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => epuraDatabaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(reviewDecisions);
      }
      if (from < 3) {
        await migrator.createTable(fileIndexEntries);
      }
      if (from < 5) {
        await migrator.createTable(dismissedReviewGroups);
      }
      if (from < 6) {
        await customStatement('DROP TABLE IF EXISTS media_fingerprints');
      }
    },
  );

  static QueryExecutor _openConnection() {
    return SqfliteQueryExecutor.inDatabaseFolder(path: epuraDatabaseName);
  }
}
