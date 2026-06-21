import '../models/burst_group.dart';
import '../models/review_item.dart';

class BurstCandidateService {
  final Duration maxAdjacentGap;

  const BurstCandidateService({
    this.maxAdjacentGap = const Duration(seconds: 10),
  });

  List<BurstGroup> findPhotoBurstGroups(List<ReviewItem> items) {
    final candidates = items.where(_isBurstCandidate).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final groups = <BurstGroup>[];
    var current = <ReviewItem>[];

    void flushCurrentGroup() {
      if (current.length >= 2) {
        groups.add(_groupFrom(current));
      }
      current = <ReviewItem>[];
    }

    for (final item in candidates) {
      if (current.isEmpty) {
        current.add(item);
        continue;
      }

      final gap = item.date.difference(current.last.date);
      if (gap <= maxAdjacentGap) {
        current.add(item);
      } else {
        flushCurrentGroup();
        current.add(item);
      }
    }
    flushCurrentGroup();

    groups.sort((a, b) => b.items.last.date.compareTo(a.items.last.date));
    return groups;
  }

  BurstGroup _groupFrom(List<ReviewItem> items) {
    final groupItems = List<ReviewItem>.unmodifiable(items);
    final first = groupItems.first.date.millisecondsSinceEpoch;
    final last = groupItems.last.date.millisecondsSinceEpoch;
    return BurstGroup(
      id: 'burst:$first:$last:${groupItems.length}',
      items: groupItems,
    );
  }

  bool _isBurstCandidate(ReviewItem item) {
    return item.source == ReviewItemSource.mediaLibrary &&
        item.type == FileItemType.photo &&
        !_looksLikeScreenshot(item);
  }

  bool _looksLikeScreenshot(ReviewItem item) {
    final name = item.name.toLowerCase();
    final path = item.path?.toLowerCase() ?? '';
    return name.contains('screenshot') ||
        name.contains('screen_shot') ||
        name.contains('screen shot') ||
        path.contains('/screenshots/') ||
        path.contains(r'\screenshots\');
  }
}
