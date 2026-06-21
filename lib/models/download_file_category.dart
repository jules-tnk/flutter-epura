import 'review_item.dart';

enum DownloadFileCategory { pdf, archives, apk, audio, documents, other }

DownloadFileCategory downloadFileCategoryForItem(ReviewItem item) {
  final name = item.name.toLowerCase();
  final mimeType = item.mimeType?.toLowerCase() ?? '';

  if (_hasExtension(name, const ['.pdf']) || mimeType == 'application/pdf') {
    return DownloadFileCategory.pdf;
  }

  if (_hasExtension(name, const ['.apk']) ||
      mimeType == 'application/vnd.android.package-archive') {
    return DownloadFileCategory.apk;
  }

  if (_hasExtension(name, const [
        '.zip',
        '.rar',
        '.7z',
        '.tar',
        '.gz',
        '.bz2',
      ]) ||
      const {
        'application/zip',
        'application/x-zip-compressed',
        'application/x-rar-compressed',
        'application/x-7z-compressed',
        'application/gzip',
        'application/x-tar',
      }.contains(mimeType)) {
    return DownloadFileCategory.archives;
  }

  if (_hasExtension(name, const [
        '.mp3',
        '.m4a',
        '.aac',
        '.wav',
        '.ogg',
        '.flac',
      ]) ||
      mimeType.startsWith('audio/')) {
    return DownloadFileCategory.audio;
  }

  if (_isDocument(name, mimeType)) {
    return DownloadFileCategory.documents;
  }

  return DownloadFileCategory.other;
}

bool _hasExtension(String name, List<String> extensions) {
  return extensions.any(name.endsWith);
}

bool _isDocument(String name, String mimeType) {
  return _hasExtension(name, const [
        '.txt',
        '.md',
        '.rtf',
        '.csv',
        '.doc',
        '.docx',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx',
        '.odt',
        '.ods',
        '.odp',
      ]) ||
      mimeType.startsWith('text/') ||
      const {
        'application/msword',
        'application/rtf',
        'application/vnd.ms-excel',
        'application/vnd.ms-powerpoint',
        'application/vnd.oasis.opendocument.text',
        'application/vnd.oasis.opendocument.spreadsheet',
        'application/vnd.oasis.opendocument.presentation',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      }.contains(mimeType);
}
