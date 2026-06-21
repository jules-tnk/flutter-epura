import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/epura_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('EpuraMetricStrip aligns icons, values, and helper labels', (
    tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: EpuraMetricStrip(
                metrics: [
                  EpuraMetric(
                    icon: Icons.storage_outlined,
                    label: 'Storage freed',
                    value: '0 B',
                    helper: 'All time',
                  ),
                  EpuraMetric(
                    icon: Icons.description_outlined,
                    label: 'Files reviewed',
                    value: '11',
                    helper: 'This month',
                  ),
                  EpuraMetric(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Streak',
                    value: '0',
                    helper: 'days in a row',
                  ),
                  EpuraMetric(
                    icon: Icons.fact_check_outlined,
                    label: 'Sessions',
                    value: '2',
                    helper: 'This month',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final storageIconCenter = tester.getCenter(
      find.byIcon(Icons.storage_outlined),
    );
    final streakIconCenter = tester.getCenter(
      find.byIcon(Icons.local_fire_department_outlined),
    );
    expect(streakIconCenter.dy, closeTo(storageIconCenter.dy, 0.1));

    final storageLabelTop = tester.getTopLeft(find.text('Storage freed')).dy;
    final streakLabelTop = tester.getTopLeft(find.text('Streak')).dy;
    expect(streakLabelTop, closeTo(storageLabelTop, 0.1));

    final storageValueTop = tester.getTopLeft(find.text('0 B')).dy;
    final streakValueTop = tester.getTopLeft(find.text('0')).dy;
    expect(streakValueTop, closeTo(storageValueTop, 0.1));

    final allTimeTop = tester.getTopLeft(find.text('All time')).dy;
    final daysInARowTop = tester.getTopLeft(find.text('days in a row')).dy;
    expect(daysInARowTop, closeTo(allTimeTop, 0.1));
  });
}
