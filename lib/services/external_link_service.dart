import 'package:url_launcher/url_launcher.dart';

class ExternalLinkService {
  static final Uri playStoreUri = Uri.parse(
    'market://details?id=com.epura.cleaner',
  );
  static final Uri playStoreWebUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.epura.cleaner',
  );
  const ExternalLinkService();

  Future<bool> openPlayStore() async {
    if (await _open(playStoreUri)) return true;
    return _open(playStoreWebUri);
  }

  Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
