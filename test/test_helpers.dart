import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/l10n/app_localizations.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/providers/file_service.dart';
import 'package:epura/providers/review_provider.dart';
import 'package:epura/providers/settings_provider.dart';
import 'package:epura/providers/stats_provider.dart';
import 'package:epura/services/database_service.dart';
import 'package:epura/services/document_access_service.dart';
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
    int dayOfWeek,
  ) async {
    return DateTime(2030, 1, 1, time.hour, time.minute);
  }

  @override
  Future<void> cancelReminder() async {}
}

class FakeDocumentAccessService implements DocumentAccessService {
  ScanFolderGrant? nextFolder;
  List<StorageDocument> nextPickedDocuments = const [];
  final Map<String, List<StorageDocument>> folderFilesByUri = {};
  final List<String> releasedUris = [];
  final List<String> deletedUris = [];
  final Set<String> deleteFailures = {};

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
    return !deleteFailures.contains(uri);
  }

  @override
  Future<void> releasePersistedUriPermission(String uri) async {
    releasedUris.add(uri);
  }
}

class FakeDatabaseService extends DatabaseService {
  final List<ReviewSession> insertedSessions = [];

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
  Future<int> getStreak() async => 0;
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
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final notifications = FakeNotificationService();
  final documents = FakeDocumentAccessService();
  final settings = SettingsProvider(notifications, documents);
  await settings.init();
  final fileService = FileService(documents);
  await fileService.init();
  final reviewProvider = ReviewProvider(documents);
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
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: context.settings),
      ChangeNotifierProvider.value(value: context.fileService),
      ChangeNotifierProvider.value(value: context.reviewProvider),
      ChangeNotifierProvider(create: (_) => StatsProvider()),
      Provider<DatabaseService>.value(value: context.database),
      Provider<NotificationService>.value(value: context.notifications),
      Provider<DocumentAccessService>.value(value: context.documents),
      ChangeNotifierProvider(create: (_) => ThumbnailCache()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.settings.resolvedThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
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
