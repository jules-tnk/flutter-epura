import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'epura_components.dart';

class LegalPageScaffold extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final String heroBody;
  final IconData heroIcon;
  final String onlineUrl;
  final List<Widget> sections;

  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.heroBody,
    required this.heroIcon,
    required this.onlineUrl,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: AppTheme.spaceMD),
                Expanded(
                  child: Text(title, style: theme.textTheme.displayMedium),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSM),
            EpuraPill(icon: Icons.verified_user, label: l.localOnlyBadge),
            const SizedBox(height: AppTheme.spaceLG),
            EpuraPanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EpuraIconBubble(icon: heroIcon, size: 64, iconSize: 32),
                  const SizedBox(width: AppTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastUpdated,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        Text(heroBody, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            ...sections.expand(
              (section) => [section, const SizedBox(height: AppTheme.spaceMD)],
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(onlineUrl)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l.viewOnline),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> paragraphs;

  const LegalSection({
    super.key,
    required this.icon,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EpuraIconBubble(icon: icon, size: 40, iconSize: 20),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          for (var index = 0; index < paragraphs.length; index++) ...[
            Text(
              paragraphs[index],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            if (index < paragraphs.length - 1)
              const SizedBox(height: AppTheme.spaceSM),
          ],
        ],
      ),
    );
  }
}
