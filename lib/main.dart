import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/file_service.dart';
import 'providers/review_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'services/database_service.dart';
import 'services/document_access_service.dart';
import 'services/notification_service.dart';
import 'services/thumbnail_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  final notificationService = NotificationService();
  const documentAccessService = MethodChannelDocumentAccessService();
  final fileService = FileService(documentAccessService);

  // Init DB, notifications, and file service cache in parallel
  await Future.wait([dbService.init(), notificationService.init(), fileService.init()]);

  final settingsProvider =
      SettingsProvider(notificationService, documentAccessService);
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: fileService),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(documentAccessService),
        ),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        Provider.value(value: dbService),
        Provider.value(value: notificationService),
        Provider<DocumentAccessService>.value(value: documentAccessService),
        ChangeNotifierProvider(create: (_) => ThumbnailCache()),
      ],
      child: const EpuraApp(),
    ),
  );
}
