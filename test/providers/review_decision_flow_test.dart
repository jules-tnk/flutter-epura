import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_item.dart';

import '../test_helpers.dart';

ReviewItem _item(String id) {
  return ReviewItem(
    id: id,
    name: '$id.jpg',
    path: '/storage/emulated/0/DCIM/$id.jpg',
    size: 100,
    type: FileItemType.photo,
    date: DateTime(2026, 5, 31),
    source: ReviewItemSource.mediaLibrary,
  );
}

void main() {
  test('skip stores a review-later decision only when saved', () async {
    final context = await createTestContext();
    context.reviewProvider.startReview([_item('asset-1')]);

    context.reviewProvider.skipCurrent();

    expect(await context.database.getReviewDecisions(), isEmpty);

    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    final decisions = await context.database.getReviewDecisions();
    expect(decisions, hasLength(1));
    expect(decisions.single.fileKey, 'media:asset-1');
    expect(decisions.single.type, ReviewDecisionType.later);
  });

  test('discard does not store skipped decisions', () async {
    final context = await createTestContext();
    context.reviewProvider.startReview([_item('asset-1')]);

    context.reviewProvider.skipCurrent();
    context.reviewProvider.discardSession();

    expect(await context.database.getReviewDecisions(), isEmpty);
  });

  test('never ask again stores a never decision when saved', () async {
    final context = await createTestContext();
    context.reviewProvider.startReview([_item('asset-1')]);

    context.reviewProvider.neverAskAgainCurrent();
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    final decisions = await context.database.getReviewDecisions();
    expect(decisions.single.fileKey, 'media:asset-1');
    expect(decisions.single.type, ReviewDecisionType.neverAskAgain);
  });

  test('keep clears an existing later decision when saved', () async {
    final context = await createTestContext();
    await context.database.upsertReviewDecisions([
      ReviewDecision(
        fileKey: 'media:asset-1',
        type: ReviewDecisionType.later,
        decidedAt: DateTime(2026, 5, 30),
      ),
    ]);
    context.reviewProvider.startReview([_item('asset-1')]);

    context.reviewProvider.keepCurrent();
    await context.reviewProvider.completeSession(
      context.database,
      context.settings,
    );

    expect(await context.database.getReviewDecisions(), isEmpty);
  });
}
