class StorageDocument {
  final String uri;
  final String name;
  final int size;
  final DateTime modifiedAt;
  final String? mimeType;

  const StorageDocument({
    required this.uri,
    required this.name,
    required this.size,
    required this.modifiedAt,
    this.mimeType,
  });

  Map<String, Object?> toJson() => {
        'uri': uri,
        'name': name,
        'size': size,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'mimeType': mimeType,
      };

  factory StorageDocument.fromJson(Map<String, dynamic> json) {
    return StorageDocument(
      uri: json['uri'] as String,
      name: json['name'] as String,
      size: (json['size'] as num?)?.toInt() ?? 0,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['modifiedAt'] as num?)?.toInt() ?? 0,
      ),
      mimeType: json['mimeType'] as String?,
    );
  }
}
