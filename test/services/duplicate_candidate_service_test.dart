import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/duplicate_candidate_service.dart';

File _writeFile(Directory dir, String name, List<int> bytes) {
  return File('${dir.path}/$name')..writeAsBytesSync(bytes);
}

ReviewItem _photo(String id, File file, {DateTime? date}) {
  return ReviewItem(
    id: id,
    name: file.uri.pathSegments.last,
    path: file.path,
    size: file.lengthSync(),
    type: FileItemType.photo,
    date: date ?? DateTime(2026, 5, 31),
    source: ReviewItemSource.mediaLibrary,
  );
}

void main() {
  test(
    'groups only photos with the same size and content fingerprint',
    () async {
      final dir = await Directory.systemTemp.createTemp('epura-duplicates-');
      addTearDown(() => dir.deleteSync(recursive: true));

      final a = _writeFile(dir, 'a.jpg', [1, 2, 3, 4]);
      final b = _writeFile(dir, 'b.jpg', [1, 2, 3, 4]);
      final sameSizeDifferentBytes = _writeFile(dir, 'c.jpg', [4, 3, 2, 1]);
      final download = _writeFile(dir, 'download.pdf', [1, 2, 3, 4]);

      const service = DuplicateCandidateService();
      final groups = await service.findExactPhotoGroups([
        _photo('a', a, date: DateTime(2026, 5, 30)),
        _photo('b', b, date: DateTime(2026, 5, 31)),
        _photo('c', sameSizeDifferentBytes),
        ReviewItem(
          id: 'download',
          name: 'download.pdf',
          path: download.path,
          size: download.lengthSync(),
          type: FileItemType.download,
          date: DateTime(2026, 5, 31),
          source: ReviewItemSource.importedDocument,
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.items.map((item) => item.id), ['b', 'a']);
      expect(groups.single.recoverableBytes, 4);
    },
  );

  test('flattens groups into annotated review items', () async {
    final dir = await Directory.systemTemp.createTemp('epura-duplicates-');
    addTearDown(() => dir.deleteSync(recursive: true));

    final a = _writeFile(dir, 'a.jpg', [7, 8, 9]);
    final b = _writeFile(dir, 'b.jpg', [7, 8, 9]);

    const service = DuplicateCandidateService();
    final reviewItems = await service.findExactDuplicateReviewItems([
      _photo('a', a, date: DateTime(2026, 5, 30)),
      _photo('b', b, date: DateTime(2026, 5, 31)),
    ]);

    expect(reviewItems, hasLength(2));
    expect(reviewItems.first.isDuplicateCandidate, isTrue);
    expect(reviewItems.first.duplicateGroupSize, 2);
    expect(reviewItems.first.duplicateGroupIndex, 1);
    expect(reviewItems.first.duplicateRecoverableBytes, 3);
    expect(reviewItems.last.duplicateGroupIndex, 2);
    expect(
      reviewItems.first.duplicateGroupId,
      reviewItems.last.duplicateGroupId,
    );
  });

  test('duplicate group exposes annotated review items', () async {
    final dir = await Directory.systemTemp.createTemp('epura-duplicates-');
    addTearDown(() => dir.deleteSync(recursive: true));

    final a = _writeFile(dir, 'a.jpg', [5, 5, 5]);
    final b = _writeFile(dir, 'b.jpg', [5, 5, 5]);

    const service = DuplicateCandidateService();
    final group = (await service.findExactPhotoGroups([
      _photo('a', a, date: DateTime(2026, 5, 30)),
      _photo('b', b, date: DateTime(2026, 5, 31)),
    ])).single;

    expect(group.reviewItems.map((item) => item.duplicateGroupIndex), [1, 2]);
    expect(group.reviewItems.first.duplicateGroupSize, 2);
    expect(group.reviewItems.first.duplicateRecoverableBytes, 3);
  });
}
