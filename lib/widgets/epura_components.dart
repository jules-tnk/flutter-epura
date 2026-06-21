import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EpuraPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const EpuraPill({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSM,
            vertical: AppTheme.spaceXS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: AppTheme.spaceXS),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EpuraIconBubble extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double iconSize;

  const EpuraIconBubble({
    super.key,
    required this.icon,
    this.color,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Icon(icon, color: accent, size: iconSize),
      ),
    );
  }
}

class EpuraPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderSide? border;

  const EpuraPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spaceMD),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = border ?? BorderSide(color: theme.dividerColor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.fromBorderSide(side),
        boxShadow: AppTheme.softShadowFor(context),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class EpuraSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EpuraSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class EpuraTabTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const EpuraTabTitle({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: color),
    );
  }
}

class EpuraMetric {
  final IconData icon;
  final String label;
  final String value;
  final String helper;

  const EpuraMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });
}

class EpuraMetricStrip extends StatelessWidget {
  final List<EpuraMetric> metrics;
  final bool framed;
  final EdgeInsetsGeometry padding;

  const EpuraMetricStrip({
    super.key,
    required this.metrics,
    this.framed = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTheme.spaceSM,
      vertical: AppTheme.spaceMD,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          Expanded(child: _EpuraMetricColumn(metric: metrics[index])),
          if (index < metrics.length - 1)
            SizedBox(
              height: 84,
              child: VerticalDivider(color: Theme.of(context).dividerColor),
            ),
        ],
      ],
    );

    if (!framed) return Padding(padding: padding, child: content);
    return EpuraPanel(padding: padding, child: content);
  }
}

class _EpuraMetricColumn extends StatelessWidget {
  final EpuraMetric metric;

  const _EpuraMetricColumn({required this.metric});

  static const double _labelSlotHeight = 44;
  static const double _valueSlotHeight = 36;
  static const double _helperSlotHeight = 34;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EpuraIconBubble(icon: metric.icon, size: 44, iconSize: 22),
        const SizedBox(height: AppTheme.spaceSM),
        SizedBox(
          height: _labelSlotHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              metric.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(
          height: _valueSlotHeight,
          child: Center(
            child: Text(
              metric.value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
        SizedBox(
          height: _helperSlotHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              metric.helper,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EpuraHeroAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback onPressed;

  const EpuraHeroAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final end = Color.lerp(primary, const Color(0xFF2563EB), 0.45)!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            gradient: LinearGradient(
              colors: disabled
                  ? [
                      context.appColors.textTertiary.withValues(alpha: 0.28),
                      context.appColors.textTertiary.withValues(alpha: 0.18),
                    ]
                  : [primary, end],
            ),
            boxShadow: AppTheme.softShadowFor(context),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.92,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Icon(icon, color: primary, size: 24),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.88,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMD),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EpuraPageHeader extends StatelessWidget {
  final String title;
  final IconData? badgeIcon;
  final String? badgeLabel;
  final Widget? trailing;
  final VoidCallback? onBack;

  const EpuraPageHeader({
    super.key,
    required this.title,
    this.badgeIcon,
    this.badgeLabel,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final backAction = onBack ?? () => Navigator.of(context).maybePop();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: backAction,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppTheme.spaceMD),
              trailing!,
            ],
          ],
        ),
        if (badgeIcon != null && badgeLabel != null) ...[
          const SizedBox(height: AppTheme.spaceSM),
          Padding(
            padding: const EdgeInsets.only(left: 40 + AppTheme.spaceMD),
            child: EpuraPill(icon: badgeIcon!, label: badgeLabel!),
          ),
        ],
      ],
    );
  }
}

class EpuraSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final int subtitleMaxLines;

  const EpuraSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.padding = const EdgeInsets.all(AppTheme.spaceMD),
    this.subtitleMaxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EpuraIconBubble(
                icon: icon,
                color: iconColor,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: subtitleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTheme.spaceMD),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EpuraSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const EpuraSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return EpuraSettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
