import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../providers/file_service.dart';
import '../providers/review_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/lookback_picker.dart';
import '../services/thumbnail_cache.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      _scanFiles();
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
    await fileService.requestPermissions(settings);
    await fileService.refreshAllFiles(settings);
  }

  List<ReviewItem> _firstPreviewableMedia(List<ReviewItem> items) {
    return items
        .where(
          (item) =>
              item.source == ReviewItemSource.mediaLibrary &&
              item.type != FileItemType.download,
        )
        .take(1)
        .toList();
  }

  Future<void> _importDownloadedFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    final importedCount = await fileService.importDownloadDocuments();
    if (!mounted || importedCount == 0) return;

    await fileService.refreshAllFiles(settings);
    if (!mounted) return;

    _showMessage(
      AppLocalizations.of(context)!.importedFilesAdded(importedCount),
    );
  }

  Future<void> _clearImportedFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    await fileService.clearImportedDocuments();
    await fileService.refreshAllFiles(settings);
    if (!mounted) return;

    _showMessage(AppLocalizations.of(context)!.importedFilesCleared);
  }

  Future<void> _startReview() async {
    final settings = context.read<SettingsProvider>();
    final fileService = context.read<FileService>();
    final reviewProvider = context.read<ReviewProvider>();
    final navigator = Navigator.of(context);

    final result = await LookbackPicker.show(
      context,
      lastReviewTimestamp: settings.lastReviewTimestamp,
    );
    if (result == null || !mounted) return;

    setState(() => _isPreparingReview = true);

    try {
      await fileService.requestPermissions(settings);
      if (!mounted) return;

      await fileService.scanForNewFiles(settings, since: result.since);
      if (!mounted) return;

      final scannedItems = fileService.items;
      if (scannedItems.isEmpty) {
        setState(() => _isPreparingReview = false);
        return;
      }

      final firstPreviewable = _firstPreviewableMedia(scannedItems);
      if (firstPreviewable.isNotEmpty) {
        await context.read<ThumbnailCache>().prefetch(firstPreviewable);
      }
      if (!mounted) return;

      reviewProvider.startReview(scannedItems);
      setState(() => _isPreparingReview = false);
      navigator.pushNamed(EpuraApp.routeReview);
    } catch (_) {
      if (mounted) {
        setState(() => _isPreparingReview = false);
      }
    }
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

  Widget _buildScanProgressCard(
    BuildContext context,
    FileService fileService,
    AppLocalizations l,
  ) {
    final hasTotal = fileService.totalEstimatedAssets > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.preparingReview.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.appColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
            if (hasTotal) ...[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${fileService.processedAssets}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${fileService.totalEstimatedAssets}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.filesScanned,
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              LinearProgressIndicator(
                value: fileService.scanProgress,
                backgroundColor: Theme.of(context).dividerColor,
                color: Theme.of(context).colorScheme.primary,
                minHeight: 3,
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spaceMD),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              hasTotal ? _scanPhaseText(l, fileService.scanPhase) : l.scanning,
              style: TextStyle(
                fontSize: 11,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSummaryCard(
    BuildContext context,
    AppLocalizations l, {
    required FileService fileService,
    required int totalCount,
    required int totalSize,
    required int photoCount,
    required int videoCount,
    required int downloadCount,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fileService.isBackgroundScanning || fileService.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                child: LinearProgressIndicator(
                  value: fileService.totalEstimatedAssets > 0
                      ? fileService.scanProgress
                      : null,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Theme.of(context).colorScheme.primary,
                  minHeight: 3,
                ),
              ),
            Text(
              l.filesToReview(totalCount),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              formatBytes(totalSize),
              style: Theme.of(context).textTheme.bodySmall,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileService = context.watch<FileService>();
    final l = AppLocalizations.of(context)!;
    final items = fileService.items;

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

    Widget topContent;
    if (fileService.permissionDenied && totalCount == 0) {
      topContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_off_outlined,
                size: 64,
                color: context.appColors.textTertiary,
              ),
              const SizedBox(height: AppTheme.spaceMD),
              Text(
                l.storageAccessNeeded,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                l.storageAccessExplanation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              ElevatedButton(onPressed: _scanFiles, child: Text(l.grantAccess)),
              TextButton(
                onPressed: openAppSettings,
                child: Text(l.openSettings),
              ),
            ],
          ),
        ),
      );
    } else if (showScanProgress) {
      topContent = _buildScanProgressCard(context, fileService, l);
    } else if (showEmptyState) {
      topContent = const EmptyState();
    } else {
      topContent = _buildReviewSummaryCard(
        context,
        l,
        fileService: fileService,
        totalCount: totalCount,
        totalSize: totalSize,
        photoCount: photoCount,
        videoCount: videoCount,
        downloadCount: downloadCount,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    l.appTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () =>
                        Navigator.pushNamed(context, EpuraApp.routeSettings),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceXL),
              Expanded(child: topContent),
              const SizedBox(height: AppTheme.spaceLG),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: buttonsDisabled ? null : _startReview,
                  child: Text(l.startReview),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: buttonsDisabled ? null : _importDownloadedFiles,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(l.addDownloadedFiles),
                ),
              ),
              if (fileService.hasImportedDocuments) ...[
                const SizedBox(height: AppTheme.spaceXS),
                TextButton(
                  onPressed: buttonsDisabled ? null : _clearImportedFiles,
                  child: Text(
                    l.clearImportedFiles(fileService.importedDocumentCount),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spaceMD),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: buttonsDisabled
                      ? null
                      : () => Navigator.pushNamed(context, EpuraApp.routeStats),
                  child: Text(l.stats),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
