enum FileItemType { photo, video, download }
enum ReviewItemSource { mediaLibrary, customFolder, importedDocument }

class ReviewItem {
  final String id;
  final String name;
  final String? path;
  final String? contentUri;
  final int size; // bytes
  final FileItemType type;
  final DateTime date;
  final ReviewItemSource source;
  final String? mimeType;
  final String? thumbnailPath;

  const ReviewItem({
    required this.id,
    required this.name,
    this.path,
    this.contentUri,
    required this.size,
    required this.type,
    required this.date,
    required this.source,
    this.mimeType,
    this.thumbnailPath,
  }) : assert(path != null || contentUri != null);

  bool get isUriBacked => contentUri != null;

  ReviewItem copyWith({
    String? id,
    String? name,
    String? path,
    String? contentUri,
    int? size,
    FileItemType? type,
    DateTime? date,
    ReviewItemSource? source,
    String? mimeType,
    String? thumbnailPath,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      contentUri: contentUri ?? this.contentUri,
      size: size ?? this.size,
      type: type ?? this.type,
      date: date ?? this.date,
      source: source ?? this.source,
      mimeType: mimeType ?? this.mimeType,
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
