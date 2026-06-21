import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/burst_group.dart';
import '../models/review_mode.dart';
import '../providers/file_service.dart';
import '../providers/review_provider.dart';
import '../services/database_service.dart';
import '../utils/format_utils.dart';
import '../widgets/review_group_list.dart';

class BurstGroupsScreen extends StatelessWidget {
  const BurstGroupsScreen({super.key});

  void _startBurstReview(BuildContext context, BurstGroup group) {
    context.read<ReviewProvider>().startReview(
      group.reviewItems,
      reviewMode: const ReviewMode.bursts(),
    );
    Navigator.pushNamed(context, EpuraApp.routeReview);
  }

  Future<void> _dismissBurst(BuildContext context, BurstGroup group) async {
    await context.read<FileService>().dismissReviewGroup(
      modeType: ReviewModeType.bursts,
      groupId: group.id,
      db: context.read<DatabaseService>(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupDismissed)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final groups = context.watch<FileService>().burstGroups;

    return ReviewGroupListScreen(
      title: l.photoBursts,
      emptyMessage: l.noBurstGroups,
      emptyIcon: Icons.burst_mode_outlined,
      items: [
        for (final group in groups)
          ReviewGroupListItem(
            icon: Icons.burst_mode_outlined,
            title: l.burstShots(group.items.length),
            details: [
              l.burstSpan(group.span.inSeconds),
              l.burstTotalStorage(formatBytes(group.totalBytes)),
            ],
            previewItems: group.items,
            compareLabel: l.compareShots,
            compareHelp: l.burstCandidateHelp,
            comparePositionLabel: l.groupComparePosition,
            actionLabel: l.reviewBurst,
            onAction: () => _startBurstReview(context, group),
            dismissLabel: l.dismissGroup,
            onDismiss: () => _dismissBurst(context, group),
          ),
      ],
    );
  }
}
