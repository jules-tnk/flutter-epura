import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/burst_group.dart';
import 'package:epura/models/duplicate_group.dart';
import 'package:epura/models/review_decision.dart';
import 'package:epura/models/review_group_dismissal.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/review_mode.dart';
import 'package:epura/models/scan_folder_grant.dart';
import 'package:epura/models/storage_document.dart';

import '../test_helpers.dart';

void main() {
  test('custom folder grants are persisted and removable', () async {
    final context = await createTestContext();
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/custom',
      name: 'Receipts',
    );

    expect(context.settings.customFolders, isEmpty);

    final addedFolder = await context.settings.addCustomFolder();

    expect(addedFolder?.name, 'Receipts');
    expect(context.settings.customFolders, hasLength(1));

    final restored = await createTestContext(
      prefs: {
        'customFolders': [
          jsonEncode(
            const ScanFolderGrant(
              uri: 'content://tree/custom',
              name: 'Receipts',
            ).toJson(),
          ),
        ],
      },
    );
    expect(restored.settings.customFolders, hasLength(1));
    expect(restored.settings.customFolders.first.name, 'Receipts');

    await context.settings.removeCustomFolder(
      context.settings.customFolders.first,
    );

    expect(context.settings.customFolders, isEmpty);
    expect(context.documents.releasedUris, contains('content://tree/custom'));
  });

  test(
    'custom folder profiles persist nickname and last-reviewed metadata',
    () async {
      final context = await createTestContext();
      context.documents.nextFolder = const ScanFolderGrant(
        uri: 'content://tree/receipts',
        name: 'Receipts',
      );

      final added = await context.settings.addCustomFolder();
      await context.settings.renameCustomFolder(added!, 'Work receipts');
      await context.settings.markFolderReviewed(
        added.uri,
        DateTime(2026, 5, 31, 10),
      );

      expect(
        context.settings.customFolders.single.displayName,
        'Work receipts',
      );
      expect(
        context.settings.customFolders.single.lastReviewedAt,
        DateTime(2026, 5, 31, 10),
      );

      final restored = await createTestContext(
        prefs: {
          'customFolders': context.settings.customFolders
              .map((entry) => jsonEncode(entry.toJson()))
              .toList(),
        },
      );
      expect(
        restored.settings.customFolders.single.displayName,
        'Work receipts',
      );
      expect(
        restored.settings.customFolders.single.lastReviewedAt,
        DateTime(2026, 5, 31, 10),
      );
    },
  );

  test('old custom folder grants migrate to folder profiles', () async {
    final restored = await createTestContext(
      prefs: {
        'customFolders': [
          jsonEncode(
            const ScanFolderGrant(
              uri: 'content://tree/legacy',
              name: 'Legacy',
            ).toJson(),
          ),
        ],
      },
    );

    expect(restored.settings.customFolders.single.uri, 'content://tree/legacy');
    expect(restored.settings.customFolders.single.name, 'Legacy');
    expect(restored.settings.customFolders.single.nickname, isNull);
    expect(restored.settings.customFolders.single.displayName, 'Legacy');
  });

  test(
    'imported documents merge into scans and failed SAF deletions stay queued',
    () async {
      final context = await createTestContext();
      await context.settings.setScanPhotos(false);
      await context.settings.setScanVideos(false);

      context.documents.nextFolder = const ScanFolderGrant(
        uri: 'content://tree/work',
        name: 'Work',
      );
      await context.settings.addCustomFolder();

      final folderDocument = StorageDocument(
        uri: 'content://doc/work-note',
        name: 'note.txt',
        size: 50,
        modifiedAt: DateTime(2026, 4, 11),
        mimeType: 'text/plain',
      );
      context.documents.folderFilesByUri['content://tree/work'] = [
        folderDocument,
      ];

      final importedDocument = StorageDocument(
        uri: 'content://doc/imported-report',
        name: 'report.pdf',
        size: 120,
        modifiedAt: DateTime(2026, 4, 12),
        mimeType: 'application/pdf',
      );
      context.documents.nextPickedDocuments = [importedDocument];
      await context.fileService.importDownloadDocuments();

      await context.fileService.scanForNewFiles(
        context.settings,
        since: DateTime(1970),
        updateCache: true,
      );

      expect(context.fileService.items, hasLength(2));
      expect(
        context.fileService.items.map((item) => item.source),
        containsAll([
          ReviewItemSource.customFolder,
          ReviewItemSource.importedDocument,
        ]),
      );

      context.reviewProvider.startReview(context.fileService.items);
      context.reviewProvider.deleteCurrent();
      context.reviewProvider.deleteCurrent();

      context.documents.deleteFailures.add(importedDocument.uri);

      final result = await context.reviewProvider.completeSession(
        context.database,
        context.settings,
      );
      await context.fileService.resolveImportedDocumentsAfterReview(result);

      expect(context.reviewProvider.bytesFreed, 50);
      expect(context.reviewProvider.deletedCount, 1);
      expect(context.reviewProvider.keptCount, 1);
      expect(result.failedDeletionItems, hasLength(1));
      expect(result.failedDeletionItems.first.contentUri, importedDocument.uri);
      expect(context.fileService.importedDocumentCount, 1);
      expect(
        context.documents.releasedUris,
        isNot(contains(importedDocument.uri)),
      );
    },
  );

  test(
    'imported documents do not allow processed count to exceed total count',
    () async {
      final context = await createTestContext();
      await context.settings.setScanPhotos(false);
      await context.settings.setScanVideos(false);

      context.documents.nextFolder = const ScanFolderGrant(
        uri: 'content://tree/work',
        name: 'Work',
      );
      await context.settings.addCustomFolder();

      context.documents.folderFilesByUri['content://tree/work'] = [
        StorageDocument(
          uri: 'content://doc/one',
          name: 'one.txt',
          size: 10,
          modifiedAt: DateTime(2026, 4, 13),
        ),
        StorageDocument(
          uri: 'content://doc/two',
          name: 'two.txt',
          size: 20,
          modifiedAt: DateTime(2026, 4, 13),
        ),
      ];

      await context.fileService.scanForNewFiles(
        context.settings,
        since: DateTime(1970),
      );

      expect(
        context.fileService.processedAssets <=
            context.fileService.totalEstimatedAssets,
        isTrue,
      );
    },
  );

  test('scanForNewFiles applies downloads and selected folder modes', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);

    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/work',
      name: 'Work',
    );
    await context.settings.addCustomFolder();

    context.documents.folderFilesByUri['content://tree/work'] = [
      StorageDocument(
        uri: 'content://doc/folder-note',
        name: 'folder-note.txt',
        size: 10,
        modifiedAt: DateTime(2026, 5, 31),
      ),
    ];
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/imported-report',
        name: 'imported-report.pdf',
        size: 20,
        modifiedAt: DateTime(2026, 5, 31),
      ),
    ];
    await context.fileService.importDownloadDocuments();

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.downloads(),
    );
    expect(context.fileService.items.map((item) => item.id), [
      'content://doc/imported-report',
    ]);

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.selectedFolders(),
    );
    expect(context.fileService.items.map((item) => item.id), [
      'content://doc/folder-note',
    ]);
  });

  test('scanForNewFiles applies one selected folder mode', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);

    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/one',
      name: 'One',
    );
    await context.settings.addCustomFolder();
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/two',
      name: 'Two',
    );
    await context.settings.addCustomFolder();

    context.documents.folderFilesByUri['content://tree/one'] = [
      StorageDocument(
        uri: 'content://doc/one',
        name: 'one.txt',
        size: 10,
        modifiedAt: DateTime(2026, 5, 31),
      ),
    ];
    context.documents.folderFilesByUri['content://tree/two'] = [
      StorageDocument(
        uri: 'content://doc/two',
        name: 'two.txt',
        size: 20,
        modifiedAt: DateTime(2026, 5, 31),
      ),
    ];

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.folder(
        folderUri: 'content://tree/two',
        folderName: 'Two',
      ),
    );

    expect(context.fileService.items.map((item) => item.name), ['two.txt']);
  });

  test(
    'scanForNewFiles keeps folder mode when local database helpers fail',
    () async {
      final context = await createTestContext();
      await context.settings.setScanPhotos(false);
      await context.settings.setScanVideos(false);

      context.documents.nextFolder = const ScanFolderGrant(
        uri: 'content://tree/one',
        name: 'One',
      );
      await context.settings.addCustomFolder();
      context.documents.nextFolder = const ScanFolderGrant(
        uri: 'content://tree/two',
        name: 'Two',
      );
      await context.settings.addCustomFolder();

      context.documents.folderFilesByUri['content://tree/one'] = [
        StorageDocument(
          uri: 'content://doc/one',
          name: 'one.txt',
          size: 10,
          modifiedAt: DateTime(2026, 5, 31),
        ),
      ];
      context.documents.folderFilesByUri['content://tree/two'] = [
        StorageDocument(
          uri: 'content://doc/two',
          name: 'two.txt',
          size: 20,
          modifiedAt: DateTime(2026, 5, 31),
        ),
      ];
      context.database.throwOnIndexUpsert = true;
      context.database.throwOnDecisionLookup = true;

      await context.fileService.scanForNewFiles(
        context.settings,
        since: DateTime(1970),
        reviewMode: const ReviewMode.folder(
          folderUri: 'content://tree/two',
          folderName: 'Two',
        ),
        db: context.database,
      );

      expect(context.fileService.items.map((item) => item.name), ['two.txt']);
      expect(context.database.indexedFilesByKey, isEmpty);
    },
  );

  test(
    'duplicate mode uses exact duplicate candidates as the review queue',
    () async {
      final first = ReviewItem(
        id: 'dup-1',
        name: 'dup-1.jpg',
        path: 'C:/tmp/dup-1.jpg',
        size: 10,
        type: FileItemType.photo,
        date: DateTime(2026, 5, 31),
        source: ReviewItemSource.mediaLibrary,
      );
      final second = first.copyWith(
        id: 'dup-2',
        name: 'dup-2.jpg',
        path: 'C:/tmp/dup-2.jpg',
      );
      final context = await createTestContext(
        prefs: {'scanPhotos': false, 'scanVideos': false},
        duplicateCandidateService: FakeDuplicateCandidateService([
          DuplicateGroup(
            id: '10:group',
            fingerprint: 'group',
            items: [first, second],
          ),
        ]),
      );

      await context.fileService.scanForNewFiles(
        context.settings,
        since: DateTime(1970),
        reviewMode: const ReviewMode.duplicates(),
        db: context.database,
      );

      expect(context.fileService.items.map((item) => item.name), [
        'dup-1.jpg',
        'dup-2.jpg',
      ]);
      expect(
        context.fileService.items.every((item) => item.isDuplicateCandidate),
        isTrue,
      );
    },
  );

  test('duplicate mode stores latest duplicate groups', () async {
    final first = ReviewItem(
      id: 'a',
      name: 'a.jpg',
      path: 'C:/tmp/a.jpg',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.mediaLibrary,
    );
    final second = first.copyWith(id: 'b', name: 'b.jpg', path: 'C:/tmp/b.jpg');
    final group = DuplicateGroup(
      id: '10:abc',
      fingerprint: 'abc',
      items: [first, second],
    );
    final context = await createTestContext(
      prefs: {'scanPhotos': false, 'scanVideos': false},
      duplicateCandidateService: FakeDuplicateCandidateService([group]),
    );

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.duplicates(),
      db: context.database,
    );

    expect(context.fileService.duplicateGroups, hasLength(1));
    expect(
      context.fileService.duplicateGroups.single.reviewItems,
      hasLength(2),
    );
  });

  test('burst mode stores latest burst groups', () async {
    final first = testPhotoReviewItem('burst-a', 'burst-a.jpg');
    final second = first.copyWith(
      id: 'burst-b',
      name: 'burst-b.jpg',
      path: 'C:/tmp/burst-b.jpg',
      date: first.date.add(const Duration(seconds: 3)),
    );
    final group = BurstGroup(id: 'burst:test', items: [first, second]);
    final context = await createTestContext(
      prefs: {'scanPhotos': false, 'scanVideos': false},
      burstCandidateService: FakeBurstCandidateService([group]),
    );

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.bursts(),
      db: context.database,
    );

    expect(context.fileService.burstGroups, hasLength(1));
    expect(context.fileService.items.map((item) => item.name), [
      'burst-a.jpg',
      'burst-b.jpg',
    ]);
    expect(
      context.fileService.items.every((item) => item.isBurstCandidate),
      isTrue,
    );
  });

  test('scanForNewFiles filters locally dismissed review groups', () async {
    final first = testPhotoReviewItem('group-a', 'group-a.jpg');
    final second = first.copyWith(
      id: 'group-b',
      name: 'group-b.jpg',
      path: 'C:/tmp/group-b.jpg',
    );
    final duplicateGroup = DuplicateGroup(
      id: 'duplicate:test',
      fingerprint: 'test',
      items: [first, second],
    );
    final burstGroup = BurstGroup(id: 'burst:test', items: [first, second]);
    final context = await createTestContext(
      prefs: {'scanPhotos': false, 'scanVideos': false},
      duplicateCandidateService: FakeDuplicateCandidateService([
        duplicateGroup,
      ]),
      burstCandidateService: FakeBurstCandidateService([burstGroup]),
    );
    await context.database.upsertReviewGroupDismissal(
      ReviewGroupDismissal(
        groupKey: duplicateGroup.id,
        mode: ReviewModeType.duplicates.name,
        dismissedAt: DateTime(2026, 5, 31),
      ),
    );
    await context.database.upsertReviewGroupDismissal(
      ReviewGroupDismissal(
        groupKey: burstGroup.id,
        mode: ReviewModeType.bursts.name,
        dismissedAt: DateTime(2026, 5, 31),
      ),
    );
    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.duplicates(),
      db: context.database,
    );
    expect(context.fileService.duplicateGroups, isEmpty);
    expect(context.fileService.items, isEmpty);

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      reviewMode: const ReviewMode.bursts(),
      db: context.database,
    );
    expect(context.fileService.burstGroups, isEmpty);
    expect(context.fileService.items, isEmpty);

    await context.fileService.dismissReviewGroup(
      modeType: ReviewModeType.recent,
      groupId: 'recent:test',
      db: context.database,
    );
    expect(
      await context.database.getDismissedReviewGroupKeys(
        ReviewModeType.recent.name,
      ),
      isEmpty,
    );
  });

  test('scanForNewFiles indexes scanned metadata without file names', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);
    context.documents.nextFolder = const ScanFolderGrant(
      uri: 'content://tree/work',
      name: 'Work',
    );
    await context.settings.addCustomFolder();
    context.documents.folderFilesByUri['content://tree/work'] = [
      StorageDocument(
        uri: 'content://doc/private-name',
        name: 'private-name.txt',
        size: 123,
        modifiedAt: DateTime(2026, 5, 31),
        mimeType: 'text/plain',
      ),
    ];

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime(1970),
      db: context.database,
    );

    final indexed = await context.database.getIndexedFilesForFolder(
      'content://tree/work',
    );
    expect(indexed.single.fileKey, 'uri:content://doc/private-name');
    expect(indexed.single.folderUri, 'content://tree/work');
    expect(indexed.single.size, 123);
    expect(indexed.single.fileType, FileItemType.download.name);
  });

  test(
    'scanForNewFiles excludes later and never decisions from normal reviews',
    () async {
      final context = await createTestContext();
      await context.settings.setScanPhotos(false);
      await context.settings.setScanVideos(false);
      context.documents.nextPickedDocuments = [
        StorageDocument(
          uri: 'content://doc/later',
          name: 'later.pdf',
          size: 10,
          modifiedAt: DateTime(2026, 5, 30),
          mimeType: 'application/pdf',
        ),
        StorageDocument(
          uri: 'content://doc/never',
          name: 'never.pdf',
          size: 20,
          modifiedAt: DateTime(2026, 5, 31),
          mimeType: 'application/pdf',
        ),
        StorageDocument(
          uri: 'content://doc/new',
          name: 'new.pdf',
          size: 30,
          modifiedAt: DateTime(2026, 5, 31),
          mimeType: 'application/pdf',
        ),
      ];
      await context.fileService.importDownloadDocuments();
      await context.database.upsertReviewDecisions([
        ReviewDecision(
          fileKey: 'uri:content://doc/later',
          type: ReviewDecisionType.later,
          decidedAt: DateTime(2026, 5, 30),
        ),
        ReviewDecision(
          fileKey: 'uri:content://doc/never',
          type: ReviewDecisionType.neverAskAgain,
          decidedAt: DateTime(2026, 5, 30),
        ),
      ]);

      await context.fileService.scanForNewFiles(
        context.settings,
        since: DateTime.fromMillisecondsSinceEpoch(0),
        db: context.database,
      );

      expect(context.fileService.items.map((item) => item.name), ['new.pdf']);
    },
  );

  test('review skipped mode only includes later decisions', () async {
    final context = await createTestContext();
    await context.settings.setScanPhotos(false);
    await context.settings.setScanVideos(false);
    context.documents.nextPickedDocuments = [
      StorageDocument(
        uri: 'content://doc/later',
        name: 'later.pdf',
        size: 10,
        modifiedAt: DateTime(2026, 5, 30),
        mimeType: 'application/pdf',
      ),
      StorageDocument(
        uri: 'content://doc/never',
        name: 'never.pdf',
        size: 20,
        modifiedAt: DateTime(2026, 5, 31),
        mimeType: 'application/pdf',
      ),
    ];
    await context.fileService.importDownloadDocuments();
    await context.database.upsertReviewDecisions([
      ReviewDecision(
        fileKey: 'uri:content://doc/later',
        type: ReviewDecisionType.later,
        decidedAt: DateTime(2026, 5, 30),
      ),
      ReviewDecision(
        fileKey: 'uri:content://doc/never',
        type: ReviewDecisionType.neverAskAgain,
        decidedAt: DateTime(2026, 5, 30),
      ),
    ]);

    await context.fileService.scanForNewFiles(
      context.settings,
      since: DateTime.fromMillisecondsSinceEpoch(0),
      reviewMode: const ReviewMode.skipped(),
      db: context.database,
    );

    expect(context.fileService.items.map((item) => item.name), ['later.pdf']);
  });
}
