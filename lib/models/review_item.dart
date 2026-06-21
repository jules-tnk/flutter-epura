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
  final int? durationSeconds;
  final String? thumbnailPath;
  final String? folderUri;
  final String? duplicateGroupId;
  final int? duplicateGroupSize;
  final int? duplicateGroupIndex;
  final int? duplicateRecoverableBytes;
  final String? burstGroupId;
  final int? burstGroupSize;
  final int? burstGroupIndex;

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
    this.durationSeconds,
    this.thumbnailPath,
    this.folderUri,
    this.duplicateGroupId,
    this.duplicateGroupSize,
    this.duplicateGroupIndex,
    this.duplicateRecoverableBytes,
    this.burstGroupId,
    this.burstGroupSize,
    this.burstGroupIndex,
  }) : assert(path != null || contentUri != null);

  bool get isUriBacked => contentUri != null;
  bool get isDuplicateCandidate => duplicateGroupId != null;
  bool get isBurstCandidate => burstGroupId != null;

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
    int? durationSeconds,
    String? thumbnailPath,
    String? folderUri,
    String? duplicateGroupId,
    int? duplicateGroupSize,
    int? duplicateGroupIndex,
    int? duplicateRecoverableBytes,
    String? burstGroupId,
    int? burstGroupSize,
    int? burstGroupIndex,
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
      durationSeconds: durationSeconds ?? this.durationSeconds,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      folderUri: folderUri ?? this.folderUri,
      duplicateGroupId: duplicateGroupId ?? this.duplicateGroupId,
      duplicateGroupSize: duplicateGroupSize ?? this.duplicateGroupSize,
      duplicateGroupIndex: duplicateGroupIndex ?? this.duplicateGroupIndex,
      duplicateRecoverableBytes:
          duplicateRecoverableBytes ?? this.duplicateRecoverableBytes,
      burstGroupId: burstGroupId ?? this.burstGroupId,
      burstGroupSize: burstGroupSize ?? this.burstGroupSize,
      burstGroupIndex: burstGroupIndex ?? this.burstGroupIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReviewItem(id: $id, name: $name, type: $type, size: $size)';
}
