import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/screens/settings_screen.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Settings screen adds and removes custom folders', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(
      prefs: {
        'scanPhotos': false,
        'scanVideos': false,
      },
    );
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/receipts',
      name: 'Receipts',
    );

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add folder'));
    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsNothing);
  });
}
