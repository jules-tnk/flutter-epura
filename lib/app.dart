import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'screens/burst_groups_screen.dart';
import 'screens/duplicate_groups_screen.dart';
import 'screens/privacy_permissions_screen.dart';
import 'screens/review_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/storage_insight_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/epura_shell.dart';

class EpuraApp extends StatelessWidget {
  const EpuraApp({super.key});

  static const String routeHome = '/';
  static const String routeReview = '/review';
  static const String routeSummary = '/summary';
  static const String routeSettings = '/settings';
  static const String routeStats = '/stats';
  static const String routeStorageInsight = '/storage-insight';
  static const String routeBurstGroups = '/burst-groups';
  static const String routeDuplicateGroups = '/duplicate-groups';
  static const String routePrivacyPermissions = '/privacy-permissions';
  static const String routePrivacyPolicy = '/privacy-policy';
  static const String routeTermsOfService = '/terms-of-service';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Epura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.resolvedThemeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: routeHome,
      routes: {
        routeHome: (_) => const EpuraShell(),
        routeReview: (_) => const ReviewScreen(),
        routeSummary: (_) => const SummaryScreen(),
        routeSettings: (_) =>
            const EpuraShell(initialTab: EpuraShellTab.settings),
        routeStats: (_) => const EpuraShell(initialTab: EpuraShellTab.stats),
        routeStorageInsight: (_) => const StorageInsightScreen(),
        routeBurstGroups: (_) => const BurstGroupsScreen(),
        routeDuplicateGroups: (_) => const DuplicateGroupsScreen(),
        routePrivacyPermissions: (_) => const PrivacyPermissionsScreen(),
        routePrivacyPolicy: (_) => const PrivacyPolicyScreen(),
        routeTermsOfService: (_) => const TermsOfServiceScreen(),
      },
    );
  }
}
