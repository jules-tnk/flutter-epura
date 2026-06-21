import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_session.dart';
import 'package:epura/models/scan_folder_grant.dart';

import '../test_helpers.dart';

void main() {
  test('clear history removes review sessions and last review only', () async {
    const folder = ScanFolderGrant(
      uri: 'content://tree/receipts',
      name: 'Receipts',
    );
    final context = await createTestContext(
      prefs: {
        'lastReviewTimestamp': '2026-05-30T12:00:00.000',
        'scanPhotos': false,
        'scanVideos': true,
        'hasAcceptedTerms': true,
        'customFolders': [jsonEncode(folder.toJson())],
      },
    );
    await context.database.insertSession(
      ReviewSession(
        id: 'session-1',
        date: DateTime(2026, 5, 30, 12),
        keptCount: 2,
        deletedCount: 1,
        skippedCount: 1,
        bytesFreed: 4096,
      ),
    );
    await context.database.upsertReviewDecisions([
      ReviewDecision(
        fileKey: 'media:asset-1',
        type: ReviewDecisionType.later,
        decidedAt: DateTime(2026, 5, 30),
      ),
    ]);

    expect(context.settings.lastReviewTimestamp, isNotNull);
    expect(context.settings.scanPhotos, isFalse);
    expect(context.settings.scanVideos, isTrue);
    expect(context.settings.hasAcceptedTerms, isTrue);
    expect(context.settings.customFolders, hasLength(1));
    expect((await context.database.getStats())['sessionCount'], 1);
    expect(await context.database.getReviewDecisions(), hasLength(1));

    await context.database.clearReviewSessions();
    await context.database.clearReviewDecisions();
    await context.settings.clearReviewHistory();

    expect(context.settings.lastReviewTimestamp, isNull);
    expect(context.settings.scanPhotos, isFalse);
    expect(context.settings.scanVideos, isTrue);
    expect(context.settings.hasAcceptedTerms, isTrue);
    expect(context.settings.customFolders.single.name, 'Receipts');
    expect(context.documents.releasedUris, isEmpty);
    expect((await context.database.getStats())['sessionCount'], 0);
    expect((await context.database.getStats())['totalFilesReviewed'], 0);
    expect(await context.database.getReviewDecisions(), isEmpty);
  });
}
