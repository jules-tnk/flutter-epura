import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/duplicate_group.dart';
import 'package:epura/models/burst_group.dart';
import 'package:epura/l10n/app_localizations.dart';
import 'package:epura/models/indexed_file.dart';
import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_group_dismissal.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/providers/file_service.dart';
import 'package:epura/providers/review_provider.dart';
import 'package:epura/providers/settings_provider.dart';
import 'package:epura/providers/stats_provider.dart';
import 'package:epura/services/database_service.dart';
import 'package:epura/services/document_access_service.dart';
import 'package:epura/services/duplicate_candidate_service.dart';
import 'package:epura/services/burst_candidate_service.dart';
import 'package:epura/services/media_library_deletion_service.dart';
import 'package:epura/services/notification_service.dart';
import 'package:epura/services/thumbnail_cache.dart';
import 'package:epura/theme/app_theme.dart';

class FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> requestExactAlarmPermission() async => true;

  @override
  Future<DateTime> scheduleReminder(
    TimeOfDay time,
    String interval,
    int dayOfWeek, {
    String? localeCode,
  }) async {
    return DateTime(2030, 1, 1, time.hour, time.minute);
  }

  @override
  Future<void> cancelReminder() async {}
}

class FakeDuplicateCandidateService extends DuplicateCandidateService {
  final List<DuplicateGroup> groups;

  const FakeDuplicateCandidateService(this.groups);

  @override
  Future<List<DuplicateGroup>> findExactPhotoGroups(
    List<ReviewItem> items,
  ) async {
    return groups;
  }
}

class FakeBurstCandidateService extends BurstCandidateService {
  final List<BurstGroup> groups;

  const FakeBurstCandidateService(this.groups);

  @override
  List<BurstGroup> findPhotoBurstGroups(List<ReviewItem> items) {
    return groups;
  }
}

ReviewItem testPhotoReviewItem(String id, String name) {
  return ReviewItem(
    id: id,
    name: name,
    path: 'C:/tmp/$name',
    size: 2048,
    type: FileItemType.photo,
    date: DateTime(2026, 5, 31),
    source: ReviewItemSource.mediaLibrary,
  );
}

class FakeDocumentAccessService implements DocumentAccessService {
  ScanFolderGrant? nextFolder;
  List<StorageDocument> nextPickedDocuments = const [];
  final Map<String, List<StorageDocument>> folderFilesByUri = {};
  final List<String> releasedUris = [];
  final List<String> deletedUris = [];
  final Set<String> deleteFailures = {};
  Completer<void>? deleteBarrier;
  Completer<void>? releaseBarrier;

  @override
  Future<ScanFolderGrant?> pickFolder() async => nextFolder;

  @override
  Future<List<StorageDocument>> pickDocuments() async => nextPickedDocuments;

  @override
  Future<List<StorageDocument>> listFolderFiles(String treeUri) async {
    return folderFilesByUri[treeUri] ?? const [];
  }

  @override
  Future<bool> deleteDocument(String uri) async {
    deletedUris.add(uri);
    final barrier = deleteBarrier;
    if (barrier != null) {
      await barrier.future;
    }
    return !deleteFailures.contains(uri);
  }

  @override
  Future<void> releasePersistedUriPermission(String uri) async {
    final barrier = releaseBarrier;
    if (barrier != null) {
      await barrier.future;
    }
    releasedUris.add(uri);
  }
}

class FakeDatabaseService extends DatabaseService {
  final List<ReviewSession> insertedSessions = [];
  final Map<String, ReviewDecision> decisionsByKey = {};
  final Map<String, IndexedFile> indexedFilesByKey = {};
  final Map<String, ReviewGroupDismissal> reviewGroupDismissalsByKey = {};
  int reviewStreak = 0;
  bool throwOnIndexUpsert = false;
  bool throwOnDecisionLookup = false;

  @override
  Future<void> init() async {}

  @override
  Future<int> insertSession(ReviewSession session) async {
    insertedSessions.add(session);
    return insertedSessions.length;
  }

  @override
  Future<List<ReviewSession>> getSessions({int limit = 50}) async {
    return insertedSessions.take(limit).toList();
  }

  @override
  Future<int> clearReviewSessions() async {
    final count = insertedSessions.length;
    insertedSessions.clear();
    return count;
  }

  @override
  Future<void> upsertReviewDecisions(List<ReviewDecision> decisions) async {
    for (final decision in decisions) {
      decisionsByKey[decision.fileKey] = decision;
    }
  }

  @override
  Future<void> clearReviewDecisionsForKeys(Iterable<String> fileKeys) async {
    for (final key in fileKeys) {
      decisionsByKey.remove(key);
    }
  }

  @override
  Future<List<ReviewDecision>> getReviewDecisions() async {
    return decisionsByKey.values.toList()
      ..sort((a, b) => b.decidedAt.compareTo(a.decidedAt));
  }

  @override
  Future<Map<String, ReviewDecision>> getReviewDecisionsForKeys(
    Iterable<String> fileKeys,
  ) async {
    if (throwOnDecisionLookup) {
      throw StateError('decision lookup failed');
    }

    final result = <String, ReviewDecision>{};
    for (final key in fileKeys) {
      final decision = decisionsByKey[key];
      if (decision != null) result[key] = decision;
    }
    return result;
  }

  @override
  Future<int> clearReviewDecisions() async {
    final count = decisionsByKey.length;
    decisionsByKey.clear();
    return count;
  }

  @override
  Future<void> upsertIndexedFiles(List<IndexedFile> files) async {
    if (throwOnIndexUpsert) {
      throw StateError('index write failed');
    }

    for (final file in files) {
      indexedFilesByKey[file.fileKey] = file;
    }
  }

  @override
  Future<List<IndexedFile>> getIndexedFilesForFolder(String folderUri) async {
    return indexedFilesByKey.values
        .where((file) => file.folderUri == folderUri)
        .toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  @override
  Future<int> clearFileIndexForFolder(String folderUri) async {
    final keys = indexedFilesByKey.entries
        .where((entry) => entry.value.folderUri == folderUri)
        .map((entry) => entry.key)
        .toList();
    for (final key in keys) {
      indexedFilesByKey.remove(key);
    }
    return keys.length;
  }

  @override
  Future<int> clearFileIndex() async {
    final count = indexedFilesByKey.length;
    indexedFilesByKey.clear();
    return count;
  }

  @override
  Future<void> upsertReviewGroupDismissal(
    ReviewGroupDismissal dismissal,
  ) async {
    reviewGroupDismissalsByKey[dismissal.groupKey] = dismissal;
  }

  @override
  Future<Set<String>> getDismissedReviewGroupKeys(String mode) async {
    return reviewGroupDismissalsByKey.values
        .where((dismissal) => dismissal.mode == mode)
        .map((dismissal) => dismissal.groupKey)
        .toSet();
  }

  @override
  Future<int> clearReviewGroupDismissals() async {
    final count = reviewGroupDismissalsByKey.length;
    reviewGroupDismissalsByKey.clear();
    return count;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    return {
      'totalBytesFreed': insertedSessions.fold<int>(
        0,
        (sum, session) => sum + session.bytesFreed,
      ),
      'totalFilesReviewed': insertedSessions.fold<int>(
        0,
        (sum, session) => sum + session.totalReviewed,
      ),
      'totalDeleted': insertedSessions.fold<int>(
        0,
        (sum, session) => sum + session.deletedCount,
      ),
      'sessionCount': insertedSessions.length,
    };
  }

  @override
  Future<int> getStreak() async => reviewStreak;
}

class TestContext {
  final FakeNotificationService notifications;
  final FakeDocumentAccessService documents;
  final SettingsProvider settings;
  final FileService fileService;
  final ReviewProvider reviewProvider;
  final FakeDatabaseService database;

  const TestContext({
    required this.notifications,
    required this.documents,
    required this.settings,
    required this.fileService,
    required this.reviewProvider,
    required this.database,
  });
}

Future<TestContext> createTestContext({
  Map<String, Object> prefs = const {},
  DuplicateCandidateService duplicateCandidateService =
      const DuplicateCandidateService(),
  BurstCandidateService burstCandidateService = const BurstCandidateService(),
  MediaLibraryDeletionService mediaLibraryDeletionService =
      const PhotoManagerMediaLibraryDeletionService(),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final notifications = FakeNotificationService();
  final documents = FakeDocumentAccessService();
  final settings = SettingsProvider(notifications, documents);
  await settings.init();
  final fileService = FileService(
    documents,
    duplicateCandidateService: duplicateCandidateService,
    burstCandidateService: burstCandidateService,
  );
  await fileService.init();
  final reviewProvider = ReviewProvider(
    documents,
    mediaLibraryDeletionService: mediaLibraryDeletionService,
  );
  final database = FakeDatabaseService();
  await database.init();

  return TestContext(
    notifications: notifications,
    documents: documents,
    settings: settings,
    fileService: fileService,
    reviewProvider: reviewProvider,
    database: database,
  );
}

Widget buildTestApp({
  required Widget home,
  required TestContext context,
  Map<String, WidgetBuilder> routes = const {},
  ThumbnailCache? thumbnailCache,
}) {
  final cache = thumbnailCache ?? ThumbnailCache();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: context.settings),
      ChangeNotifierProvider.value(value: context.fileService),
      ChangeNotifierProvider.value(value: context.reviewProvider),
      ChangeNotifierProvider(create: (_) => StatsProvider()),
      Provider<DatabaseService>.value(value: context.database),
      Provider<NotificationService>.value(value: context.notifications),
      Provider<DocumentAccessService>.value(value: context.documents),
      ChangeNotifierProvider.value(value: cache),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.settings.resolvedThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
      routes: routes,
    ),
  );
}

void configureTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
}

void resetTestViewport(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
