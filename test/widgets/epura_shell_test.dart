import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/epura_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('EpuraShell frames bottom tabs with border and top rounding', (
    tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const EpuraShell(), context: context),
    );
    await tester.pumpAndSettle();

    final frame = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('epura-shell-navigation-frame')),
    );
    final decoration = frame.decoration as BoxDecoration;
    final radius = decoration.borderRadius! as BorderRadius;

    expect(decoration.border, isNotNull);
    expect(decoration.border!.top.color, AppTheme.lightTheme.dividerColor);
    expect(radius.topLeft.x, AppTheme.radiusLG);
    expect(radius.topRight.x, AppTheme.radiusLG);
    expect(radius.bottomLeft, Radius.zero);
    expect(radius.bottomRight, Radius.zero);
  });
}
