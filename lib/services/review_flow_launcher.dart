import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../models/review_mode.dart';
import '../providers/file_service.dart';
import '../providers/review_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/thumbnail_cache.dart';
import '../widgets/lookback_picker.dart';

class ReviewFlowLauncher {
  final BuildContext context;
  final bool Function() isMounted;
  final void Function(bool preparing) setPreparing;
  final void Function(String message) showMessage;

  const ReviewFlowLauncher({
    required this.context,
    required this.isMounted,
    required this.setPreparing,
    required this.showMessage,
  });

  Future<void> start({
    ReviewMode reviewMode = const ReviewMode.recent(),
  }) async {
    final settings = context.read<SettingsProvider>();
    final fileService = context.read<FileService>();
    final reviewProvider = context.read<ReviewProvider>();
    final db = context.read<DatabaseService>();
    final thumbnailCache = context.read<ThumbnailCache>();
    final l = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    DateTime since;
    if (reviewMode.usesLookback) {
      final result = await LookbackPicker.show(
        context,
        lastReviewTimestamp: settings.lastReviewTimestamp,
      );
      if (result == null || !isMounted()) return;
      since = result.since;
    } else {
      since = DateTime.fromMillisecondsSinceEpoch(0);
    }

    setPreparing(true);

    try {
      await fileService.requestPermissions(settings);
      if (!isMounted()) return;

      await fileService.scanForNewFiles(
        settings,
        since: since,
        reviewMode: reviewMode,
        db: db,
      );
      if (!isMounted()) return;

      final scannedItems = fileService.items;
      if (scannedItems.isEmpty) {
        await fileService.refreshAllFiles(settings, db: db);
        if (!isMounted()) return;
        setPreparing(false);
        showMessage(l.noFilesForMode);
        return;
      }

      if (reviewMode.type == ReviewModeType.duplicates) {
        setPreparing(false);
        navigator.pushNamed(EpuraApp.routeDuplicateGroups);
        return;
      }

      if (reviewMode.type == ReviewModeType.bursts) {
        setPreparing(false);
        navigator.pushNamed(EpuraApp.routeBurstGroups);
        return;
      }

      final firstPreviewable = _firstPreviewableMedia(scannedItems);
      if (firstPreviewable.isNotEmpty) {
        await thumbnailCache.prefetch(firstPreviewable);
      }
      if (!isMounted()) return;

      reviewProvider.startReview(scannedItems, reviewMode: reviewMode);
      setPreparing(false);
      navigator.pushNamed(EpuraApp.routeReview);
    } catch (_) {
      if (isMounted()) setPreparing(false);
    }
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
}
