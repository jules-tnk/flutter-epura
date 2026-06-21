import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/screens/stats_screen.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Stats screen shows target-style historical stats', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();
    final now = DateTime.now();
    await context.database.insertSession(
      ReviewSession(
        id: 'current-month',
        date: DateTime(now.year, now.month, 2),
        keptCount: 4,
        deletedCount: 3,
        skippedCount: 2,
        bytesFreed: 2 * 1024 * 1024,
      ),
    );

    await tester.pumpWidget(
      buildTestApp(home: const StatsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Storage freed'), findsAtLeastNWidgets(1));
    expect(find.text('Files reviewed'), findsAtLeastNWidgets(1));
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Storage freed this month'), findsOneWidget);
    expect(find.text('This month'), findsAtLeastNWidgets(1));
    expect(find.text('Recent sessions'), findsOneWidget);
    expect(find.text('9 files reviewed'), findsOneWidget);
    expect(find.text('2.0 MB'), findsAtLeastNWidgets(1));
  });

  testWidgets('Stats screen keeps Storage Insight navigation available', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(
        home: const StatsScreen(),
        context: context,
        routes: {
          EpuraApp.routeStorageInsight: (_) =>
              const Text('storage insight route'),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Storage insight'));
    await tester.pumpAndSettle();

    expect(find.text('storage insight route'), findsOneWidget);
  });
}
