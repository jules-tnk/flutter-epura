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
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/empty_state.dart';
import '../services/notification_service.dart';
import '../widgets/lookback_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPreparingReview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanFiles();
      _requestNotifPermissionIfFirstRun();
    });
  }

  Future<void> _scanFiles() async {
    final fileService = context.read<FileService>();
    final settings = context.read<SettingsProvider>();
    await fileService.requestPermissions();
    await fileService.scanForNewFiles(settings, since: DateTime(1970), updateCache: true);
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
      case ScanPhase.scanningDownloads:
        return l.scanningDownloads;
      case ScanPhase.idle:
        return l.startingReview;
    }
  }

  Widget _buildScanProgressCard(BuildContext context, FileService fileService, AppLocalizations l) {
    final hasTotal = fileService.totalEstimatedAssets > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.preparingReview.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTertiary,
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
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${fileService.totalEstimatedAssets}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.filesScanned,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              LinearProgressIndicator(
                value: fileService.scanProgress,
                backgroundColor: AppTheme.divider,
                color: AppTheme.accent,
                minHeight: 3,
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spaceMD),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              hasTotal
                  ? _scanPhaseText(l, fileService.scanPhase)
                  : l.scanning,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
              ),
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

    // Resolve counts from fresh items or cached summary
    final hasFreshData = !fileService.isLoading && !fileService.isBackgroundScanning;
    final summary = hasFreshData ? null : fileService.cachedSummary;

    int photoCount, videoCount, downloadCount, totalSize;
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
      for (final i in items) {
        totalSize += i.size;
        switch (i.type) {
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    l.appTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                      color: AppTheme.textPrimary,
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

              // Content
              Expanded(
                child: fileService.permissionDenied
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_off_outlined,
                                  size: 64, color: AppTheme.textTertiary),
                              const SizedBox(height: AppTheme.spaceMD),
                              Text(
                                l.storageAccessNeeded,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                l.storageAccessExplanation,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              ElevatedButton(
                                onPressed: _scanFiles,
                                child: Text(l.grantAccess),
                              ),
                              TextButton(
                                onPressed: () => openAppSettings(),
                                child: Text(l.openSettings),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _isPreparingReview
                        ? _buildScanProgressCard(context, fileService, l)
                        : (fileService.isLoading && summary == null)
                            ? _buildScanProgressCard(context, fileService, l)
                            : totalCount == 0 && !fileService.isBackgroundScanning && !fileService.isLoading
                                ? const EmptyState()
                                : Card(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(AppTheme.spaceMD),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (fileService.isBackgroundScanning || fileService.isLoading)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: AppTheme.spaceSM),
                                              child: LinearProgressIndicator(
                                                value: fileService.totalEstimatedAssets > 0
                                                    ? fileService.scanProgress
                                                    : null,
                                                backgroundColor: AppTheme.divider,
                                                color: AppTheme.accent,
                                                minHeight: 3,
                                              ),
                                            ),
                                          Text(
                                            l.filesToReview(totalCount),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall,
                                          ),
                                          const SizedBox(height: AppTheme.spaceSM),
                                          Text(
                                            formatBytes(totalSize),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const Divider(
                                              height: AppTheme.spaceLG),
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
                                  ),
              ),

              // Action buttons — always visible
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: buttonsDisabled
                      ? null
                      : () async {
                          final settings = context.read<SettingsProvider>();
                          final fs = context.read<FileService>();
                          final reviewProvider = context.read<ReviewProvider>();
                          final navigator = Navigator.of(context);

                          final result = await LookbackPicker.show(
                            context,
                            lastReviewTimestamp: settings.lastReviewTimestamp,
                          );
                          if (result == null || !mounted) return;

                          setState(() => _isPreparingReview = true);

                          try {
                            await fs.requestPermissions();
                            if (!mounted) return;

                            await fs.scanForNewFiles(settings, since: result.since);
                            if (!mounted) return;

                            final scannedItems = fs.items;
                            if (scannedItems.isEmpty) {
                              setState(() => _isPreparingReview = false);
                              return;
                            }

                            reviewProvider.startReview(scannedItems);
                            setState(() => _isPreparingReview = false);
                            navigator.pushNamed(EpuraApp.routeReview);
                          } catch (_) {
                            if (mounted) {
                              setState(() => _isPreparingReview = false);
                            }
                          }
                        },
                  child: Text(l.startReview),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: buttonsDisabled
                      ? null
                      : () => Navigator.pushNamed(
                          context, EpuraApp.routeStats),
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
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spaceSM),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
