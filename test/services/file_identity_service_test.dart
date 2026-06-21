import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/file_identity_service.dart';

void main() {
  test('uses media asset id for media library files', () {
    final item = ReviewItem(
      id: 'asset-42',
      name: 'photo.jpg',
      path: '/storage/emulated/0/DCIM/photo.jpg',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.mediaLibrary,
    );

    expect(FileIdentityService.keyFor(item), 'media:asset-42');
  });

  test('uses content uri for SAF-backed files', () {
    final item = ReviewItem(
      id: 'content://doc/report',
      name: 'report.pdf',
      contentUri: 'content://doc/report',
      size: 10,
      type: FileItemType.download,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.importedDocument,
    );

    expect(FileIdentityService.keyFor(item), 'uri:content://doc/report');
  });

  test('uses normalized path when a non-uri file has no media identity', () {
    final item = ReviewItem(
      id: 'fallback',
      name: 'photo.jpg',
      path: r'C:\Users\Phone\Photo.JPG',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.customFolder,
    );

    expect(FileIdentityService.keyFor(item), 'path:c:/users/phone/photo.jpg');
  });
}
