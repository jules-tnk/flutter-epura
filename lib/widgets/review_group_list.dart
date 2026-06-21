import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../services/thumbnail_cache.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import 'epura_components.dart';
import 'file_preview.dart';

typedef ReviewGroupPositionLabel = String Function(int index, int count);

class ReviewGroupListItem {
  final IconData icon;
  final String title;
  final List<String> details;
  final List<ReviewItem> previewItems;
  final String? compareLabel;
  final String? compareHelp;
  final ReviewGroupPositionLabel? comparePositionLabel;
  final String actionLabel;
  final VoidCallback onAction;
  final String? dismissLabel;
  final VoidCallback? onDismiss;

  const ReviewGroupListItem({
    required this.icon,
    required this.title,
    required this.details,
    required this.previewItems,
    this.compareLabel,
    this.compareHelp,
    this.comparePositionLabel,
    required this.actionLabel,
    required this.onAction,
    this.dismissLabel,
    this.onDismiss,
  });
}

class ReviewGroupListScreen extends StatefulWidget {
  final String title;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<ReviewGroupListItem> items;

  const ReviewGroupListScreen({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.items,
  });

  @override
  State<ReviewGroupListScreen> createState() => _ReviewGroupListScreenState();
}

class _ReviewGroupListScreenState extends State<ReviewGroupListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchCardThumbnails();
    });
  }

  @override
  void didUpdateWidget(covariant ReviewGroupListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items == widget.items) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchCardThumbnails();
    });
  }

  void _prefetchCardThumbnails() {
    if (!mounted) return;

    final previewItems = [
      for (final group in widget.items) ...group.previewItems.take(2),
    ];
    if (previewItems.isEmpty) return;

    unawaited(context.read<ThumbnailCache>().prefetch(previewItems));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          children: [
            EpuraPageHeader(
              title: widget.title,
              badgeIcon: widget.emptyIcon,
              badgeLabel: l.reviewGroupCount(widget.items.length),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            if (widget.items.isEmpty)
              _ReviewGroupEmptyState(
                icon: widget.emptyIcon,
                message: widget.emptyMessage,
              )
            else
              for (var index = 0; index < widget.items.length; index++) ...[
                _ReviewGroupCard(item: widget.items[index]),
                if (index < widget.items.length - 1)
                  const SizedBox(height: AppTheme.spaceMD),
              ],
          ],
        ),
      ),
    );
  }
}

class _ReviewGroupEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ReviewGroupEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: EpuraPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EpuraIconBubble(icon: icon, size: 72, iconSize: 36),
              const SizedBox(height: AppTheme.spaceLG),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewGroupCard extends StatelessWidget {
  final ReviewGroupListItem item;

  const _ReviewGroupCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final previewItems = item.previewItems.take(2).toList();
    final canCompare = _canCompare;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewGroupHeader(item: item),
          const SizedBox(height: AppTheme.spaceMD),
          SizedBox(
            height: 148,
            child: Row(
              children: [
                for (var index = 0; index < previewItems.length; index++) ...[
                  Expanded(child: FilePreview(item: previewItems[index])),
                  if (index < previewItems.length - 1)
                    const SizedBox(width: AppTheme.spaceSM),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          if (canCompare) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openComparison(context),
                icon: const Icon(Icons.compare_outlined),
                label: Text(item.compareLabel!),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: item.onAction,
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(item.actionLabel),
            ),
          ),
          if (item.onDismiss != null && item.dismissLabel != null) ...[
            const SizedBox(height: AppTheme.spaceSM),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: item.onDismiss,
                icon: const Icon(Icons.visibility_off_outlined),
                label: Text(item.dismissLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canCompare =>
      item.compareLabel != null &&
      item.comparePositionLabel != null &&
      item.previewItems.length > 1;

  void _openComparison(BuildContext context) {
    final positionLabel = item.comparePositionLabel;
    if (!_canCompare || positionLabel == null) return;

    unawaited(context.read<ThumbnailCache>().prefetch(item.previewItems));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _ReviewGroupCompareScreen(item: item, positionLabel: positionLabel),
      ),
    );
  }
}

class _ReviewGroupHeader extends StatelessWidget {
  final ReviewGroupListItem item;

  const _ReviewGroupHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraIconBubble(icon: item.icon),
        const SizedBox(width: AppTheme.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spaceXS),
              Wrap(
                spacing: AppTheme.spaceSM,
                runSpacing: AppTheme.spaceXS,
                children: [
                  for (final detail in item.details)
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewGroupCompareScreen extends StatelessWidget {
  final ReviewGroupListItem item;
  final ReviewGroupPositionLabel positionLabel;

  const _ReviewGroupCompareScreen({
    required this.item,
    required this.positionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final help = item.compareHelp;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          children: [
            EpuraPageHeader(title: item.title),
            const SizedBox(height: AppTheme.spaceLG),
            EpuraPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewGroupHeader(item: item),
                  if (help != null) ...[
                    const Divider(height: AppTheme.spaceLG),
                    Text(
                      help,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.previewItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppTheme.spaceSM,
                    mainAxisSpacing: AppTheme.spaceSM,
                    childAspectRatio: columns == 2 ? 0.58 : 0.66,
                  ),
                  itemBuilder: (context, index) {
                    return _ReviewGroupCompareTile(
                      item: item.previewItems[index],
                      positionLabel: positionLabel(
                        index + 1,
                        item.previewItems.length,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: FilledButton.icon(
            onPressed: item.onAction,
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(item.actionLabel),
          ),
        ),
      ),
    );
  }
}

class _ReviewGroupCompareTile extends StatelessWidget {
  final ReviewItem item;
  final String positionLabel;

  const _ReviewGroupCompareTile({
    required this.item,
    required this.positionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return EpuraPanel(
      padding: const EdgeInsets.all(AppTheme.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpuraPill(icon: Icons.photo_outlined, label: positionLabel),
          const SizedBox(height: AppTheme.spaceSM),
          Expanded(child: FilePreview(item: item)),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            '${formatBytes(item.size)} · ${DateFormat.yMMMd().format(item.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
