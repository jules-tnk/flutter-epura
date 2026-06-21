import 'dart:io';

import '../models/duplicate_group.dart';
import '../models/review_item.dart';

class DuplicateCandidateService {
  static const int _fnvOffset = 0xcbf29ce484222325;
  static const int _fnvPrime = 0x100000001b3;
  static const int _mask64 = 0xffffffffffffffff;

  const DuplicateCandidateService();

  Future<List<DuplicateGroup>> findExactPhotoGroups(
    List<ReviewItem> items,
  ) async {
    final candidatesBySize = <int, List<ReviewItem>>{};
    for (final item in items) {
      if (!_isPathBackedPhotoCandidate(item)) continue;
      candidatesBySize.putIfAbsent(item.size, () => []).add(item);
    }

    final groupsByFingerprint = <String, List<ReviewItem>>{};
    for (final candidates in candidatesBySize.values.where(
      (entry) => entry.length > 1,
    )) {
      for (final item in candidates) {
        final fingerprint = await _fingerprintFile(item.path!);
        if (fingerprint == null) continue;
        groupsByFingerprint
            .putIfAbsent('${item.size}:$fingerprint', () => [])
            .add(item);
      }
    }

    final groups = <DuplicateGroup>[];
    for (final entry in groupsByFingerprint.entries) {
      final groupItems = entry.value;
      if (groupItems.length < 2) continue;
      groupItems.sort((a, b) => b.date.compareTo(a.date));
      groups.add(
        DuplicateGroup(
          id: entry.key,
          fingerprint: entry.key.split(':').last,
          items: List.unmodifiable(groupItems),
        ),
      );
    }

    groups.sort((a, b) {
      final byBytes = b.recoverableBytes.compareTo(a.recoverableBytes);
      if (byBytes != 0) return byBytes;
      return b.items.first.date.compareTo(a.items.first.date);
    });
    return groups;
  }

  Future<List<ReviewItem>> findExactDuplicateReviewItems(
    List<ReviewItem> items,
  ) async {
    final groups = await findExactPhotoGroups(items);
    return [for (final group in groups) ...group.reviewItems];
  }

  Future<String?> _fingerprintFile(String path) async {
    try {
      var hash = _fnvOffset;
      await for (final chunk in File(path).openRead()) {
        for (final byte in chunk) {
          hash ^= byte;
          hash = (hash * _fnvPrime) & _mask64;
        }
      }
      return hash.toRadixString(16).padLeft(16, '0');
    } on FileSystemException {
      return null;
    }
  }

  bool _isPathBackedPhotoCandidate(ReviewItem item) {
    return item.type == FileItemType.photo &&
        item.path != null &&
        item.size > 0;
  }
}
