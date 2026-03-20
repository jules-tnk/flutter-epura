import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/review_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'theme/app_theme.dart';

class EpuraApp extends StatelessWidget {
  const EpuraApp({super.key});

  static const String routeHome = '/';
  static const String routeReview = '/review';
  static const String routeSummary = '/summary';
  static const String routeSettings = '/settings';
  static const String routeStats = '/stats';
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
        routeHome: (_) => const HomeScreen(),
        routeReview: (_) => const ReviewScreen(),
        routeSummary: (_) => const SummaryScreen(),
        routeSettings: (_) => const SettingsScreen(),
        routeStats: (_) => const StatsScreen(),
        routePrivacyPolicy: (_) => const PrivacyPolicyScreen(),
        routeTermsOfService: (_) => const TermsOfServiceScreen(),
      },
    );
  }
}
