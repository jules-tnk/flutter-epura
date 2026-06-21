import '../models/review_item.dart';

class FileIdentityService {
  FileIdentityService._();

  static String? keyFor(ReviewItem item) {
    switch (item.source) {
      case ReviewItemSource.mediaLibrary:
        if (item.id.trim().isNotEmpty) return 'media:${item.id}';
      case ReviewItemSource.customFolder:
      case ReviewItemSource.importedDocument:
        final uri = item.contentUri?.trim();
        if (uri != null && uri.isNotEmpty) return 'uri:$uri';
    }

    final path = item.path?.trim();
    if (path == null || path.isEmpty) return null;
    return 'path:${path.replaceAll(r'\', '/').toLowerCase()}';
  }
}
