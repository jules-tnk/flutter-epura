import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/review_session.dart';
import '../providers/stats_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/epura_components.dart';

final _statsMonthDayFormat = DateFormat.MMMd();
final _statsSessionDateFormat = DateFormat.yMMMd();

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = context.read<DatabaseService>();
      context.read<StatsProvider>().loadStats(db);
    });
  }

  List<ReviewSession> _monthlySessions(StatsProvider stats) {
    final now = DateTime.now();
    return stats.sessions
        .where((session) => session.date.year == now.year)
        .where((session) => session.date.month == now.month)
        .toList(growable: false);
  }

  Map<int, double> _monthlyStorageByDay(StatsProvider stats) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final dayBytes = {for (var day = 1; day <= daysInMonth; day++) day: 0.0};

    for (final session in stats.sessions) {
      if (session.date.year != now.year || session.date.month != now.month) {
        continue;
      }
      dayBytes[session.date.day] =
          (dayBytes[session.date.day] ?? 0) + session.bytesFreed / 1048576;
    }

    return dayBytes;
  }

  List<BarChartGroupData> _buildMonthlyBars(
    StatsProvider stats,
    Color barColor,
  ) {
    return _monthlyStorageByDay(stats).entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: barColor,
            width: 6,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _chartMaxY(StatsProvider stats) {
    final maxValue = _monthlyStorageByDay(
      stats,
    ).values.fold<double>(0, math.max);
    if (maxValue <= 0) return 1;
    return maxValue * 1.25;
  }

  String _monthRangeLabel() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final last = DateTime(
      now.year,
      now.month,
      DateUtils.getDaysInMonth(now.year, now.month),
    );
    return '${_statsMonthDayFormat.format(first)} - ${_statsMonthDayFormat.format(last)}';
  }

  Widget _monthDayLabel(double value) {
    final day = value.toInt();
    final now = DateTime.now();
    final lastDay = DateUtils.getDaysInMonth(now.year, now.month);
    if (day != 1 && day != 8 && day != 15 && day != 22 && day != lastDay) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        day == 1
            ? _statsMonthDayFormat.format(DateTime(now.year, now.month))
            : '$day',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l) {
    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const EpuraIconBubble(icon: Icons.query_stats_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Text(
                  l.loadingStats,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          LinearProgressIndicator(
            value: context.watch<StatsProvider>().loadProgress,
            backgroundColor: Theme.of(context).dividerColor,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStrip(AppLocalizations l, StatsProvider stats) {
    return EpuraMetricStrip(
      metrics: [
        EpuraMetric(
          icon: Icons.storage_outlined,
          label: l.storageFreed,
          value: formatBytes(stats.totalBytesFreed),
          helper: l.allTime,
        ),
        EpuraMetric(
          icon: Icons.description_outlined,
          label: l.filesReviewed,
          value: '${stats.monthlyFilesReviewed}',
          helper: l.thisMonth,
        ),
        EpuraMetric(
          icon: Icons.local_fire_department_outlined,
          label: l.streak,
          value: '${stats.streak}',
          helper: l.daysInARow,
        ),
        EpuraMetric(
          icon: Icons.fact_check_outlined,
          label: l.sessions,
          value: '${_monthlySessions(stats).length}',
          helper: l.thisMonth,
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(AppLocalizations l, StatsProvider stats) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasMonthlyStorage = stats.monthlyBytesFreed > 0;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.storageFreedThisMonth,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                _monthRangeLabel(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BarChart(
                  BarChartData(
                    maxY: _chartMaxY(stats),
                    barGroups: _buildMonthlyBars(stats, primary),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: hasMonthlyStorage,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor,
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: hasMonthlyStorage,
                          reservedSize: 72,
                          maxIncluded: false,
                          getTitlesWidget: (value, meta) => Text(
                            formatBytes((value * 1048576).round()),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) =>
                              _monthDayLabel(value),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!hasMonthlyStorage)
                  Text(
                    formatBytes(0),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.appColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(AppLocalizations l, StatsProvider stats) {
    return _ResponsivePair(
      first: EpuraPanel(
        child: _CompactStatBlock(
          icon: Icons.calendar_today_outlined,
          title: l.thisMonth,
          primaryValue: formatBytes(stats.monthlyBytesFreed),
          primaryLabel: l.storageFreed,
          rows: [
            _StatLine(
              label: l.filesReviewed,
              value: '${stats.monthlyFilesReviewed}',
            ),
            _StatLine(label: l.deleted, value: '${stats.monthlyDeleted}'),
          ],
        ),
      ),
      second: EpuraPanel(
        child: _CompactStatBlock(
          icon: Icons.local_fire_department_outlined,
          title: l.streak,
          primaryValue: l.streakDays(stats.streak),
          primaryLabel: l.daysInARow,
          rows: [
            _StatLine(
              label: l.freedThisWeek,
              value: formatBytes(stats.weeklyBytesFreed),
            ),
            _StatLine(
              label: l.totalReviewed,
              value: '${stats.totalFilesReviewed}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInsightEntry(AppLocalizations l) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        onTap: () => Navigator.pushNamed(context, EpuraApp.routeStorageInsight),
        child: EpuraPanel(
          child: Row(
            children: [
              const EpuraIconBubble(icon: Icons.insights_outlined),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.storageInsightTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      l.storageInsightStatsEntryBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesReviewedBreakdown(AppLocalizations l, StatsProvider stats) {
    final keptCount = math.max(
      0,
      stats.totalFilesReviewed - stats.totalDeleted,
    );

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.filesReviewed, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spaceSM),
          _BreakdownRow(
            label: l.totalReviewed,
            value: '${stats.totalFilesReviewed}',
          ),
          _BreakdownRow(label: l.deleted, value: '${stats.totalDeleted}'),
          _BreakdownRow(label: l.kept, value: '$keptCount'),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(AppLocalizations l, StatsProvider stats) {
    if (stats.sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraSectionHeader(title: l.recentSessions),
        const SizedBox(height: AppTheme.spaceSM),
        EpuraPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < stats.sessions.length; index++) ...[
                _SessionRow(session: stats.sessions[index]),
                if (index < stats.sessions.length - 1)
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        children: [
          EpuraTabTitle(title: l.stats),
          const SizedBox(height: AppTheme.spaceLG),
          if (stats.isLoading) ...[
            _buildLoadingState(l),
          ] else ...[
            _buildMetricStrip(l, stats),
            const SizedBox(height: AppTheme.spaceLG),
            _buildMonthlyChart(l, stats),
            const SizedBox(height: AppTheme.spaceLG),
            _buildMonthlySummary(l, stats),
            const SizedBox(height: AppTheme.spaceLG),
            _buildStorageInsightEntry(l),
            const SizedBox(height: AppTheme.spaceLG),
            _buildFilesReviewedBreakdown(l, stats),
            const SizedBox(height: AppTheme.spaceLG),
            _buildSessionHistory(l, stats),
          ],
          const SizedBox(height: AppTheme.spaceLG),
        ],
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsivePair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            children: [
              first,
              const SizedBox(height: AppTheme.spaceSM),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppTheme.spaceSM),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _CompactStatBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String primaryValue;
  final String primaryLabel;
  final List<_StatLine> rows;

  const _CompactStatBlock({
    required this.icon,
    required this.title,
    required this.primaryValue,
    required this.primaryLabel,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            EpuraIconBubble(icon: icon, size: 44, iconSize: 22),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Text(
          primaryValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          primaryLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const Divider(height: AppTheme.spaceLG),
        for (final row in rows)
          _BreakdownRow(label: row.label, value: row.value),
      ],
    );
  }
}

class _StatLine {
  final String label;
  final String value;

  const _StatLine({required this.label, required this.value});
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;

  const _BreakdownRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final ReviewSession session;

  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        children: [
          const EpuraIconBubble(
            icon: Icons.calendar_today_outlined,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statsSessionDateFormat.format(session.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  l.filesReviewedCount(session.totalReviewed),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Text(
            formatBytes(session.bytesFreed),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.spaceXS),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}
