import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/media_library_deletion_service.dart';

import '../test_helpers.dart';

class FakeMediaLibraryDeletionService implements MediaLibraryDeletionService {
  final Set<String> trashedIds;
  final Set<String> permanentlyDeletedIds;
  final List<List<String>> requests = [];

  FakeMediaLibraryDeletionService({
    this.trashedIds = const {},
    this.permanentlyDeletedIds = const {},
  });

  @override
  Future<MediaLibraryDeletionResult> removeFromLibrary(
    List<ReviewItem> items,
  ) async {
    requests.add(items.map((item) => item.id).toList());
    return MediaLibraryDeletionResult(
      trashedIds: trashedIds,
      permanentlyDeletedIds: permanentlyDeletedIds,
    );
  }
}

void main() {
  test('media trash does not count as immediately freed storage', () async {
    final mediaDeletion = FakeMediaLibraryDeletionService(
      trashedIds: {'asset-1'},
    );
    final context = await createTestContext(
      mediaLibraryDeletionService: mediaDeletion,
    );
    context.reviewProvider.startReview([
      testPhotoReviewItem('asset-1', 'photo.jpg').copyWith(size: 500),
    ]);

    context.reviewProvider.deleteCurrent();
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    expect(mediaDeletion.requests, [
      ['asset-1'],
    ]);
    expect(context.reviewProvider.deletedCount, 1);
    expect(context.reviewProvider.lastTrashedCount, 1);
    expect(context.reviewProvider.lastPermanentDeletionCount, 0);
    expect(context.reviewProvider.bytesFreed, 0);
    expect(context.database.insertedSessions.single.bytesFreed, 0);
  });

  test('media permanent fallback still counts freed storage', () async {
    final context = await createTestContext(
      mediaLibraryDeletionService: FakeMediaLibraryDeletionService(
        permanentlyDeletedIds: {'asset-1'},
      ),
    );
    context.reviewProvider.startReview([
      testPhotoReviewItem('asset-1', 'photo.jpg').copyWith(size: 500),
    ]);

    context.reviewProvider.deleteCurrent();
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    expect(context.reviewProvider.lastTrashedCount, 0);
    expect(context.reviewProvider.lastPermanentDeletionCount, 1);
    expect(context.reviewProvider.bytesFreed, 500);
  });

  test('SAF document deletion remains permanent and frees storage', () async {
    final context = await createTestContext();
    context.reviewProvider.startReview([
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
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    expect(context.documents.deletedUris, ['content://doc/report']);
    expect(context.reviewProvider.lastTrashedCount, 0);
    expect(context.reviewProvider.lastPermanentDeletionCount, 1);
    expect(context.reviewProvider.bytesFreed, 120);
  });
}
