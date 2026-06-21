import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/burst_group.dart';
import 'package:epura/models/duplicate_group.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/models/review_mode.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/screens/home_screen.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/theme/app_theme.dart';

import '../test_helpers.dart';

const _homeScreenPrefs = <String, Object>{
  'hasAcceptedTerms': true,
  'hasAskedNotifPermission': true,
  'scanPhotos': false,
  'scanVideos': false,
};

Future<void> _tapReviewMode(
  WidgetTester tester,
  ReviewModeType type, {
  String folderUri = '',
}) async {
  final mode = find.byKey(ValueKey('reviewMode:$type:$folderUri'));
  await tester.ensureVisible(mode);
  await tester.pumpAndSettle();
  await tester.tap(mode);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home screen imports downloaded files into the review queue', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add downloaded files'));
    await tester.pumpAndSettle();

    expect(context.fileService.importedDocumentCount, 1);
    expect(find.text('1 file imported - 120 B'), findsOneWidget);
    expect(find.text('Clear imported files (1)'), findsOneWidget);
  });

  testWidgets('Home screen shows downloads inbox summary after import', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 1024,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
      StorageDocument(
        uri: 'content://doc/archive',
        name: 'archive.zip',
        size: 2048,
        modifiedAt: DateTime(2026, 4, 12),
        mimeType: 'application/zip',
      ),
    ];

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add downloaded files'));
    await tester.pumpAndSettle();

    expect(find.text('Downloads inbox'), findsOneWidget);
    expect(find.text('2 files imported - 3.0 KB'), findsOneWidget);
    expect(
      find.text(
        'Android asks you to choose downloads manually. Epura only reviews files you picked.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Review downloads'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Add more'), findsOneWidget);
    expect(find.text('Clear imported files (2)'), findsOneWidget);
  });

  testWidgets('Downloads inbox review action starts downloads-only review', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 1024,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
      StorageDocument(
        uri: 'content://doc/archive',
        name: 'archive.zip',
        size: 2048,
        modifiedAt: DateTime(2026, 4, 12),
        mimeType: 'application/zip',
      ),
    ];
    await context.fileService.importDownloadDocuments();

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const Text('review route')},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review downloads'));
    await tester.pumpAndSettle();

    expect(find.text('review route'), findsOneWidget);
    expect(context.reviewProvider.queue.map((item) => item.name), [
      'report.pdf',
      'archive.zip',
    ]);
  });

  testWidgets('Home screen filters imported downloads by file type', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 1024,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
      StorageDocument(
        uri: 'content://doc/archive',
        name: 'archive.zip',
        size: 2048,
        modifiedAt: DateTime(2026, 4, 12),
        mimeType: 'application/zip',
      ),
    ];

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const Text('review route')},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add downloaded files'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Review downloads by type'), findsOneWidget);
    expect(find.text('All downloads (2)'), findsOneWidget);
    expect(find.text('PDFs (1)'), findsOneWidget);
    expect(find.text('Archives (1)'), findsOneWidget);

    await tester.tap(find.text('PDFs (1)'));
    await tester.pumpAndSettle();

    expect(find.text('review route'), findsOneWidget);
    expect(context.reviewProvider.queue.map((item) => item.name), [
      'report.pdf',
    ]);
  });

  testWidgets('Home screen keeps space between the top card and start button', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();
    await context.fileService.refreshAllFiles(context.settings);

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    final cardBottom = tester.getBottomLeft(find.text('days in a row')).dy;
    final startButtonTop = tester.getTopLeft(find.text('Start Review')).dy;

    expect(startButtonTop - cardBottom, greaterThanOrEqualTo(AppTheme.spaceLG));
  });

  testWidgets('Home screen blends historical stats with readiness context', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.database.reviewStreak = 4;
    await context.database.insertSession(
      ReviewSession(
        id: 'history',
        date: DateTime.now(),
        keptCount: 8,
        deletedCount: 3,
        skippedCount: 1,
        bytesFreed: 5 * 1024 * 1024,
      ),
    );
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/current',
        name: 'current.pdf',
        size: 4096,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();
    await context.fileService.refreshAllFiles(
      context.settings,
      db: context.database,
    );

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('Storage freed'), findsOneWidget);
    expect(find.text('5.0 MB'), findsOneWidget);
    expect(find.text('Files reviewed'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Ready to review'), findsOneWidget);
    expect(find.text('1 files to review · 4.0 KB'), findsOneWidget);
    expect(find.text('8 review modes available'), findsOneWidget);
    expect(find.text('Start Review'), findsOneWidget);
  });

  testWidgets('Home screen shows available review modes as cards', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Largest'), findsOneWidget);
    expect(find.text('Screenshots'), findsOneWidget);
    expect(find.text('More modes'), findsNothing);
    expect(find.text('Choose review mode'), findsNothing);
    expect(find.text('Large videos'), findsOneWidget);
    expect(find.text('Bursts'), findsOneWidget);
    expect(find.text('Duplicates'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
  });

  testWidgets('Home screen shows duplicate review mode in picker', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('Duplicates'), findsOneWidget);
  });

  testWidgets('Duplicates mode opens duplicate groups before review', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final group = DuplicateGroup(
      id: '2048:abc',
      fingerprint: 'abc',
      items: [
        testPhotoReviewItem('a', 'a.jpg'),
        testPhotoReviewItem('b', 'b.jpg'),
      ],
    );
    final context = await createTestContext(
      prefs: _homeScreenPrefs,
      duplicateCandidateService: FakeDuplicateCandidateService([group]),
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {
          EpuraApp.routeDuplicateGroups: (_) =>
              const Text('duplicate groups route'),
          EpuraApp.routeReview: (_) => const Text('review route'),
        },
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(tester, ReviewModeType.duplicates);

    expect(find.text('duplicate groups route'), findsOneWidget);
    expect(find.text('review route'), findsNothing);
    expect(context.reviewProvider.queue, isEmpty);
  });

  testWidgets('Bursts mode opens burst groups before review', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final first = testPhotoReviewItem('burst-a', 'burst-a.jpg');
    final second = first.copyWith(
      id: 'burst-b',
      name: 'burst-b.jpg',
      path: 'C:/tmp/burst-b.jpg',
      date: first.date.add(const Duration(seconds: 3)),
    );
    final context = await createTestContext(
      prefs: _homeScreenPrefs,
      burstCandidateService: FakeBurstCandidateService([
        BurstGroup(id: 'burst:test', items: [first, second]),
      ]),
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {
          EpuraApp.routeBurstGroups: (_) => const Text('burst groups route'),
          EpuraApp.routeReview: (_) => const Text('review route'),
        },
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(tester, ReviewModeType.bursts);

    await tester.tap(find.text('Forever'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Review').last);
    await tester.pumpAndSettle();

    expect(find.text('burst groups route'), findsOneWidget);
    expect(find.text('review route'), findsNothing);
    expect(context.reviewProvider.queue, isEmpty);
  });

  testWidgets('Downloads mode starts review with imported documents only', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(tester, ReviewModeType.downloads);

    expect(context.reviewProvider.queue, hasLength(1));
    expect(context.reviewProvider.queue.single.name, 'report.pdf');
  });

  testWidgets('Largest mode starts review with largest item first', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/small',
        name: 'small.pdf',
        size: 10,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
      StorageDocument(
        uri: 'content://doc/large',
        name: 'large.pdf',
        size: 200,
        modifiedAt: DateTime(2026, 4, 12),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const Text('review route')},
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(tester, ReviewModeType.largestFiles);

    await tester.tap(find.text('Forever'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Review').last);
    await tester.pumpAndSettle();

    expect(find.text('review route'), findsOneWidget);
    expect(context.reviewProvider.queue.map((item) => item.name), [
      'large.pdf',
      'small.pdf',
    ]);
  });

  testWidgets('Empty mode scan restores the all-files home summary', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();
    await context.fileService.refreshAllFiles(
      context.settings,
      db: context.database,
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(tester, ReviewModeType.skipped);

    expect(context.fileService.items.map((item) => item.name), ['report.pdf']);
    expect(context.reviewProvider.queue, isEmpty);
  });

  testWidgets('Home screen starts review for one selected folder from picker', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/work',
      name: 'Work',
    );
    final folder = await context.settings.addCustomFolder();
    await context.settings.renameCustomFolder(folder!, 'Receipts');
    context.documents.folderFilesByUri['content://tree/work'] = [
      StorageDocument(
        uri: 'content://doc/work',
        name: 'work.txt',
        size: 20,
        modifiedAt: DateTime(2026, 5, 31),
      ),
    ];

    await tester.pumpWidget(
      buildTestApp(
        home: const HomeScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    await _tapReviewMode(
      tester,
      ReviewModeType.folder,
      folderUri: 'content://tree/work',
    );

    await tester.tap(find.text('Forever'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Review').last);
    await tester.pumpAndSettle();

    expect(context.reviewProvider.queue.single.name, 'work.txt');
  });
}
