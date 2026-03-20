import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _onlineUrl =
      'https://jules-tnk.github.io/flutter-epura/privacy-policy/';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.privacyPolicy,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.privacyPolicyLastUpdated,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.privacyPolicyIntro,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.privacyPolicyAccess,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.privacyPolicyNoData,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.privacyPolicyPermissions,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.privacyPolicyPermMedia,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.privacyPolicyPermStorage,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.privacyPolicyPermNotif,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.privacyPolicyPermAlarm,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceXL),
            Center(
              child: TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(_onlineUrl)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l.viewOnline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
