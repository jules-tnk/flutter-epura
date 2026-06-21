import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/epura_components.dart';

class PrivacyPermissionsScreen extends StatefulWidget {
  const PrivacyPermissionsScreen({super.key});

  @override
  State<PrivacyPermissionsScreen> createState() =>
      _PrivacyPermissionsScreenState();
}

class _PrivacyPermissionsScreenState extends State<PrivacyPermissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final db = context.read<DatabaseService>();
      context.read<StatsProvider>().loadStats(db);
    });
  }

  Future<void> _clearHistory(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.clearHistoryTitle),
        content: Text(l.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.clearHistoryConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final db = context.read<DatabaseService>();
    final settings = context.read<SettingsProvider>();
    await db.clearReviewSessions();
    await db.clearReviewDecisions();
    await db.clearFileIndex();
    await db.clearReviewGroupDismissals();
    await settings.clearReviewHistory();
    if (!context.mounted) return;
    await context.read<StatsProvider>().loadStats(db);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.historyClearedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          children: [
            EpuraPageHeader(
              title: l.privacyPermissions,
              badgeIcon: Icons.verified_user,
              badgeLabel: l.localOnlyBadge,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            _PrivacyReceipt(l: l),
            const SizedBox(height: AppTheme.spaceLG),
            EpuraSectionHeader(title: l.permissionsEpuraUses),
            const SizedBox(height: AppTheme.spaceSM),
            EpuraPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _PermissionRow(
                    icon: Icons.photo_library_outlined,
                    title: l.mediaPermissionTitle,
                    body: l.mediaPermissionBody,
                  ),
                  const Divider(height: 1),
                  _PermissionRow(
                    icon: Icons.folder_open_outlined,
                    title: l.selectedFoldersPermissionTitle,
                    body: l.selectedFoldersPermissionBody,
                  ),
                  const Divider(height: 1),
                  _PermissionRow(
                    icon: Icons.notifications_outlined,
                    title: l.notificationsPermissionTitle,
                    body: l.notificationsPermissionBody,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            EpuraSectionHeader(title: l.currentLocalAccess),
            const SizedBox(height: AppTheme.spaceSM),
            EpuraPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _AccessStatusRow(
                    label: l.photos,
                    enabled: settings.scanPhotos,
                  ),
                  const Divider(height: 1),
                  _AccessStatusRow(
                    label: l.videos,
                    enabled: settings.scanVideos,
                  ),
                  const Divider(height: 1),
                  _TextRow(
                    label: l.selectedFolders,
                    value: settings.customFolders.isEmpty
                        ? l.noneSelected
                        : l.selectedFolderCount(settings.customFolders.length),
                  ),
                  const Divider(height: 1),
                  _AccessStatusRow(
                    label: l.notifications,
                    enabled: settings.notificationsEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            _AccessBoundaryPanel(l: l),
            const SizedBox(height: AppTheme.spaceLG),
            EpuraSectionHeader(title: l.localHistory),
            const SizedBox(height: AppTheme.spaceSM),
            EpuraPanel(
              child: Column(
                children: [
                  const EpuraIconBubble(
                    icon: Icons.manage_history_outlined,
                    size: 56,
                    iconSize: 28,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  Text(
                    stats.sessions.isEmpty
                        ? l.noLocalReviewHistory
                        : l.localReviewSessionCount(stats.sessions.length),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  Text(
                    l.clearHistoryExplanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceLG),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _clearHistory(context),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(
                        l.clearEpuraHistory,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    );
  }
}

class _PrivacyReceipt extends StatelessWidget {
  final AppLocalizations l;

  const _PrivacyReceipt({required this.l});

  @override
  Widget build(BuildContext context) {
    return EpuraPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EpuraIconBubble(
            icon: Icons.verified_user_outlined,
            size: 72,
            iconSize: 36,
          ),
          const SizedBox(width: AppTheme.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.privacyReceipt,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                _ReceiptLine(label: l.noAccount),
                _ReceiptLine(label: l.noAnalyticsTracking),
                _ReceiptLine(label: l.noCloudSync),
                _ReceiptLine(label: l.localOnlyProcessing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;

  const _ReceiptLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpuraIconBubble(icon: icon),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessBoundaryPanel extends StatelessWidget {
  final AppLocalizations l;

  const _AccessBoundaryPanel({required this.l});

  @override
  Widget build(BuildContext context) {
    final firstColumn = _BoundaryColumn(
      icon: Icons.visibility_outlined,
      title: l.storageInsightEpuraCanReview,
      body: l.storageInsightEpuraCanReviewBody,
    );
    final secondColumn = _BoundaryColumn(
      icon: Icons.lock_outline,
      title: l.storageInsightSystemStorage,
      body: l.storageInsightSystemStorageBody,
    );

    return EpuraPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                firstColumn,
                Divider(
                  height: AppTheme.spaceXL,
                  color: Theme.of(context).dividerColor,
                ),
                secondColumn,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: firstColumn),
              SizedBox(
                height: 150,
                child: VerticalDivider(color: Theme.of(context).dividerColor),
              ),
              Expanded(child: secondColumn),
            ],
          );
        },
      ),
    );
  }
}

class _BoundaryColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _BoundaryColumn({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraIconBubble(icon: icon, size: 44, iconSize: 22),
        const SizedBox(height: AppTheme.spaceSM),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTheme.spaceXS),
        Text(
          body,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AccessStatusRow extends StatelessWidget {
  final String label;
  final bool enabled;

  const _AccessStatusRow({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _TextRow(
      label: label,
      value: enabled ? l.enabled : l.disabled,
      pillColor: enabled
          ? Theme.of(context).colorScheme.primary
          : context.appColors.textTertiary,
    );
  }
}

class _TextRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? pillColor;

  const _TextRow({required this.label, required this.value, this.pillColor});

  @override
  Widget build(BuildContext context) {
    final color = pillColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppTheme.spaceMD),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceXS,
              ),
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
