import 'review_item.dart';

class BurstGroup {
  final String id;
  final List<ReviewItem> items;

  const BurstGroup({required this.id, required this.items})
    : assert(items.length >= 2);

  Duration get span => items.last.date.difference(items.first.date);

  int get totalBytes {
    return items.fold(0, (sum, item) => sum + item.size);
  }

  List<ReviewItem> get reviewItems {
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(
          burstGroupId: id,
          burstGroupSize: items.length,
          burstGroupIndex: index + 1,
        ),
    ];
  }
}
