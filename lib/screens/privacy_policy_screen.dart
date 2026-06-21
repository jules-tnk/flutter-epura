import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/legal_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _onlineUrl =
      'https://jules-tnk.github.io/flutter-epura/privacy-policy/';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LegalPageScaffold(
      title: l.privacyPolicy,
      lastUpdated: l.privacyPolicyLastUpdated,
      heroBody: l.privacyPolicyIntro,
      heroIcon: Icons.verified_user_outlined,
      onlineUrl: _onlineUrl,
      sections: [
        LegalSection(
          icon: Icons.phone_android_outlined,
          title: l.localOnlyBadge,
          paragraphs: [l.privacyPolicyAccess, l.privacyPolicyNoData],
        ),
        LegalSection(
          icon: Icons.lock_outline,
          title: l.privacyPolicyPermissions,
          paragraphs: [
            l.privacyPolicyPermMedia,
            l.privacyPolicyPermStorage,
            l.privacyPolicyPermNotif,
            l.privacyPolicyPermAlarm,
          ],
        ),
      ],
    );
  }
}
