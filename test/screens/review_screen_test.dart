import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/screens/review_screen.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Review screen moves through a mixed queue', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();
    context.reviewProvider.startReview([
      ReviewItem(
        id: 'asset-1',
        name: 'photo.jpg',
        path: '/tmp/photo.jpg',
        size: 10,
        type: FileItemType.photo,
        date: DateTime(2026, 4, 13),
        source: ReviewItemSource.mediaLibrary,
      ),
      ReviewItem(
        id: 'content://doc/report',
        name: 'report.pdf',
        contentUri: 'content://doc/report',
        size: 20,
        type: FileItemType.download,
        date: DateTime(2026, 4, 12),
        source: ReviewItemSource.importedDocument,
      ),
    ]);

    await tester.pumpWidget(
      buildTestApp(home: const ReviewScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.text('photo.jpg'), findsOneWidget);

    await tester.tap(find.text('Skip for later'));
    await tester.pumpAndSettle();

    expect(find.text('report.pdf'), findsOneWidget);
  });
}
