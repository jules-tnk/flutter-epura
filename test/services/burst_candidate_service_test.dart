import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/burst_candidate_service.dart';

ReviewItem _photo(String id, DateTime date, {String? name}) {
  final fileName = name ?? '$id.jpg';
  return ReviewItem(
    id: id,
    name: fileName,
    path: 'C:/tmp/$fileName',
    size: 100,
    type: FileItemType.photo,
    date: date,
    source: ReviewItemSource.mediaLibrary,
  );
}

void main() {
  test('groups adjacent photos taken close together', () {
    const service = BurstCandidateService();
    final start = DateTime(2026, 5, 31, 12);

    final groups = service.findPhotoBurstGroups([
      _photo('a', start),
      _photo('b', start.add(const Duration(seconds: 5))),
      _photo('c', start.add(const Duration(seconds: 9))),
      _photo('d', start.add(const Duration(seconds: 25))),
    ]);

    expect(groups, hasLength(1));
    expect(groups.single.items.map((item) => item.id), ['a', 'b', 'c']);
    expect(groups.single.span, const Duration(seconds: 9));
    expect(groups.single.totalBytes, 300);
    expect(groups.single.reviewItems.map((item) => item.burstGroupIndex), [
      1,
      2,
      3,
    ]);
  });

  test('splits bursts when the adjacent gap is too large', () {
    const service = BurstCandidateService();
    final start = DateTime(2026, 5, 31, 12);

    final groups = service.findPhotoBurstGroups([
      _photo('a', start),
      _photo('b', start.add(const Duration(seconds: 3))),
      _photo('c', start.add(const Duration(seconds: 20))),
      _photo('d', start.add(const Duration(seconds: 23))),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.items.map((item) => item.id), ['c', 'd']);
    expect(groups.last.items.map((item) => item.id), ['a', 'b']);
  });

  test('ignores videos downloads screenshots and non-media-library items', () {
    const service = BurstCandidateService();
    final start = DateTime(2026, 5, 31, 12);

    final groups = service.findPhotoBurstGroups([
      _photo('s1', start, name: 'Screenshot_20260531.png'),
      _photo(
        's2',
        start.add(const Duration(seconds: 2)),
        name: 'screen_shot_20260531.png',
      ),
      ReviewItem(
        id: 'video',
        name: 'clip.mp4',
        path: 'C:/tmp/clip.mp4',
        size: 100,
        type: FileItemType.video,
        date: start.add(const Duration(seconds: 3)),
        source: ReviewItemSource.mediaLibrary,
      ),
      ReviewItem(
        id: 'download',
        name: 'photo.jpg',
        contentUri: 'content://doc/photo',
        size: 100,
        type: FileItemType.photo,
        date: start.add(const Duration(seconds: 4)),
        source: ReviewItemSource.importedDocument,
      ),
    ]);

    expect(groups, isEmpty);
  });
}
