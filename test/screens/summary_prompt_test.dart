import 'package:flutter_test/flutter_test.dart';

import 'package:epura/screens/summary_screen.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Summary shows local receipt and session metrics', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();
    context.reviewProvider.startReview([testPhotoReviewItem('a', 'a.jpg')]);
    context.reviewProvider.keepCurrent();

    await tester.pumpWidget(
      buildTestApp(home: const SummaryScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('All done!'), findsOneWidget);
    expect(find.text('Local only'), findsNWidgets(2));
    expect(find.text('Kept'), findsOneWidget);
    expect(find.text('Deleted'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.text('Storage freed'), findsOneWidget);
    expect(find.text('This session'), findsNWidgets(3));
  });

  testWidgets(
    'Summary hides review prompt before repeated successful sessions',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await createTestContext();
      context.reviewProvider.startReview([testPhotoReviewItem('a', 'a.jpg')]);
      context.reviewProvider.keepCurrent();
      await context.settings.recordSuccessfulReviewSession(
        hadFailedDeletions: false,
      );

      await tester.pumpWidget(
        buildTestApp(home: const SummaryScreen(), context: context),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enjoying Epura?'), findsNothing);
    },
  );

  testWidgets(
    'Summary shows review prompt after repeated successful sessions',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await createTestContext();
      context.reviewProvider.startReview([testPhotoReviewItem('a', 'a.jpg')]);
      context.reviewProvider.keepCurrent();
      await context.settings.recordSuccessfulReviewSession(
        hadFailedDeletions: false,
      );
      await context.settings.recordSuccessfulReviewSession(
        hadFailedDeletions: false,
      );

      await tester.pumpWidget(
        buildTestApp(home: const SummaryScreen(), context: context),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enjoying Epura?'), findsOneWidget);
      expect(find.text('Rate Epura'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    },
  );
}
