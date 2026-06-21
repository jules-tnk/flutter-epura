class IndexedFile {
  final String fileKey;
  final String source;
  final String fileType;
  final int size;
  final DateTime modifiedAt;
  final DateTime indexedAt;
  final String? folderUri;
  final String? mimeType;

  const IndexedFile({
    required this.fileKey,
    required this.source,
    required this.fileType,
    required this.size,
    required this.modifiedAt,
    required this.indexedAt,
    this.folderUri,
    this.mimeType,
  });
}
