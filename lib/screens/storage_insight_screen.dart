import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../providers/file_service.dart';
import '../providers/stats_provider.dart';
import '../services/android_settings_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/epura_components.dart';

class StorageInsightScreen extends StatefulWidget {
  final AndroidSettingsService settingsService;

  const StorageInsightScreen({
    super.key,
    this.settingsService = const AndroidSettingsService(),
  });

  @override
  State<StorageInsightScreen> createState() => _StorageInsightScreenState();
}

class _StorageInsightScreenState extends State<StorageInsightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = context.read<DatabaseService>();
      context.read<StatsProvider>().loadStats(db);
    });
  }

  Future<void> _openStorageSettings(AppLocalizations l) async {
    final opened = await widget.settingsService.openStorageSettings();
    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.androidStorageSettingsUnavailable)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final summary = _StorageInsightSummary.fromFileService(
      context.watch<FileService>(),
    );
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLG,
            AppTheme.spaceLG,
            AppTheme.spaceLG,
            AppTheme.spaceXL,
          ),
          children: [
            EpuraPageHeader(
              title: l.storageInsightTitle,
              badgeIcon: Icons.verified_user,
              badgeLabel: l.localOnlyBadge,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            _EpuraScopeCard(summary: summary),
            const SizedBox(height: AppTheme.spaceLG),
            _FreedStorageCard(stats: stats),
            const SizedBox(height: AppTheme.spaceLG),
            _GuideCard(onOpenSettings: () => _openStorageSettings(l)),
            const SizedBox(height: AppTheme.spaceLG),
            const _CleanupPlanCard(),
          ],
        ),
      ),
    );
  }
}

class _StorageInsightSummary {
  final int photoCount;
  final int videoCount;
  final int downloadCount;
  final int totalSize;

  const _StorageInsightSummary({
    required this.photoCount,
    required this.videoCount,
    required this.downloadCount,
    required this.totalSize,
  });

  int get totalCount => photoCount + videoCount + downloadCount;

  static _StorageInsightSummary fromFileService(FileService fileService) {
    final cached = fileService.cachedSummary;
    if (cached != null) {
      return _StorageInsightSummary(
        photoCount: cached.photoCount,
        videoCount: cached.videoCount,
        downloadCount: cached.downloadCount,
        totalSize: cached.totalSize,
      );
    }

    var photoCount = 0;
    var videoCount = 0;
    var downloadCount = 0;
    var totalSize = 0;
    for (final item in fileService.items) {
      totalSize += item.size;
      switch (item.type) {
        case FileItemType.photo:
          photoCount++;
        case FileItemType.video:
          videoCount++;
        case FileItemType.download:
          downloadCount++;
      }
    }

    return _StorageInsightSummary(
      photoCount: photoCount,
      videoCount: videoCount,
      downloadCount: downloadCount,
      totalSize: totalSize,
    );
  }
}

class _EpuraScopeCard extends StatelessWidget {
  final _StorageInsightSummary summary;

  const _EpuraScopeCard({required this.summary});

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
              const EpuraIconBubble(icon: Icons.phone_android_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.storageInsightEpuraCanReview,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      l.storageInsightEpuraCanReviewBody,
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
          Text(
            formatBytes(summary.totalSize),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          EpuraPill(
            icon: Icons.fact_check_outlined,
            label: l.storageInsightFilesAvailable(summary.totalCount),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          _MetricRow(
            icon: Icons.photo_library_outlined,
            label: l.storageInsightPhotosVideos,
            value: '${summary.photoCount + summary.videoCount}',
          ),
          _MetricRow(
            icon: Icons.folder_outlined,
            label: l.downloads,
            value: '${summary.downloadCount}',
          ),
        ],
      ),
    );
  }
}

class _FreedStorageCard extends StatelessWidget {
  final StatsProvider stats;

  const _FreedStorageCard({required this.stats});

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
              const EpuraIconBubble(icon: Icons.delete_sweep_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Text(
                  l.storageInsightAlreadyFreed,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          _MetricRow(
            icon: Icons.storage_outlined,
            label: l.totalStorageFreed,
            value: formatBytes(stats.totalBytesFreed),
          ),
          _MetricRow(
            icon: Icons.calendar_today_outlined,
            label: l.freedThisWeek,
            value: formatBytes(stats.weeklyBytesFreed),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _GuideCard({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.insights_outlined,
            title: l.storageInsightGuideTitle,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          _InsightRow(
            icon: Icons.photo_library_outlined,
            title: l.storageInsightPhotosVideos,
            body: l.storageInsightPhotosVideosBody,
          ),
          _InsightRow(
            icon: Icons.folder_outlined,
            title: l.downloads,
            body: l.storageInsightDownloadsBody,
          ),
          _InsightRow(
            icon: Icons.apps_outlined,
            title: l.storageInsightAppCache,
            body: l.storageInsightAppCacheBody,
          ),
          _InsightRow(
            icon: Icons.cloud_off_outlined,
            title: l.storageInsightCloudCopies,
            body: l.storageInsightCloudCopiesBody,
          ),
          _InsightRow(
            icon: Icons.settings_outlined,
            title: l.storageInsightSystemStorage,
            body: l.storageInsightSystemStorageBody,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.open_in_new),
              label: Text(l.openAndroidStorageSettings),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanupPlanCard extends StatelessWidget {
  const _CleanupPlanCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.task_alt_outlined,
            title: l.storageInsightPlanTitle,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          _InsightRow(
            icon: Icons.timer_outlined,
            title: l.storageInsightPlan2MinuteTitle,
            body: l.storageInsightPlan2MinuteBody,
          ),
          _InsightRow(
            icon: Icons.video_library_outlined,
            title: l.storageInsightPlan5MinuteTitle,
            body: l.storageInsightPlan5MinuteBody,
          ),
          _InsightRow(
            icon: Icons.event_repeat_outlined,
            title: l.storageInsightPlanWeeklyTitle,
            body: l.storageInsightPlanWeeklyBody,
          ),
          _InsightRow(
            icon: Icons.folder_copy_outlined,
            title: l.storageInsightPlanMonthlyTitle,
            body: l.storageInsightPlanMonthlyBody,
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PanelHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraIconBubble(icon: icon),
        const SizedBox(width: AppTheme.spaceMD),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
      child: Row(
        children: [
          EpuraIconBubble(icon: icon, size: 36, iconSize: 18),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InsightRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpuraIconBubble(icon: icon, size: 40, iconSize: 20),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppTheme.spaceXS),
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
