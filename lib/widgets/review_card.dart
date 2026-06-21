import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import 'epura_components.dart';
import 'file_preview.dart';

class ReviewCard extends StatelessWidget {
  final ReviewItem item;
  final VoidCallback onKeep;
  final VoidCallback onDelete;
  final VoidCallback onNeverAskAgain;

  const ReviewCard({
    super.key,
    required this.item,
    required this.onKeep,
    required this.onDelete,
    required this.onNeverAskAgain,
  });

  String _typeLabel(AppLocalizations l) {
    switch (item.type) {
      case FileItemType.photo:
        return l.photo;
      case FileItemType.video:
        return l.video;
      case FileItemType.download:
        return l.download;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return EpuraPanel(
      padding: const EdgeInsets.all(AppTheme.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EpuraIconBubble(icon: _typeIcon),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Wrap(
                      spacing: AppTheme.spaceSM,
                      runSpacing: AppTheme.spaceXS,
                      children: [
                        EpuraPill(icon: _typeIcon, label: _typeLabel(l)),
                        EpuraPill(
                          icon: Icons.storage_outlined,
                          label: formatBytes(item.size),
                        ),
                        EpuraPill(
                          icon: Icons.calendar_today_outlined,
                          label: DateFormat.yMMMd().format(item.date),
                        ),
                        if (item.type == FileItemType.video &&
                            item.durationSeconds != null &&
                            item.durationSeconds! > 0)
                          EpuraPill(
                            icon: Icons.schedule_outlined,
                            label: formatDurationSeconds(item.durationSeconds!),
                          ),
                        if (item.isDuplicateCandidate)
                          EpuraPill(
                            icon: Icons.copy_all_outlined,
                            label: l.duplicateCandidate(
                              item.duplicateGroupIndex ?? 1,
                              item.duplicateGroupSize ?? 2,
                            ),
                          ),
                        if (item.isBurstCandidate)
                          EpuraPill(
                            icon: Icons.burst_mode_outlined,
                            label: l.burstCandidate(
                              item.burstGroupIndex ?? 1,
                              item.burstGroupSize ?? 2,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasCandidateContext) ...[
            const SizedBox(height: AppTheme.spaceSM),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceSM),
                child: Text(
                  _candidateHelp(l),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spaceSM),
          Expanded(child: FilePreview(item: item, enableFullScreen: true)),
          const SizedBox(height: AppTheme.spaceSM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ReviewActionButton(
                  key: const ValueKey('review-delete-button'),
                  icon: Icons.delete_outline,
                  label: l.delete,
                  color: theme.colorScheme.error,
                  onTap: onDelete,
                ),
                _ReviewActionButton(
                  key: const ValueKey('review-keep-button'),
                  icon: Icons.check_circle_outline,
                  label: l.keep,
                  color: theme.colorScheme.primary,
                  filled: true,
                  onTap: onKeep,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSM,
                  vertical: AppTheme.spaceXS,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onNeverAskAgain,
              icon: const Icon(Icons.visibility_off_outlined),
              label: Text(l.neverAskAgain),
            ),
          ),
        ],
      ),
    );
  }

  String _candidateHelp(AppLocalizations l) {
    if (item.isDuplicateCandidate) return l.duplicateCandidateHelp;
    if (item.isBurstCandidate) return l.burstCandidateHelp;
    return '';
  }

  bool get _hasCandidateContext =>
      item.isDuplicateCandidate || item.isBurstCandidate;

  IconData get _typeIcon {
    switch (item.type) {
      case FileItemType.photo:
        return Icons.image_outlined;
      case FileItemType.video:
        return Icons.movie_creation_outlined;
      case FileItemType.download:
        return Icons.description_outlined;
    }
  }
}

class _ReviewActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ReviewActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Theme.of(context).colorScheme.onPrimary : color;

    return Semantics(
      button: true,
      child: SizedBox(
        height: 44,
        child: Material(
          color: filled ? color : Colors.transparent,
          shape: StadiumBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(color: color.withValues(alpha: 0.42)),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(width: AppTheme.spaceSM),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
