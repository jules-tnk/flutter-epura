import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/screens/review_screen.dart';
import 'package:epura/screens/summary_screen.dart';
import 'package:epura/services/thumbnail_cache.dart';

import '../test_helpers.dart';

const _validPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0x00,
  0x00,
  0x03,
  0x01,
  0x01,
  0x00,
  0xC9,
  0xFE,
  0x92,
  0xEF,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _RecordingThumbnailCache extends ThumbnailCache {
  final List<List<String>> requests = [];

  @override
  Future<void> prefetch(List<ReviewItem> items) async {
    requests.add(items.map((item) => item.id).toList());

    for (final item in items) {
      if (item.source != ReviewItemSource.mediaLibrary) continue;
      if (item.type == FileItemType.download) continue;
      if (get(item.id) != null) continue;

      insertForTesting(item.id, Uint8List.fromList(_validPngBytes));
    }
  }
}

Future<TestContext> _createStorageOnlyReviewContext() async {
  final context = await createTestContext();
  await context.settings.setScanPhotos(false);
  await context.settings.setScanVideos(false);
  return context;
}

Widget _buildReviewScreenApp(
  TestContext context, {
  ThumbnailCache? thumbnailCache,
}) {
  return buildTestApp(
    home: const ReviewScreen(),
    context: context,
    routes: {EpuraApp.routeSummary: (_) => const SummaryScreen()},
    thumbnailCache: thumbnailCache,
  );
}

Future<void> _pumpReviewScreen(
  WidgetTester tester,
  TestContext context, {
  ThumbnailCache? thumbnailCache,
}) async {
  await tester.pumpWidget(
    _buildReviewScreenApp(context, thumbnailCache: thumbnailCache),
  );
  await tester.pumpAndSettle();
}

ReviewItem _importedDocumentItem(
  String id, {
  String? name,
  int size = 20,
  DateTime? date,
}) {
  return ReviewItem(
    id: id,
    name: name ?? '$id.pdf',
    contentUri: id,
    size: size,
    type: FileItemType.download,
    date: date ?? DateTime(2026, 4, 12),
    source: ReviewItemSource.importedDocument,
  );
}

List<ReviewItem> _mediaItems(int count) {
  return List.generate(
    count,
    (index) => ReviewItem(
      id: 'asset-$index',
      name: 'item-$index.jpg',
      path: '/tmp/item-$index.jpg',
      size: 10 + index,
      type: FileItemType.photo,
      date: DateTime(2026, 4, 13).subtract(Duration(days: index)),
      source: ReviewItemSource.mediaLibrary,
    ),
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
        _importedDocumentItem(
          'content://doc/keep-later',
          name: 'first.pdf',
          size: 10,
          date: DateTime(2026, 4, 13),
        ),
        _importedDocumentItem('content://doc/current', name: 'current.pdf'),
      ]);
      context.reviewProvider.deleteCurrent();

      await _pumpReviewScreen(tester, context);

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
        _importedDocumentItem('content://doc/slow-sync', name: 'slow-sync.pdf'),
      ]);
      context.reviewProvider.deleteCurrent();

      await _pumpReviewScreen(tester, context);

      expect(find.text('All done!'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
      expect(context.documents.releasedUris, isEmpty);

      context.documents.releaseBarrier!.complete();
      await tester.pumpAndSettle();

      expect(context.documents.releasedUris, ['content://doc/slow-sync']);
    },
  );

  testWidgets(
    'Review screen keeps prefetching thumbnails beyond the first ten cards',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await createTestContext();
      final cache = _RecordingThumbnailCache();
      context.reviewProvider.startReview(_mediaItems(12));

      await _pumpReviewScreen(tester, context, thumbnailCache: cache);

      expect(cache.requests.first, [
        'asset-0',
        'asset-1',
        'asset-2',
        'asset-3',
        'asset-4',
        'asset-5',
        'asset-6',
        'asset-7',
        'asset-8',
        'asset-9',
      ]);
      expect(find.byType(Image), findsOneWidget);

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('Keep'));
        await tester.pumpAndSettle();
      }

      expect(find.text('item-10.jpg'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(
        cache.requests.any((request) => request.contains('asset-10')),
        isTrue,
      );
    },
  );

  testWidgets(
    'Review screen advances thumbnail prefetch window for keep, delete, and skip',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await createTestContext();
      final cache = _RecordingThumbnailCache();
      context.reviewProvider.startReview(_mediaItems(13));

      await _pumpReviewScreen(tester, context, thumbnailCache: cache);

      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(
        cache.requests.any((request) => request.contains('asset-10')),
        isTrue,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        cache.requests.any((request) => request.contains('asset-11')),
        isTrue,
      );

      await tester.tap(find.text('Skip for later'));
      await tester.pumpAndSettle();
      expect(
        cache.requests.any((request) => request.contains('asset-12')),
        isTrue,
      );
    },
  );
}
