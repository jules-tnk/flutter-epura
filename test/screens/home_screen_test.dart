import 'package:flutter_test/flutter_test.dart';

import 'package:epura/screens/home_screen.dart';
import 'package:epura/models/storage_document.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Home screen imports downloaded files into the review queue', (
    WidgetTester tester,
  ) async {
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
}
