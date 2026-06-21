import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/duplicate_group.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/review_mode.dart';
import 'package:epura/screens/duplicate_groups_screen.dart';
import 'package:epura/services/thumbnail_cache.dart';

import '../test_helpers.dart';

void main() {
  const prefs = <String, Object>{
    'hasAcceptedTerms': true,
    'scanPhotos': false,
    'scanVideos': false,
  };

  testWidgets('Duplicate groups screen starts review for one group', (
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
      prefs: prefs,
      duplicateCandidateService: FakeDuplicateCandidateService([group]),
    );
    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.duplicates(),
      db: context.database,
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const DuplicateGroupsScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Exact duplicate groups'), findsOneWidget);
    expect(find.text('2 exact copies'), findsOneWidget);
    expect(find.text('2.0 KB recoverable'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Review group'));
    await tester.pumpAndSettle();

    expect(context.reviewProvider.queue, hasLength(2));
    expect(context.reviewProvider.queue.first.isDuplicateCandidate, isTrue);
  });

  testWidgets('Duplicate groups screen prefetches card thumbnails', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final group = DuplicateGroup(
      id: '2048:thumbnails',
      fingerprint: 'thumbnails',
      items: [
        testPhotoReviewItem('a', 'thumbnail-a.jpg'),
        testPhotoReviewItem('b', 'thumbnail-b.jpg'),
      ],
    );
    final context = await createTestContext(
      prefs: prefs,
      duplicateCandidateService: FakeDuplicateCandidateService([group]),
    );
    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.duplicates(),
      db: context.database,
    );
    final thumbnailCache = _RecordingThumbnailCache();

    await tester.pumpWidget(
      buildTestApp(
        home: const DuplicateGroupsScreen(),
        context: context,
        thumbnailCache: thumbnailCache,
      ),
    );
    await tester.pumpAndSettle();

    expect(thumbnailCache.prefetchedIds, containsAll(['a', 'b']));
  });

  testWidgets('Duplicate groups screen opens comparison before review', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final group = DuplicateGroup(
      id: '2048:compare',
      fingerprint: 'compare',
      items: [
        testPhotoReviewItem('a', 'compare-a.jpg'),
        testPhotoReviewItem('b', 'compare-b.jpg'),
      ],
    );
    final context = await createTestContext(
      prefs: prefs,
      duplicateCandidateService: FakeDuplicateCandidateService([group]),
    );
    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.duplicates(),
      db: context.database,
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const DuplicateGroupsScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Compare group'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('2 of 2'), findsOneWidget);
    expect(find.text('compare-a.jpg'), findsOneWidget);
    expect(find.text('compare-b.jpg'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Review group'));
    await tester.pumpAndSettle();

    expect(context.reviewProvider.queue, hasLength(2));
    expect(context.reviewProvider.queue.first.isDuplicateCandidate, isTrue);
  });

  testWidgets('Duplicate groups screen shows an empty state', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: prefs);

    await tester.pumpWidget(
      buildTestApp(home: const DuplicateGroupsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('No exact duplicate groups found.'), findsOneWidget);
  });
}

class _RecordingThumbnailCache extends ThumbnailCache {
  final List<String> prefetchedIds = [];

  @override
  Future<void> prefetch(List<ReviewItem> items) async {
    prefetchedIds.addAll(items.map((item) => item.id));
  }
}
