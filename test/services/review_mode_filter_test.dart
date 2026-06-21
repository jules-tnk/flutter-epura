import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/download_file_category.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/models/review_mode.dart';
import 'package:epura/services/review_mode_filter.dart';

void main() {
  final now = DateTime(2026, 5, 31, 12);

  ReviewItem item({
    required String id,
    required String name,
    String? path,
    int size = 100,
    FileItemType type = FileItemType.photo,
    ReviewItemSource source = ReviewItemSource.mediaLibrary,
    int ageHours = 0,
    String? folderUri,
    String? mimeType,
  }) {
    return ReviewItem(
      id: id,
      name: name,
      path: path ?? '/storage/emulated/0/DCIM/$name',
      size: size,
      type: type,
      date: now.subtract(Duration(hours: ageHours)),
      source: source,
      folderUri: folderUri,
      mimeType: mimeType,
    );
  }

  test('recent mode keeps all items newest first', () {
    final filtered = filterReviewItemsForMode([
      item(id: 'old', name: 'old.jpg', ageHours: 4),
      item(id: 'new', name: 'new.jpg', ageHours: 1),
    ], const ReviewMode.recent());

    expect(filtered.map((entry) => entry.id), ['new', 'old']);
  });

  test('screenshot mode includes only conservative screenshot matches', () {
    final filtered = filterReviewItemsForMode([
      item(id: 's1', name: 'Screenshot_20260531.jpg'),
      item(id: 's2', name: 'chat.png', path: '/Pictures/Screenshots/chat.png'),
      item(id: 'p1', name: 'vacation.jpg'),
      item(id: 'v1', name: 'screen_record.mp4', type: FileItemType.video),
    ], const ReviewMode.screenshots());

    expect(filtered.map((entry) => entry.id), ['s1', 's2']);
  });

  test('large videos mode keeps videos sorted by size descending', () {
    final filtered = filterReviewItemsForMode([
      item(id: 'photo', name: 'photo.jpg', size: 900),
      item(
        id: 'small-video',
        name: 'small.mp4',
        size: 200,
        type: FileItemType.video,
      ),
      item(
        id: 'large-video',
        name: 'large.mp4',
        size: 900,
        type: FileItemType.video,
      ),
    ], const ReviewMode.largeVideos());

    expect(filtered.map((entry) => entry.id), ['large-video', 'small-video']);
  });

  test('largest files mode keeps all items sorted by size descending', () {
    final filtered = filterReviewItemsForMode([
      item(id: 'small-photo', name: 'small.jpg', size: 100),
      item(id: 'large-photo', name: 'large.jpg', size: 900),
      item(
        id: 'medium-video',
        name: 'medium.mp4',
        size: 500,
        type: FileItemType.video,
      ),
    ], const ReviewMode.largestFiles());

    expect(filtered.map((entry) => entry.id), [
      'large-photo',
      'medium-video',
      'small-photo',
    ]);
  });

  test('downloads and selected folders modes filter by source', () {
    final items = [
      item(id: 'media', name: 'photo.jpg'),
      item(
        id: 'download',
        name: 'report.pdf',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
      ),
      item(
        id: 'folder',
        name: 'receipt.pdf',
        source: ReviewItemSource.customFolder,
        type: FileItemType.download,
      ),
    ];

    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(),
      ).map((entry) => entry.id),
      ['download'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.selectedFolders(),
      ).map((entry) => entry.id),
      ['folder'],
    );
  });

  test('downloads mode can filter imported documents by file category', () {
    final items = [
      item(
        id: 'pdf',
        name: 'report.pdf',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'application/pdf',
      ),
      item(
        id: 'archive',
        name: 'archive.zip',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'application/zip',
      ),
      item(
        id: 'apk',
        name: 'installer.apk',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'application/vnd.android.package-archive',
      ),
      item(
        id: 'audio',
        name: 'voice.m4a',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'audio/mp4',
      ),
      item(
        id: 'document',
        name: 'notes.txt',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'text/plain',
      ),
      item(
        id: 'other',
        name: 'unknown.bin',
        source: ReviewItemSource.importedDocument,
        type: FileItemType.download,
        mimeType: 'application/octet-stream',
      ),
    ];

    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.pdf),
      ).map((entry) => entry.id),
      ['pdf'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.archives),
      ).map((entry) => entry.id),
      ['archive'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.apk),
      ).map((entry) => entry.id),
      ['apk'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.audio),
      ).map((entry) => entry.id),
      ['audio'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.documents),
      ).map((entry) => entry.id),
      ['document'],
    );
    expect(
      filterReviewItemsForMode(
        items,
        const ReviewMode.downloads(category: DownloadFileCategory.other),
      ).map((entry) => entry.id),
      ['other'],
    );
  });

  test('download category classification falls back to file extensions', () {
    final cases = {
      'report.pdf': DownloadFileCategory.pdf,
      'bundle.zip': DownloadFileCategory.archives,
      'installer.apk': DownloadFileCategory.apk,
      'voice-note.m4a': DownloadFileCategory.audio,
      'notes.txt': DownloadFileCategory.documents,
      'unknown.bin': DownloadFileCategory.other,
    };

    for (final entry in cases.entries) {
      expect(
        downloadFileCategoryForItem(
          item(
            id: entry.key,
            name: entry.key,
            source: ReviewItemSource.importedDocument,
            type: FileItemType.download,
            mimeType: 'application/octet-stream',
          ),
        ),
        entry.value,
      );
    }
  });

  test('folder mode includes only items from the selected folder uri', () {
    final items = [
      item(
        id: 'one',
        name: 'one.txt',
        source: ReviewItemSource.customFolder,
        folderUri: 'content://tree/one',
      ),
      item(
        id: 'two',
        name: 'two.txt',
        source: ReviewItemSource.customFolder,
        folderUri: 'content://tree/two',
      ),
    ];

    final filtered = filterReviewItemsForMode(
      items,
      const ReviewMode.folder(
        folderUri: 'content://tree/two',
        folderName: 'Two',
      ),
    );

    expect(filtered.map((entry) => entry.id), ['two']);
  });
}
