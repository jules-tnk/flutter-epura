import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../theme/app_theme.dart';

enum EpuraShellTab { home, stats, settings }

class EpuraShell extends StatefulWidget {
  final EpuraShellTab initialTab;

  const EpuraShell({super.key, this.initialTab = EpuraShellTab.home});

  @override
  State<EpuraShell> createState() => _EpuraShellState();
}

class _EpuraShellState extends State<EpuraShell> {
  late EpuraShellTab _currentTab;
  final Map<EpuraShellTab, Widget> _builtTabs = {};

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(EpuraShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _currentTab = widget.initialTab;
    }
  }

  Widget _tabBody(EpuraShellTab tab) {
    return _builtTabs.putIfAbsent(tab, () {
      return switch (tab) {
        EpuraShellTab.home => const HomeScreen(embedded: true),
        EpuraShellTab.stats => const StatsScreen(),
        EpuraShellTab.settings => const SettingsScreen(embedded: true),
      };
    });
  }

  NavigationDestination _destinationFor(EpuraShellTab tab, AppLocalizations l) {
    return switch (tab) {
      EpuraShellTab.home => NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l.home,
      ),
      EpuraShellTab.stats => NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: l.stats,
      ),
      EpuraShellTab.settings => NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l.settings,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tabs = EpuraShellTab.values;
    final activeIndex = tabs.indexOf(_currentTab);
    _tabBody(_currentTab);
    const navigationRadius = BorderRadius.vertical(
      top: Radius.circular(AppTheme.radiusLG),
    );

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: [
          for (final tab in tabs) _builtTabs[tab] ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        key: const ValueKey('epura-shell-navigation-frame'),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: navigationRadius,
        ),
        child: ClipRRect(
          borderRadius: navigationRadius,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: activeIndex,
            onDestinationSelected: (index) {
              setState(() => _currentTab = tabs[index]);
            },
            destinations: [for (final tab in tabs) _destinationFor(tab, l)],
          ),
        ),
      ),
    );
  }
}
