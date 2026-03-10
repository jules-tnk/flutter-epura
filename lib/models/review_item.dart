enum FileItemType { photo, video, download }

class ReviewItem {
  final String id;
  final String name;
  final String path;
  final int size; // bytes
  final FileItemType type;
  final DateTime date;
  final String? thumbnailPath;

  const ReviewItem({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    required this.date,
    this.thumbnailPath,
  });

  ReviewItem copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    FileItemType? type,
    DateTime? date,
    String? thumbnailPath,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      date: date ?? this.date,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReviewItem(id: $id, name: $name, type: $type, size: $size)';
}
