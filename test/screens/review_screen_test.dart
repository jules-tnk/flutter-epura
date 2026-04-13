import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/screens/review_screen.dart';
import 'package:epura/screens/summary_screen.dart';

import '../test_helpers.dart';

Future<TestContext> _createStorageOnlyReviewContext() async {
  final context = await createTestContext();
  await context.settings.setScanPhotos(false);
  await context.settings.setScanVideos(false);
  return context;
}

Widget _buildReviewScreenApp(TestContext context) {
  return buildTestApp(
    home: const ReviewScreen(),
    context: context,
    routes: {EpuraApp.routeSummary: (_) => const SummaryScreen()},
  );
}

void main() {
  testWidgets('Review screen moves through a mixed queue', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();
    context.reviewProvider.startReview([
      ReviewItem(
        id: 'asset-1',
        name: 'photo.jpg',
        path: '/tmp/photo.jpg',
        size: 10,
        type: FileItemType.photo,
        date: DateTime(2026, 4, 13),
        source: ReviewItemSource.mediaLibrary,
      ),
      ReviewItem(
        id: 'content://doc/report',
        name: 'report.pdf',
        contentUri: 'content://doc/report',
        size: 20,
        type: FileItemType.download,
        date: DateTime(2026, 4, 12),
        source: ReviewItemSource.importedDocument,
      ),
    ]);

    await tester.pumpWidget(
      buildTestApp(home: const ReviewScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('photo.jpg'), findsOneWidget);

    await tester.tap(find.text('Skip for later'));
    await tester.pumpAndSettle();

    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets(
    'Save & Exit shows cleanup progress before navigating to summary',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await _createStorageOnlyReviewContext();
      context.documents.deleteBarrier = Completer<void>();
      context.reviewProvider.startReview([
        ReviewItem(
          id: 'content://doc/keep-later',
          name: 'first.pdf',
          contentUri: 'content://doc/keep-later',
          size: 10,
          type: FileItemType.download,
          date: DateTime(2026, 4, 13),
          source: ReviewItemSource.importedDocument,
        ),
        ReviewItem(
          id: 'content://doc/current',
          name: 'current.pdf',
          contentUri: 'content://doc/current',
          size: 20,
          type: FileItemType.download,
          date: DateTime(2026, 4, 12),
          source: ReviewItemSource.importedDocument,
        ),
      ]);
      context.reviewProvider.deleteCurrent();

      await tester.pumpWidget(_buildReviewScreenApp(context));
      await tester.pumpAndSettle();

      expect(find.text('current.pdf'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save & Exit'));
      await tester.pump();

      expect(find.text('Cleaning up...'), findsOneWidget);
      expect(find.text('0 / 1 files deleted'), findsOneWidget);
      expect(find.text('current.pdf'), findsNothing);

      context.documents.deleteBarrier!.complete();
      await tester.pumpAndSettle();

      expect(find.text('All done!'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
    },
  );

  testWidgets(
    'Summary opens immediately after deletion completes even if sync is still running',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await _createStorageOnlyReviewContext();
      context.documents.nextPickedDocuments = [
        StorageDocument(
          uri: 'content://doc/slow-sync',
          name: 'slow-sync.pdf',
          size: 20,
          modifiedAt: DateTime(2026, 4, 12),
          mimeType: 'application/pdf',
        ),
      ];
      await context.fileService.importDownloadDocuments();
      context.documents.releaseBarrier = Completer<void>();
      context.reviewProvider.startReview([
        ReviewItem(
          id: 'content://doc/slow-sync',
          name: 'slow-sync.pdf',
          contentUri: 'content://doc/slow-sync',
          size: 20,
          type: FileItemType.download,
          date: DateTime(2026, 4, 12),
          source: ReviewItemSource.importedDocument,
        ),
      ]);
      context.reviewProvider.deleteCurrent();

      await tester.pumpWidget(_buildReviewScreenApp(context));
      await tester.pumpAndSettle();

      expect(find.text('All done!'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
      expect(context.documents.releasedUris, isEmpty);

      context.documents.releaseBarrier!.complete();
      await tester.pumpAndSettle();

      expect(context.documents.releasedUris, ['content://doc/slow-sync']);
    },
  );
}
