import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/duplicate_group.dart';
import '../models/review_mode.dart';
import '../providers/file_service.dart';
import '../providers/review_provider.dart';
import '../services/database_service.dart';
import '../utils/format_utils.dart';
import '../widgets/review_group_list.dart';

class DuplicateGroupsScreen extends StatelessWidget {
  const DuplicateGroupsScreen({super.key});

  void _startGroupReview(BuildContext context, DuplicateGroup group) {
    context.read<ReviewProvider>().startReview(
      group.reviewItems,
      reviewMode: const ReviewMode.duplicates(),
    );
    Navigator.pushNamed(context, EpuraApp.routeReview);
  }

  Future<void> _dismissGroup(BuildContext context, DuplicateGroup group) async {
    await context.read<FileService>().dismissReviewGroup(
      modeType: ReviewModeType.duplicates,
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
    final groups = context.watch<FileService>().duplicateGroups;

    return ReviewGroupListScreen(
      title: l.exactDuplicateGroups,
      emptyMessage: l.noDuplicateGroups,
      emptyIcon: Icons.copy_all_outlined,
      items: [
        for (final group in groups)
          ReviewGroupListItem(
            icon: Icons.copy_all_outlined,
            title: l.exactCopies(group.items.length),
            details: [
              l.recoverableStorage(formatBytes(group.recoverableBytes)),
            ],
            previewItems: group.items,
            compareLabel: l.compareGroup,
            compareHelp: l.duplicateCandidateHelp,
            comparePositionLabel: l.groupComparePosition,
            actionLabel: l.reviewGroup,
            onAction: () => _startGroupReview(context, group),
            dismissLabel: l.dismissGroup,
            onDismiss: () => _dismissGroup(context, group),
          ),
      ],
    );
  }
}
