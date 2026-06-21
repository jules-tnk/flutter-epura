import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/burst_group.dart';
import 'package:epura/models/review_mode.dart';
import 'package:epura/screens/burst_groups_screen.dart';

import '../test_helpers.dart';

void main() {
  const prefs = <String, Object>{
    'hasAcceptedTerms': true,
    'scanPhotos': false,
    'scanVideos': false,
  };

  testWidgets('Burst groups screen starts review for one burst', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final first = testPhotoReviewItem('a', 'a.jpg');
    final second = first.copyWith(
      id: 'b',
      name: 'b.jpg',
      path: 'C:/tmp/b.jpg',
      date: first.date.add(const Duration(seconds: 3)),
    );
    final group = BurstGroup(id: 'burst:test', items: [first, second]);
    final context = await createTestContext(
      prefs: prefs,
      burstCandidateService: FakeBurstCandidateService([group]),
    );
    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.bursts(),
      db: context.database,
    );

    await tester.pumpWidget(
      buildTestApp(
        home: const BurstGroupsScreen(),
        context: context,
        routes: {EpuraApp.routeReview: (_) => const SizedBox.shrink()},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Photo bursts'), findsOneWidget);
    expect(find.text('2 shots'), findsOneWidget);
    expect(find.text('3s span'), findsOneWidget);
    expect(find.text('4.0 KB total'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Compare shots'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Review burst'));
    await tester.pumpAndSettle();

    expect(context.reviewProvider.queue, hasLength(2));
    expect(context.reviewProvider.queue.first.isBurstCandidate, isTrue);
  });

  testWidgets('Burst groups screen shows an empty state', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: prefs);

    await tester.pumpWidget(
      buildTestApp(home: const BurstGroupsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('No photo bursts found.'), findsOneWidget);
  });
}
