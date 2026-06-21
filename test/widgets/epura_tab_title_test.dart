import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/epura_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('EpuraTabTitle keeps tab titles aligned with matching type', (
    tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Stack(
              children: [
                EpuraTabTitle(
                  title: 'Epura',
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                const EpuraTabTitle(title: 'Stats'),
                const EpuraTabTitle(title: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Stats')),
      tester.getTopLeft(find.text('Epura')),
    );
    expect(
      tester.getTopLeft(find.text('Settings')),
      tester.getTopLeft(find.text('Epura')),
    );

    final epuraStyle = tester.widget<Text>(find.text('Epura')).style!;
    final statsStyle = tester.widget<Text>(find.text('Stats')).style!;
    final settingsStyle = tester.widget<Text>(find.text('Settings')).style!;

    expect(statsStyle.fontSize, epuraStyle.fontSize);
    expect(settingsStyle.fontSize, epuraStyle.fontSize);
    expect(statsStyle.fontWeight, epuraStyle.fontWeight);
    expect(settingsStyle.fontWeight, epuraStyle.fontWeight);
    expect(statsStyle.color, isNot(epuraStyle.color));
  });
}
