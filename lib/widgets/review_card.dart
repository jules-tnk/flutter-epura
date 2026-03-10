import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import 'file_preview.dart';

class ReviewCard extends StatelessWidget {
  final ReviewItem item;
  final VoidCallback onKeep;
  final VoidCallback onDelete;

  const ReviewCard({
    super.key,
    required this.item,
    required this.onKeep,
    required this.onDelete,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top info section
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Row(
              children: [
                Text(
                  formatBytes(item.size),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Text(
                  DateFormat.yMMMd().format(item.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Chip(
                  label: Text(
                    _typeLabel(l),
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceMD),

            // Middle preview section
            Expanded(
              child: FilePreview(item: item),
            ),

            const SizedBox(height: AppTheme.spaceMD),

            // Bottom action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: l.delete,
                  color: AppTheme.danger,
                  onTap: onDelete,
                ),
                _ActionButton(
                  icon: Icons.check_circle_outline,
                  label: l.keep,
                  color: AppTheme.success,
                  onTap: onKeep,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLG,
          vertical: AppTheme.spaceSM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
