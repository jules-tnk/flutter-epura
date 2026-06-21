import 'review_item.dart';

class DuplicateGroup {
  final String id;
  final String fingerprint;
  final List<ReviewItem> items;

  const DuplicateGroup({
    required this.id,
    required this.fingerprint,
    required this.items,
  }) : assert(items.length >= 2);

  int get recoverableBytes => items.first.size * (items.length - 1);

  List<ReviewItem> get reviewItems {
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(
          duplicateGroupId: id,
          duplicateGroupSize: items.length,
          duplicateGroupIndex: index + 1,
          duplicateRecoverableBytes: recoverableBytes,
        ),
    ];
  }
}
