import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/download_file_category.dart';
import '../models/review_item.dart';
import '../models/review_mode.dart';
import '../providers/file_service.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/review_flow_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/epura_components.dart';
import '../widgets/review_mode_catalog.dart';
import '../widgets/review_mode_grid.dart';

class HomeScreen extends StatefulWidget {
  final bool embedded;

  const HomeScreen({super.key, this.embedded = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPreparingReview = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showTermsIfNeeded();
      unawaited(_scanFiles());
      unawaited(_loadStats());
      _requestNotifPermissionIfFirstRun();
    });
  }

  Future<void> _showTermsIfNeeded() async {
    final settings = context.read<SettingsProvider>();
    if (settings.hasAcceptedTerms) return;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        final theme = Theme.of(ctx);
        return PopScope(
          canPop: false,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.welcomeToEpura, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spaceMD),
                Text(
                  l.termsBottomSheetSummary,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceLG),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(ctx, EpuraApp.routePrivacyPolicy),
                  child: Text(l.readPrivacyPolicy),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(ctx, EpuraApp.routeTermsOfService),
                  child: Text(l.readTermsOfService),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      settings.setHasAcceptedTerms(true);
                      Navigator.pop(ctx);
                    },
                    child: Text(l.accept),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    final db = context.read<DatabaseService>();
    await fileService.requestPermissions(settings);
    await fileService.refreshAllFiles(settings, db: db);
  }

  Future<void> _loadStats() async {
    await context.read<StatsProvider>().loadStats(
      context.read<DatabaseService>(),
    );
  }

  Future<void> _importDownloadedFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    final db = context.read<DatabaseService>();
    final importedCount = await fileService.importDownloadDocuments();
    if (!mounted || importedCount == 0) return;

    await fileService.refreshAllFiles(settings, db: db);
    if (!mounted) return;

    _showMessage(
      AppLocalizations.of(context)!.importedFilesAdded(importedCount),
    );
  }

  Future<void> _clearImportedFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    final db = context.read<DatabaseService>();
    await fileService.clearImportedDocuments();
    await fileService.refreshAllFiles(settings, db: db);
    if (!mounted) return;

    _showMessage(AppLocalizations.of(context)!.importedFilesCleared);
  }

  Future<void> _reviewImportedFiles() {
    return _startReview(reviewMode: const ReviewMode.downloads());
  }

  List<ReviewItem> _importedDocumentItems(FileService fileService) {
    return fileService.items
        .where((item) => item.source == ReviewItemSource.importedDocument)
        .toList();
  }

  Map<DownloadFileCategory, int> _downloadCategoryCounts(
    List<ReviewItem> items,
  ) {
    final counts = {
      for (final category in DownloadFileCategory.values) category: 0,
    };

    for (final item in items) {
      final category = downloadFileCategoryForItem(item);
      counts[category] = counts[category]! + 1;
    }

    return counts;
  }

  String _downloadCategoryLabel(
    AppLocalizations l,
    DownloadFileCategory category,
  ) {
    switch (category) {
      case DownloadFileCategory.pdf:
        return l.downloadFilterPdfs;
      case DownloadFileCategory.archives:
        return l.downloadFilterArchives;
      case DownloadFileCategory.apk:
        return l.downloadFilterApks;
      case DownloadFileCategory.audio:
        return l.downloadFilterAudio;
      case DownloadFileCategory.documents:
        return l.downloadFilterDocuments;
      case DownloadFileCategory.other:
        return l.downloadFilterOther;
    }
  }

  IconData _downloadCategoryIcon(DownloadFileCategory category) {
    switch (category) {
      case DownloadFileCategory.pdf:
        return Icons.picture_as_pdf_outlined;
      case DownloadFileCategory.archives:
        return Icons.folder_zip_outlined;
      case DownloadFileCategory.apk:
        return Icons.android_outlined;
      case DownloadFileCategory.audio:
        return Icons.audio_file_outlined;
      case DownloadFileCategory.documents:
        return Icons.description_outlined;
      case DownloadFileCategory.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _showDownloadFilterSheet(FileService fileService) async {
    final importedItems = _importedDocumentItems(fileService);
    if (importedItems.isEmpty) return;

    final l = AppLocalizations.of(context)!;
    final counts = _downloadCategoryCounts(importedItems);
    final selectedMode = await showModalBottomSheet<ReviewMode>(
      context: context,
      builder: (sheetContext) {
        final filterRows = [
          EpuraSettingsRow(
            icon: Icons.download_outlined,
            title: l.downloadFilterOption(
              l.downloadFilterAll,
              importedItems.length,
            ),
            onTap: () =>
                Navigator.pop(sheetContext, const ReviewMode.downloads()),
          ),
          for (final entry in counts.entries)
            if (entry.value > 0)
              EpuraSettingsRow(
                icon: _downloadCategoryIcon(entry.key),
                title: l.downloadFilterOption(
                  _downloadCategoryLabel(l, entry.key),
                  entry.value,
                ),
                onTap: () => Navigator.pop(
                  sheetContext,
                  ReviewMode.downloads(category: entry.key),
                ),
              ),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.downloadFilterTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                EpuraPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < filterRows.length;
                        index++
                      ) ...[
                        filterRows[index],
                        if (index < filterRows.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMode == null || !mounted) return;
    await _startReview(reviewMode: selectedMode);
  }

  Future<void> _startReview({
    ReviewMode reviewMode = const ReviewMode.recent(),
  }) {
    return ReviewFlowLauncher(
      context: context,
      isMounted: () => mounted,
      setPreparing: (preparing) {
        if (mounted) setState(() => _isPreparingReview = preparing);
      },
      showMessage: _showMessage,
    ).start(reviewMode: reviewMode);
  }

  Future<void> _requestNotifPermissionIfFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'hasAskedNotifPermission';
    if (prefs.getBool(key) == true) return;

    await prefs.setBool(key, true);

    if (!mounted) return;
    final notifService = context.read<NotificationService>();
    final settings = context.read<SettingsProvider>();
    final granted = await notifService.requestPermission();
    if (!mounted) return;
    await settings.applyNotificationPermissionResult(granted);
  }

  String _scanPhaseText(AppLocalizations l, ScanPhase phase) {
    switch (phase) {
      case ScanPhase.scanningMedia:
        return l.scanningPhotosAndVideos;
      case ScanPhase.scanningCustomFolders:
        return l.scanningCustomFolders;
      case ScanPhase.idle:
        return l.startingReview;
    }
  }

  Widget _buildScanProgressContent(
    BuildContext context,
    FileService fileService,
    AppLocalizations l,
    int availableModeCount,
  ) {
    final hasTotal = fileService.totalEstimatedAssets > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const EpuraIconBubble(icon: Icons.autorenew_outlined),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Text(
                l.preparingReview,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMD),
        if (hasTotal) ...[
          Text(
            '${fileService.processedAssets} / ${fileService.totalEstimatedAssets}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(l.filesScanned, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppTheme.spaceMD),
          LinearProgressIndicator(
            value: fileService.scanProgress,
            backgroundColor: Theme.of(context).dividerColor,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 4,
          ),
        ] else ...[
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: AppTheme.spaceSM),
        Text(
          hasTotal ? _scanPhaseText(l, fileService.scanPhase) : l.scanning,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        _buildModeAvailabilityPill(l, availableModeCount),
      ],
    );
  }

  Widget _buildHistoricalStatsStrip(AppLocalizations l, StatsProvider stats) {
    return EpuraMetricStrip(
      framed: false,
      padding: EdgeInsets.zero,
      metrics: [
        EpuraMetric(
          icon: Icons.storage_outlined,
          label: l.storageFreed,
          value: formatBytes(stats.totalBytesFreed),
          helper: l.allTime,
        ),
        EpuraMetric(
          icon: Icons.description_outlined,
          label: l.filesReviewed,
          value: '${stats.totalFilesReviewed}',
          helper: l.allTime,
        ),
        EpuraMetric(
          icon: Icons.local_fire_department_outlined,
          label: l.streak,
          value: '${stats.streak}',
          helper: l.daysInARow,
        ),
      ],
    );
  }

  Widget _buildOverviewPanel(
    BuildContext context,
    AppLocalizations l, {
    required StatsProvider stats,
    required Widget readinessContent,
  }) {
    return EpuraPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSM,
              vertical: AppTheme.spaceMD,
            ),
            child: _buildHistoricalStatsStrip(l, stats),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: readinessContent,
          ),
        ],
      ),
    );
  }

  Widget _buildModeAvailabilityPill(
    AppLocalizations l,
    int availableModeCount,
  ) {
    return EpuraPill(
      icon: Icons.dashboard_customize_outlined,
      label: l.reviewModesAvailable(availableModeCount),
    );
  }

  Widget _buildAccessContent(
    BuildContext context,
    AppLocalizations l,
    int availableModeCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 44,
              color: context.appColors.textTertiary,
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.storageAccessNeeded,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    l.storageAccessExplanation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildModeAvailabilityPill(l, availableModeCount),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceLG),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _scanFiles,
            child: Text(l.grantAccess),
          ),
        ),
        TextButton(onPressed: openAppSettings, child: Text(l.openSettings)),
      ],
    );
  }

  Widget _buildReviewSummaryContent(
    BuildContext context,
    AppLocalizations l, {
    required FileService fileService,
    required int totalCount,
    required int totalSize,
    required int photoCount,
    required int videoCount,
    required int downloadCount,
    required int availableModeCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileService.isBackgroundScanning || fileService.isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
            child: LinearProgressIndicator(
              value: fileService.totalEstimatedAssets > 0
                  ? fileService.scanProgress
                  : null,
              backgroundColor: Theme.of(context).dividerColor,
              color: Theme.of(context).colorScheme.primary,
              minHeight: 4,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EpuraIconBubble(icon: Icons.fact_check_outlined),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.readyToReview,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    '${l.filesToReview(totalCount)} · ${formatBytes(totalSize)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildModeAvailabilityPill(l, availableModeCount),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: AppTheme.spaceLG),
        _SummaryRow(
          icon: Icons.photo_outlined,
          label: l.photos,
          count: photoCount,
        ),
        _SummaryRow(
          icon: Icons.videocam_outlined,
          label: l.videos,
          count: videoCount,
        ),
        _SummaryRow(
          icon: Icons.download_outlined,
          label: l.downloads,
          count: downloadCount,
        ),
      ],
    );
  }

  Widget _buildEmptyReadinessContent(
    BuildContext context,
    AppLocalizations l,
    int availableModeCount,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EpuraIconBubble(icon: Icons.check_circle_outline),
        const SizedBox(width: AppTheme.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.allClean, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                l.noFilesToReview,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              _buildModeAvailabilityPill(l, availableModeCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadsInboxCard(
    AppLocalizations l,
    FileService fileService,
    bool disabled,
  ) {
    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const EpuraIconBubble(icon: Icons.download_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.downloadsInboxTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      l.downloadsInboxSummary(
                        fileService.importedDocumentCount,
                        formatBytes(fileService.importedDocumentTotalSize),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            l.downloadsInboxBody,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Wrap(
            spacing: AppTheme.spaceSM,
            runSpacing: AppTheme.spaceXS,
            children: [
              OutlinedButton.icon(
                onPressed: disabled ? null : _reviewImportedFiles,
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(l.reviewDownloads),
              ),
              TextButton(
                onPressed: disabled
                    ? null
                    : () => _showDownloadFilterSheet(fileService),
                child: Text(l.filterDownloads),
              ),
              TextButton(
                onPressed: disabled ? null : _importDownloadedFiles,
                child: Text(l.addMoreDownloads),
              ),
              TextButton(
                onPressed: disabled ? null : _clearImportedFiles,
                child: Text(
                  l.clearImportedFiles(fileService.importedDocumentCount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportDownloadsCard(AppLocalizations l, bool disabled) {
    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const EpuraIconBubble(icon: Icons.cloud_download_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Text(
                  l.downloadsInboxBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: disabled ? null : _importDownloadedFiles,
              icon: const Icon(Icons.download_outlined),
              label: Text(l.addDownloadedFiles),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileService = context.watch<FileService>();
    final settings = context.watch<SettingsProvider>();
    final stats = context.watch<StatsProvider>();
    final l = AppLocalizations.of(context)!;
    final items = fileService.items;
    final reviewModes = availableReviewModes(fileService, settings);
    final availableModeCount = reviewModes.length;

    final hasFreshData =
        !fileService.isLoading && !fileService.isBackgroundScanning;
    final summary = hasFreshData ? null : fileService.cachedSummary;

    int photoCount;
    int videoCount;
    int downloadCount;
    int totalSize;
    if (summary != null) {
      photoCount = summary.photoCount;
      videoCount = summary.videoCount;
      downloadCount = summary.downloadCount;
      totalSize = summary.totalSize;
    } else {
      photoCount = 0;
      videoCount = 0;
      downloadCount = 0;
      totalSize = 0;
      for (final item in items) {
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
    }
    final totalCount = photoCount + videoCount + downloadCount;
    final buttonsDisabled = _isPreparingReview;
    final showScanProgress =
        _isPreparingReview || (fileService.isLoading && summary == null);
    final showEmptyState =
        totalCount == 0 &&
        !fileService.isBackgroundScanning &&
        !fileService.isLoading;

    Widget readinessContent;
    if (fileService.permissionDenied && totalCount == 0) {
      readinessContent = _buildAccessContent(context, l, availableModeCount);
    } else if (showScanProgress) {
      readinessContent = _buildScanProgressContent(
        context,
        fileService,
        l,
        availableModeCount,
      );
    } else if (showEmptyState) {
      readinessContent = _buildEmptyReadinessContent(
        context,
        l,
        availableModeCount,
      );
    } else {
      readinessContent = _buildReviewSummaryContent(
        context,
        l,
        fileService: fileService,
        totalCount: totalCount,
        totalSize: totalSize,
        photoCount: photoCount,
        videoCount: videoCount,
        downloadCount: downloadCount,
        availableModeCount: availableModeCount,
      );
    }

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        children: [
          EpuraTabTitle(
            title: l.appTitle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _buildOverviewPanel(
            context,
            l,
            stats: stats,
            readinessContent: readinessContent,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          EpuraHeroAction(
            icon: Icons.auto_awesome,
            title: l.startReview,
            subtitle: l.takeControlOfSpace,
            disabled: buttonsDisabled,
            onPressed: _startReview,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          EpuraSectionHeader(title: l.reviewModes),
          const SizedBox(height: AppTheme.spaceSM),
          ReviewModeGrid(
            modes: reviewModes,
            disabled: buttonsDisabled,
            onSelect: (mode) => _startReview(reviewMode: mode),
          ),
          const SizedBox(height: AppTheme.spaceLG),
          if (fileService.hasImportedDocuments)
            _buildDownloadsInboxCard(l, fileService, buttonsDisabled)
          else
            _buildImportDownloadsCard(l, buttonsDisabled),
          const SizedBox(height: AppTheme.spaceLG),
        ],
      ),
    );

    if (widget.embedded) return content;
    return Scaffold(body: content);
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.appColors.textSecondary),
          const SizedBox(width: AppTheme.spaceSM),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text('$count', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
