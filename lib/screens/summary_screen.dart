import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../providers/review_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            children: [
              const Spacer(),

              // Checkmark icon
              const Icon(
                Icons.check_circle_outline,
                size: 96,
                color: AppTheme.success,
              ),
              const SizedBox(height: AppTheme.spaceLG),

              Text(
                l.allDone,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppTheme.spaceXL),

              // Stats card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.check_circle_outline,
                        label: l.kept,
                        value: '${review.keptCount}',
                        color: AppTheme.success,
                      ),
                      const Divider(height: AppTheme.spaceMD),
                      _StatRow(
                        icon: Icons.delete_outline,
                        label: l.deleted,
                        value: '${review.deletedCount}',
                        color: AppTheme.danger,
                      ),
                      const Divider(height: AppTheme.spaceMD),
                      _StatRow(
                        icon: Icons.skip_next_outlined,
                        label: l.skipped,
                        value: '${review.skippedCount}',
                        color: AppTheme.textSecondary,
                      ),
                      const Divider(height: AppTheme.spaceMD),
                      _StatRow(
                        icon: Icons.storage_outlined,
                        label: l.storageFreed,
                        value: formatBytes(review.bytesFreed),
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),

              // Motivational message
              Text(
                l.motivationalMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, EpuraApp.routeStats),
                  child: Text(l.viewStats),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    EpuraApp.routeHome,
                    (route) => false,
                  ),
                  child: Text(l.goHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppTheme.spaceSM),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
