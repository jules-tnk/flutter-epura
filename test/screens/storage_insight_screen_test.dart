import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_session.dart';
import 'package:epura/screens/storage_insight_screen.dart';
import 'package:epura/services/android_settings_service.dart';

import '../test_helpers.dart';

void main() {
  testWidgets(
    'Storage insight distinguishes Epura scope from Android storage',
    (WidgetTester tester) async {
      configureTestViewport(tester);
      addTearDown(() => resetTestViewport(tester));

      final context = await createTestContext(
        prefs: {
          'cachedPhotoCount': 8,
          'cachedVideoCount': 2,
          'cachedDownloadCount': 3,
          'cachedTotalSize': 7 * 1024 * 1024,
        },
      );
      await context.database.insertSession(
        ReviewSession(
          id: 'session-1',
          date: DateTime.now(),
          keptCount: 1,
          deletedCount: 2,
          skippedCount: 0,
          bytesFreed: 2 * 1024 * 1024,
        ),
      );

      await tester.pumpWidget(
        buildTestApp(home: const StorageInsightScreen(), context: context),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('Storage insight'), findsOneWidget);
      expect(find.text('Epura can review'), findsOneWidget);
      expect(find.text('7.0 MB'), findsOneWidget);
      expect(find.text('Photos and videos'), findsWidgets);
      expect(find.text('Downloads'), findsWidgets);
      expect(find.text('App cache'), findsOneWidget);
      expect(find.text('System storage'), findsOneWidget);
      expect(find.text('Cloud copies'), findsOneWidget);
      expect(find.text('2-minute cleanup'), findsOneWidget);
      expect(find.text('Open Android storage settings'), findsOneWidget);
    },
  );

  testWidgets('Storage insight opens Android storage settings', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel(AndroidSettingsService.channelName),
      (call) async {
        calls.add(call);
        return true;
      },
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(
        const MethodChannel(AndroidSettingsService.channelName),
        null,
      ),
    );

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const StorageInsightScreen(), context: context),
    );
    await tester.pumpAndSettle();

    final button = find.text('Open Android storage settings');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'openStorageSettings');
  });
}
