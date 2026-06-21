import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../providers/review_provider.dart';
import '../providers/settings_provider.dart';
import '../services/external_link_service.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/epura_components.dart';

class SummaryScreen extends StatelessWidget {
  final ExternalLinkService externalLinkService;

  const SummaryScreen({
    super.key,
    this.externalLinkService = const ExternalLinkService(),
  });

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLG,
            AppTheme.spaceXL,
            AppTheme.spaceLG,
            AppTheme.spaceXL,
          ),
          children: [
            const _CompletionReceiptPanel(),
            const SizedBox(height: AppTheme.spaceLG),

            if (review.lastFailedDeletionCount > 0) ...[
              _DeletionFailurePanel(count: review.lastFailedDeletionCount),
              const SizedBox(height: AppTheme.spaceLG),
            ],

            if (review.lastTrashedCount > 0 ||
                review.lastPermanentDeletionCount > 0) ...[
              _DeletionOutcomeCard(
                trashedCount: review.lastTrashedCount,
                permanentDeletionCount: review.lastPermanentDeletionCount,
              ),
              const SizedBox(height: AppTheme.spaceLG),
            ],

            _SummaryMetrics(review: review),
            const SizedBox(height: AppTheme.spaceLG),

            if (settings.shouldShowReviewPrompt(
              review.lastFailedDeletionCount,
            )) ...[
              _ReviewPromptCard(externalLinkService: externalLinkService),
              const SizedBox(height: AppTheme.spaceLG),
            ],

            const _SummaryActions(),
          ],
        ),
      ),
    );
  }
}

class _CompletionReceiptPanel extends StatelessWidget {
  const _CompletionReceiptPanel();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpuraIconBubble(
            icon: Icons.verified_user_outlined,
            color: context.appColors.success,
            size: 64,
            iconSize: 32,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.allDone,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  l.motivationalMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                EpuraPill(
                  icon: Icons.phone_android_outlined,
                  label: l.localOnlyBadge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletionFailurePanel extends StatelessWidget {
  final int count;

  const _DeletionFailurePanel({required this.count});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;

    return EpuraPanel(
      color: Theme.of(context).colorScheme.errorContainer,
      border: BorderSide(color: error.withValues(alpha: 0.24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpuraIconBubble(
            icon: Icons.error_outline,
            color: error,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Text(
              l.filesCouldNotBeDeleted(count),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  final ReviewProvider review;

  const _SummaryMetrics({required this.review});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraMetricStrip(
      metrics: [
        EpuraMetric(
          icon: Icons.check_circle_outline,
          label: l.kept,
          value: '${review.keptCount}',
          helper: l.thisSession,
        ),
        EpuraMetric(
          icon: Icons.delete_outline,
          label: l.deleted,
          value: '${review.deletedCount}',
          helper: l.thisSession,
        ),
        EpuraMetric(
          icon: Icons.skip_next_outlined,
          label: l.skipped,
          value: '${review.skippedCount}',
          helper: l.thisSession,
        ),
        EpuraMetric(
          icon: Icons.storage_outlined,
          label: l.storageFreed,
          value: formatBytes(review.bytesFreed),
          helper: l.localOnlyBadge,
        ),
      ],
    );
  }
}

class _DeletionOutcomeCard extends StatelessWidget {
  final int trashedCount;
  final int permanentDeletionCount;

  const _DeletionOutcomeCard({
    required this.trashedCount,
    required this.permanentDeletionCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trashedCount > 0) ...[
            _OutcomeLine(
              icon: Icons.restore_from_trash_outlined,
              text: l.filesMovedToTrash(trashedCount),
            ),
            const SizedBox(height: AppTheme.spaceSM),
          ],
          if (permanentDeletionCount > 0) ...[
            _OutcomeLine(
              icon: Icons.delete_forever_outlined,
              text: l.filesPermanentlyDeleted(permanentDeletionCount),
            ),
            const SizedBox(height: AppTheme.spaceSM),
          ],
          if (trashedCount > 0)
            Text(
              l.trashStorageFreedNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _OutcomeLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OutcomeLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraIconBubble(icon: icon, size: 40, iconSize: 20),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ReviewPromptCard extends StatelessWidget {
  final ExternalLinkService externalLinkService;

  const _ReviewPromptCard({required this.externalLinkService});

  Future<void> _rate(BuildContext context) async {
    await externalLinkService.openPlayStore();
    if (context.mounted) {
      await context.read<SettingsProvider>().dismissReviewPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EpuraIconBubble(icon: Icons.star_outline),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.reviewPromptTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      l.reviewPromptBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              TextButton(
                onPressed: () =>
                    context.read<SettingsProvider>().dismissReviewPrompt(),
                child: Text(l.notNow),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _rate(context),
                icon: const Icon(Icons.open_in_new_outlined),
                label: Text(l.rateEpura),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryActions extends StatelessWidget {
  const _SummaryActions();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, EpuraApp.routeStats),
            icon: const Icon(Icons.query_stats_outlined),
            label: Text(l.viewStats),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMD),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              EpuraApp.routeHome,
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined),
            label: Text(l.goHome),
          ),
        ),
      ],
    );
  }
}
