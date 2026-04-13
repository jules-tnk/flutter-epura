import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:epura/app.dart';
import 'package:epura/providers/stats_provider.dart';
import 'package:epura/services/database_service.dart';
import 'package:epura/services/document_access_service.dart';
import 'package:epura/services/notification_service.dart';
import 'package:epura/services/thumbnail_cache.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('App renders smoke test with providers', (WidgetTester tester) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext(
      prefs: {
        'hasAcceptedTerms': true,
        'hasAskedNotifPermission': true,
        'scanPhotos': false,
        'scanVideos': false,
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.settings),
          ChangeNotifierProvider.value(value: context.fileService),
          ChangeNotifierProvider.value(value: context.reviewProvider),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
          Provider<DatabaseService>.value(value: context.database),
          Provider<NotificationService>.value(value: context.notifications),
          Provider<DocumentAccessService>.value(value: context.documents),
          ChangeNotifierProvider(create: (_) => ThumbnailCache()),
        ],
        child: const EpuraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('epura'), findsOneWidget);
    expect(find.text('Add downloaded files'), findsOneWidget);
  });
}
