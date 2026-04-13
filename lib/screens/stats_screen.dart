import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/stats_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static final _dayFormat = DateFormat.E();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = context.read<DatabaseService>();
      context.read<StatsProvider>().loadStats(db);
    });
  }

  List<BarChartGroupData> _buildWeeklyBars(StatsProvider stats, Color barColor) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<int, double> dayBytes = {};
    for (int i = 0; i < 7; i++) {
      dayBytes[i] = 0;
    }

    for (final session in stats.sessions) {
      final sessionDay =
          DateTime(session.date.year, session.date.month, session.date.day);
      final diff = today.difference(sessionDay).inDays;
      if (diff >= 0 && diff < 7) {
        dayBytes[6 - diff] = (dayBytes[6 - diff] ?? 0) +
            session.bytesFreed / (1024 * 1024);
      }
    }

    return dayBytes.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  String _dayLabel(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    return _dayFormat.format(day);
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.stats)),
      body: stats.isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.loadingStats),
                  const SizedBox(height: AppTheme.spaceMD),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
                    child: LinearProgressIndicator(
                      value: stats.loadProgress,
                      backgroundColor: Theme.of(context).dividerColor,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              children: [
                StatCard(
                  icon: Icons.storage_outlined,
                  title: l.totalStorageFreed,
                  value: formatBytes(stats.totalBytesFreed),
                ),
                const SizedBox(height: AppTheme.spaceMD),

                StatCard(
                  icon: Icons.calendar_today_outlined,
                  title: l.freedThisWeek,
                  value: formatBytes(stats.weeklyBytesFreed),
                ),
                const SizedBox(height: AppTheme.spaceMD),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.last7Days,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        SizedBox(
                          height: 160,
                          child: BarChart(
                            BarChartData(
                              barGroups: _buildWeeklyBars(stats, Theme.of(context).colorScheme.primary),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _dayLabel(value.toInt()),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.appColors.textTertiary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),

                StatCard(
                  icon: Icons.local_fire_department_outlined,
                  title: l.streak,
                  value: l.streakDays(stats.streak),
                ),
                const SizedBox(height: AppTheme.spaceMD),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.filesReviewed,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        _BreakdownRow(
                          label: l.totalReviewed,
                          value: '${stats.totalFilesReviewed}',
                        ),
                        _BreakdownRow(
                          label: l.deleted,
                          value: '${stats.totalDeleted}',
                        ),
                        _BreakdownRow(
                          label: l.kept,
                          value:
                              '${stats.totalFilesReviewed - stats.totalDeleted}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),

                if (stats.sessions.isNotEmpty) ...[
                  Text(
                    l.sessionHistory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  ...stats.sessions.map((session) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          DateFormat.yMMMd().format(session.date),
                        ),
                        subtitle: Text(
                          l.filesReviewedCount(session.totalReviewed),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          formatBytes(session.bytesFreed),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: AppTheme.spaceLG),
              ],
            ),
    );
  }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
