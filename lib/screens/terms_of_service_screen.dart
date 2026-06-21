import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/legal_page.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _onlineUrl =
      'https://jules-tnk.github.io/flutter-epura/terms-of-service/';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LegalPageScaffold(
      title: l.termsOfService,
      lastUpdated: l.tosLastUpdated,
      heroBody: l.tosIntro,
      heroIcon: Icons.gavel_outlined,
      onlineUrl: _onlineUrl,
      sections: [
        LegalSection(
          icon: Icons.phone_android_outlined,
          title: l.localOnlyBadge,
          paragraphs: [l.tosLocalOnly, l.tosDeletion],
        ),
        LegalSection(
          icon: Icons.info_outline,
          title: l.termsOfService,
          paragraphs: [l.tosNoWarranty, l.tosChanges],
        ),
      ],
    );
  }
}
