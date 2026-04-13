import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/scan_folder_grant.dart';
import '../providers/file_service.dart';
import '../providers/settings_provider.dart';
import '../services/document_access_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _refreshSummary(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await context.read<FileService>().refreshAllFiles(settings);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateScanSetting(
    BuildContext context,
    SettingsProvider settings,
    Future<void> Function() update,
  ) async {
    await update();
    if (context.mounted) {
      await _refreshSummary(context, settings);
    }
  }

  Future<void> _addCustomFolder(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l,
  ) async {
    final folder = await settings.addCustomFolder();
    if (folder == null || !context.mounted) return;

    await _refreshSummary(context, settings);
    if (!context.mounted) return;
    _showMessage(context, l.folderAdded(folder.name));
  }

  Future<void> _removeCustomFolder(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l,
    ScanFolderGrant folder,
  ) async {
    await settings.removeCustomFolder(folder);
    if (!context.mounted) return;

    await _refreshSummary(context, settings);
    if (!context.mounted) return;
    _showMessage(context, l.folderRemoved(folder.name));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final documentAccess = context.read<DocumentAccessService>();
    final l = AppLocalizations.of(context)!;
    final supportsCustomFolders =
        Platform.isAndroid || documentAccess is! MethodChannelDocumentAccessService;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceMD,
              top: AppTheme.spaceMD,
              bottom: AppTheme.spaceSM,
            ),
            child: Text(
              l.appearance,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceSM,
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l.light),
                  selected: settings.themeMode == 'light',
                  onSelected: (_) => settings.setThemeMode('light'),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                ChoiceChip(
                  label: Text(l.dark),
                  selected: settings.themeMode == 'dark',
                  onSelected: (_) => settings.setThemeMode('dark'),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                ChoiceChip(
                  label: Text(l.systemDefault),
                  selected: settings.themeMode == 'system',
                  onSelected: (_) => settings.setThemeMode('system'),
                ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l.notifications),
            subtitle: Text(l.cleanupReminder),
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              await settings.setNotificationsEnabled(value);
              if (context.mounted) _showNextNotifToast(context, settings);
            },
          ),
          if (settings.notificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceSM,
              ),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l.daily),
                    selected: settings.notificationInterval == 'daily',
                    onSelected: (_) async {
                      await settings.setNotificationInterval('daily');
                      if (context.mounted) _showNextNotifToast(context, settings);
                    },
                  ),
                  const SizedBox(width: AppTheme.spaceSM),
                  ChoiceChip(
                    label: Text(l.weekly),
                    selected: settings.notificationInterval == 'weekly',
                    onSelected: (_) async {
                      await settings.setNotificationInterval('weekly');
                      if (context.mounted) _showNextNotifToast(context, settings);
                    },
                  ),
                ],
              ),
            ),
          if (settings.notificationsEnabled &&
              settings.notificationInterval == 'weekly')
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceSM,
              ),
              child: Wrap(
                spacing: AppTheme.spaceSM,
                runSpacing: AppTheme.spaceSM,
                children: [
                  for (final entry in {
                    DateTime.monday: l.monday,
                    DateTime.tuesday: l.tuesday,
                    DateTime.wednesday: l.wednesday,
                    DateTime.thursday: l.thursday,
                    DateTime.friday: l.friday,
                    DateTime.saturday: l.saturday,
                    DateTime.sunday: l.sunday,
                  }.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: settings.notificationDayOfWeek == entry.key,
                      onSelected: (_) async {
                        await settings.setNotificationDayOfWeek(entry.key);
                        if (context.mounted) _showNextNotifToast(context, settings);
                      },
                    ),
                ],
              ),
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
                  if (context.mounted) _showNextNotifToast(context, settings);
                }
              },
            ),
          const Divider(),
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
            onChanged: (value) => _updateScanSetting(
              context,
              settings,
              () => settings.setScanPhotos(value),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.videocam_outlined),
            title: Text(l.videos),
            value: settings.scanVideos,
            onChanged: (value) => _updateScanSetting(
              context,
              settings,
              () => settings.setScanVideos(value),
            ),
          ),
          if (supportsCustomFolders) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spaceMD,
                top: AppTheme.spaceMD,
                bottom: AppTheme.spaceSM,
              ),
              child: Text(
                l.customFoldersToScan,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l.addCustomFolder),
              subtitle: Text(l.customFoldersHelp),
              onTap: () => _addCustomFolder(context, settings, l),
            ),
            if (settings.customFolders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                  vertical: AppTheme.spaceSM,
                ),
                child: Text(
                  l.noCustomFolders,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                ),
              )
            else
              ...settings.customFolders.map((folder) {
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder.name),
                  subtitle: Text(
                    folder.uri,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        _removeCustomFolder(context, settings, l, folder),
                  ),
                );
              }),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMD,
                0,
                AppTheme.spaceMD,
                AppTheme.spaceMD,
              ),
              child: Text(
                l.downloadFolderSelectionHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
              ),
            ),
          ],
          const Divider(),
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
            subtitle: Text(l.version('1.0.12')),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceMD,
              top: AppTheme.spaceMD,
              bottom: AppTheme.spaceSM,
            ),
            child: Text(
              l.legal,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicy),
            onTap: () => Navigator.pushNamed(
              context,
              EpuraApp.routePrivacyPolicy,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.termsOfService),
            onTap: () => Navigator.pushNamed(
              context,
              EpuraApp.routeTermsOfService,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l.help),
            onTap: () => _showHelp(context, l),
          ),
        ],
      ),
    );
  }
}

void _showNextNotifToast(BuildContext context, SettingsProvider settings) {
  final next = settings.nextNotificationTime;
  if (next == null || !settings.notificationsEnabled) return;

  final now = DateTime.now();
  final diff = next.difference(now);

  String timeStr;
  if (diff.inDays > 0) {
    final hours = diff.inHours % 24;
    timeStr = '${diff.inDays}d ${hours}h';
  } else if (diff.inHours > 0) {
    final minutes = diff.inMinutes % 60;
    timeStr = '${diff.inHours}h ${minutes}m';
  } else if (diff.inMinutes > 0) {
    timeStr = '${diff.inMinutes}m';
  } else {
    timeStr = '${diff.inSeconds}s';
  }

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text('Next notification in $timeStr'),
        duration: const Duration(seconds: 4),
      ),
    );
}

void _showHelp(BuildContext context, AppLocalizations l) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.helpWhatIsEpura,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpWhatIsEpuraBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.helpHowItWorks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpHowItWorksBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.helpNotifications,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpNotificationsBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.helpLookback,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpLookbackBody),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              l.helpStats,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpStatsBody),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    ),
  );
}
