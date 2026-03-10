import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l.notifications),
            subtitle: Text(l.dailyCleanupReminder),
            value: settings.notificationsEnabled,
            onChanged: (value) => settings.setNotificationsEnabled(value),
          ),
          if (settings.notificationsEnabled)
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: Text(l.reminderTime),
              subtitle: Text(settings.reminderTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.reminderTime,
                );
                if (picked != null) {
                  await settings.setReminderTime(picked);
                }
              },
            ),
          const Divider(),

          // Language
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceMD,
              top: AppTheme.spaceMD,
              bottom: AppTheme.spaceSM,
            ),
            child: Text(
              l.language,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l.language),
            trailing: DropdownButton<String?>(
              value: settings.localeCode,
              underline: const SizedBox.shrink(),
              onChanged: (value) => settings.setLocale(value),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l.systemDefault),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l.english),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(l.french),
                ),
              ],
            ),
          ),
          const Divider(),

          // Scan toggles
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceMD,
              top: AppTheme.spaceMD,
              bottom: AppTheme.spaceSM,
            ),
            child: Text(
              l.fileTypesToScan,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.photo_outlined),
            title: Text(l.photos),
            value: settings.scanPhotos,
            onChanged: (value) => settings.setScanPhotos(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.videocam_outlined),
            title: Text(l.videos),
            value: settings.scanVideos,
            onChanged: (value) => settings.setScanVideos(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.download_outlined),
            title: Text(l.downloads),
            value: settings.scanDownloads,
            onChanged: (value) => settings.setScanDownloads(value),
          ),

          const Divider(),

          // About
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceMD,
              top: AppTheme.spaceMD,
              bottom: AppTheme.spaceSM,
            ),
            child: Text(
              l.about,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Epura'),
            subtitle: Text(l.version('1.0.0')),
          ),
        ],
      ),
    );
  }
}
