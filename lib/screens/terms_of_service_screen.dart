import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _onlineUrl =
      'https://jules-tnk.github.io/flutter-epura/terms-of-service/';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.termsOfService)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.termsOfService,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              l.tosLastUpdated,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.tosIntro,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.tosLocalOnly,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.tosDeletion,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.tosNoWarranty,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              l.tosChanges,
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
