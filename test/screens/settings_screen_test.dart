import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/indexed_file.dart';
import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_group_dismissal.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/screens/privacy_permissions_screen.dart';
import 'package:epura/screens/settings_screen.dart';
import 'package:epura/widgets/epura_components.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Settings screen adds and removes custom folders', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(
      prefs: {'scanPhotos': false, 'scanVideos': false},
    );
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/receipts',
      name: 'Receipts',
    );
    await context.database.upsertIndexedFiles([
      IndexedFile(
        fileKey: 'uri:content://doc/one',
        source: ReviewItemSource.customFolder.name,
        fileType: FileItemType.download.name,
        size: 10,
        modifiedAt: DateTime(2026, 5, 31),
        indexedAt: DateTime(2026, 5, 31, 12),
        folderUri: 'content://tree/receipts',
        mimeType: 'text/plain',
      ),
    ]);
    await context.database.upsertReviewGroupDismissal(
      ReviewGroupDismissal(
        groupKey: 'duplicate:test',
        mode: 'duplicates',
        dismissedAt: DateTime(2026, 5, 30),
      ),
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
    expect(
      await context.database.getIndexedFilesForFolder(
        'content://tree/receipts',
      ),
      isEmpty,
    );
  });

  testWidgets('Settings opens Privacy and Permissions', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(
        home: const SettingsScreen(),
        context: context,
        routes: {
          '/privacy-permissions': (_) => const PrivacyPermissionsScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy and permissions'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy receipt'), findsOneWidget);
    expect(find.text('No account'), findsOneWidget);
    expect(find.text('No analytics or tracking'), findsOneWidget);
  });

  testWidgets('Settings uses Epura rows instead of raw list tiles', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(EpuraSettingsRow), findsAtLeastNWidgets(5));
    expect(find.byType(EpuraSwitchRow), findsAtLeastNWidgets(3));
  });

  testWidgets('Settings theme choices stay compact in the appearance panel', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    final light = find.byKey(const ValueKey('theme-choice-light'));
    final dark = find.byKey(const ValueKey('theme-choice-dark'));
    final system = find.byKey(const ValueKey('theme-choice-system'));

    expect(light, findsOneWidget);
    expect(dark, findsOneWidget);
    expect(system, findsOneWidget);

    final lightSize = tester.getSize(light);
    final darkSize = tester.getSize(dark);
    final systemSize = tester.getSize(system);

    expect(lightSize.height, 44);
    expect(darkSize.height, 44);
    expect(systemSize.height, 44);
    expect(lightSize.width, lessThan(140));
    expect(darkSize.width, lessThan(140));
    expect(systemSize.width, lessThan(160));
  });

  testWidgets('Settings does not expose feedback', (WidgetTester tester) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    for (var page = 0; page < 8; page++) {
      expect(find.byIcon(Icons.feedback_outlined), findsNothing);
      await tester.drag(find.byType(Scrollable), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Settings shows the release candidate version', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.2.0'), findsOneWidget);
  });

  testWidgets('Settings screen renames a folder locally', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(
      prefs: {'scanPhotos': false, 'scanVideos': false},
    );
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/receipts',
      name: 'Receipts',
    );
    await context.settings.addCustomFolder();

    await tester.pumpWidget(
      buildTestApp(home: const SettingsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Work receipts');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Work receipts'), findsOneWidget);
    expect(context.settings.customFolders.single.nickname, 'Work receipts');
  });

  testWidgets('Privacy and Permissions clears history without touching files', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(
      prefs: {'lastReviewTimestamp': '2026-05-30T12:00:00.000'},
    );
    await context.database.insertSession(
      ReviewSession(
        id: 'session-1',
        date: DateTime(2026, 5, 30, 12),
        keptCount: 1,
        deletedCount: 1,
        skippedCount: 0,
        bytesFreed: 2048,
      ),
    );
    await context.database.upsertReviewDecisions([
      ReviewDecision(
        fileKey: 'media:asset-1',
        type: ReviewDecisionType.neverAskAgain,
        decidedAt: DateTime(2026, 5, 30),
      ),
    ]);
    await context.database.upsertIndexedFiles([
      IndexedFile(
        fileKey: 'uri:content://doc/indexed',
        source: ReviewItemSource.customFolder.name,
        fileType: FileItemType.download.name,
        size: 10,
        modifiedAt: DateTime(2026, 5, 30),
        indexedAt: DateTime(2026, 5, 30),
        folderUri: 'content://tree/indexed',
      ),
    ]);

    await tester.pumpWidget(
      buildTestApp(home: const PrivacyPermissionsScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('1 local review session'), findsOneWidget);
    final clearHistoryButton = find.widgetWithText(
      FilledButton,
      'Clear Epura history',
    );
    expect(tester.getSize(clearHistoryButton).width, greaterThan(900));
    expect(
      tester.widget<Text>(find.text('Clear Epura history')).textAlign,
      TextAlign.center,
    );

    await tester.tap(find.text('Clear Epura history'));
    await tester.pumpAndSettle();
    expect(find.text('Clear local history?'), findsOneWidget);

    await tester.tap(find.text('Clear history'));
    await tester.pumpAndSettle();

    expect(find.text('No local review history'), findsOneWidget);
    expect(context.settings.lastReviewTimestamp, isNull);
    expect(await context.database.getReviewDecisions(), isEmpty);
    expect(
      await context.database.getIndexedFilesForFolder('content://tree/indexed'),
      isEmpty,
    );
    expect(
      await context.database.getDismissedReviewGroupKeys('duplicates'),
      isEmpty,
    );
    expect(context.documents.deletedUris, isEmpty);
    expect(context.documents.releasedUris, isEmpty);
  });
}
