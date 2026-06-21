import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/review_mode.dart';
import '../theme/app_theme.dart';
import 'epura_components.dart';
import 'review_mode_catalog.dart';

class ReviewModeGrid extends StatelessWidget {
  final List<ReviewMode> modes;
  final bool disabled;
  final void Function(ReviewMode mode) onSelect;

  const ReviewModeGrid({
    super.key,
    required this.modes,
    required this.onSelect,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 720 ? 3 : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppTheme.spaceSM;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final mode in modes)
              SizedBox(
                width: itemWidth,
                child: _ReviewModeCard(
                  mode: mode,
                  disabled: disabled,
                  onSelect: onSelect,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewModeCard extends StatelessWidget {
  final ReviewMode mode;
  final bool disabled;
  final void Function(ReviewMode mode) onSelect;

  const _ReviewModeCard({
    required this.mode,
    required this.disabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final label = reviewModeLabel(l, mode);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        key: ValueKey('reviewMode:${mode.type}:${mode.folderUri ?? ''}'),
        onTap: disabled ? null : () => onSelect(mode),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: EpuraPanel(
          padding: const EdgeInsets.all(AppTheme.spaceSM),
          child: Row(
            children: [
              EpuraIconBubble(icon: reviewModeIcon(mode), size: 40),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: disabled
                          ? context.appColors.textTertiary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
