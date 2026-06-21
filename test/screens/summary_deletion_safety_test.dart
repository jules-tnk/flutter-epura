import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/screens/summary_screen.dart';
import 'package:epura/services/media_library_deletion_service.dart';

import '../test_helpers.dart';

class FakeMediaLibraryDeletionService implements MediaLibraryDeletionService {
  @override
  Future<MediaLibraryDeletionResult> removeFromLibrary(
    List<ReviewItem> items,
  ) async {
    return const MediaLibraryDeletionResult(trashedIds: {'asset-1'});
  }
}

void main() {
  testWidgets('Summary explains trash and permanent deletion outcomes', (
    tester,
  ) async {
    final context = await createTestContext(
      mediaLibraryDeletionService: FakeMediaLibraryDeletionService(),
    );
    context.reviewProvider.startReview([
      testPhotoReviewItem('asset-1', 'photo.jpg').copyWith(size: 500),
      ReviewItem(
        id: 'content://doc/report',
        name: 'report.pdf',
        contentUri: 'content://doc/report',
        size: 120,
        type: FileItemType.download,
        date: DateTime(2026, 5, 31),
        source: ReviewItemSource.importedDocument,
      ),
    ]);
    context.reviewProvider.deleteCurrent();
    context.reviewProvider.deleteCurrent();
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    await tester.pumpWidget(
      buildTestApp(home: const SummaryScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('moved to Android Trash'), findsOneWidget);
    expect(find.text('1 file was permanently deleted.'), findsOneWidget);
    expect(find.textContaining('Storage freed only counts'), findsOneWidget);
  });
}
