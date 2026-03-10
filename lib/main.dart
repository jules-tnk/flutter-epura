import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/file_service.dart';
import 'providers/review_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/thumbnail_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  final notificationService = NotificationService();

  // Init DB and notifications in parallel
  await Future.wait([dbService.init(), notificationService.init()]);

  final settingsProvider = SettingsProvider(notificationService);
  await settingsProvider.init();

  if (settingsProvider.notificationsEnabled) {
    await notificationService.scheduleDailyReminder(settingsProvider.reminderTime);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => FileService()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        Provider.value(value: dbService),
        Provider.value(value: notificationService),
        Provider(create: (_) => ThumbnailCache()),
      ],
      child: const EpuraApp(),
    ),
  );
}
