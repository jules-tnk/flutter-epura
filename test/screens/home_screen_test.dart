import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/screens/home_screen.dart';
import 'package:epura/models/storage_document.dart';
import 'package:epura/theme/app_theme.dart';

import '../test_helpers.dart';

const _homeScreenPrefs = <String, Object>{
  'hasAcceptedTerms': true,
  'hasAskedNotifPermission': true,
  'scanPhotos': false,
  'scanVideos': false,
};

void main() {
  testWidgets('Home screen imports downloaded files into the review queue', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add downloaded files'));
    await tester.pumpAndSettle();

    expect(context.fileService.importedDocumentCount, 1);
    expect(find.text('Clear imported files (1)'), findsOneWidget);
  });

  testWidgets('Home screen keeps space between the top card and start button', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(prefs: _homeScreenPrefs);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 13),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();
    await context.fileService.refreshAllFiles(context.settings);

    await tester.pumpWidget(
      buildTestApp(home: const HomeScreen(), context: context),
    );
    await tester.pumpAndSettle();

    final cardBottom = tester.getBottomLeft(find.byType(Card).first).dy;
    final startButtonTop = tester
        .getTopLeft(find.widgetWithText(ElevatedButton, 'Start Review'))
        .dy;

    expect(startButtonTop - cardBottom, greaterThanOrEqualTo(AppTheme.spaceLG));
  });
}
