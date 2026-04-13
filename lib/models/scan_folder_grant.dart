class ScanFolderGrant {
  final String uri;
  final String name;

  const ScanFolderGrant({
    required this.uri,
    required this.name,
  });

  Map<String, Object?> toJson() => {
        'uri': uri,
        'name': name,
      };

  factory ScanFolderGrant.fromJson(Map<String, dynamic> json) {
    return ScanFolderGrant(
      uri: json['uri'] as String,
      name: json['name'] as String,
    );
  }
}
