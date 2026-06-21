import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../app_version.dart';
import '../l10n/app_localizations.dart';
import '../models/folder_profile.dart';
import '../providers/file_service.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/document_access_service.dart';
import '../theme/app_theme.dart';
import '../widgets/epura_components.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  Future<void> _refreshSummary(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await context.read<FileService>().refreshAllFiles(
      settings,
      db: context.read<DatabaseService>(),
    );
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
    FolderProfile folder,
  ) async {
    final db = context.read<DatabaseService>();
    await settings.removeCustomFolder(folder);
    await db.clearFileIndexForFolder(folder.uri);
    if (!context.mounted) return;

    await _refreshSummary(context, settings);
    if (!context.mounted) return;
    _showMessage(context, l.folderRemoved(folder.name));
  }

  Future<void> _renameCustomFolder(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l,
    FolderProfile folder,
  ) async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => _RenameFolderDialog(folder: folder),
    );
    if (nickname == null || !context.mounted) return;
    await settings.renameCustomFolder(folder, nickname);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final documentAccess = context.read<DocumentAccessService>();
    final l = AppLocalizations.of(context)!;
    final supportsCustomFolders =
        Platform.isAndroid ||
        documentAccess is! MethodChannelDocumentAccessService;

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        children: [
          EpuraTabTitle(title: l.settings),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.appearance,
            children: [_ThemeModeSelector(settings: settings, l: l)],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.notifications,
            children: [
              EpuraSwitchRow(
                icon: Icons.notifications_outlined,
                title: l.notifications,
                subtitle: l.cleanupReminder,
                value: settings.notificationsEnabled,
                onChanged: (value) async {
                  await settings.setNotificationsEnabled(value);
                  if (context.mounted) _showNextNotifToast(context, settings);
                },
              ),
              if (settings.notificationsEnabled) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMD,
                    0,
                    AppTheme.spaceMD,
                    AppTheme.spaceSM,
                  ),
                  child: Wrap(
                    spacing: AppTheme.spaceSM,
                    runSpacing: AppTheme.spaceSM,
                    children: [
                      ChoiceChip(
                        label: Text(l.daily),
                        selected: settings.notificationInterval == 'daily',
                        onSelected: (_) async {
                          await settings.setNotificationInterval('daily');
                          if (context.mounted) {
                            _showNextNotifToast(context, settings);
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(l.weekly),
                        selected: settings.notificationInterval == 'weekly',
                        onSelected: (_) async {
                          await settings.setNotificationInterval('weekly');
                          if (context.mounted) {
                            _showNextNotifToast(context, settings);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (settings.notificationInterval == 'weekly')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMD,
                      0,
                      AppTheme.spaceMD,
                      AppTheme.spaceSM,
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
                            selected:
                                settings.notificationDayOfWeek == entry.key,
                            onSelected: (_) async {
                              await settings.setNotificationDayOfWeek(
                                entry.key,
                              );
                              if (context.mounted) {
                                _showNextNotifToast(context, settings);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                EpuraSettingsRow(
                  icon: Icons.access_time_outlined,
                  title: l.reminderTime,
                  subtitle: settings.reminderTime.format(context),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (picked != null) {
                      await settings.setReminderTime(picked);
                      if (context.mounted) {
                        _showNextNotifToast(context, settings);
                      }
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.language,
            children: [
              EpuraSettingsRow(
                icon: Icons.language_outlined,
                title: l.language,
                trailing: DropdownButton<String?>(
                  value: settings.localeCode,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) => settings.setLocale(value),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.systemDefault)),
                    DropdownMenuItem(value: 'en', child: Text(l.english)),
                    DropdownMenuItem(value: 'fr', child: Text(l.french)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.fileTypesToScan,
            children: [
              EpuraSwitchRow(
                icon: Icons.photo_outlined,
                title: l.photos,
                value: settings.scanPhotos,
                onChanged: (value) => _updateScanSetting(
                  context,
                  settings,
                  () => settings.setScanPhotos(value),
                ),
              ),
              const Divider(height: 1),
              EpuraSwitchRow(
                icon: Icons.videocam_outlined,
                title: l.videos,
                value: settings.scanVideos,
                onChanged: (value) => _updateScanSetting(
                  context,
                  settings,
                  () => settings.setScanVideos(value),
                ),
              ),
            ],
          ),
          if (supportsCustomFolders) ...[
            const SizedBox(height: AppTheme.spaceLG),
            _SettingsSection(
              title: l.customFoldersToScan,
              children: [
                EpuraSettingsRow(
                  icon: Icons.create_new_folder_outlined,
                  title: l.addCustomFolder,
                  subtitle: l.customFoldersHelp,
                  subtitleMaxLines: 5,
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => _addCustomFolder(context, settings, l),
                ),
                const Divider(height: 1),
                if (settings.customFolders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Text(
                      l.noCustomFolders,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...settings.customFolders.map((folder) {
                    final lastReviewed = folder.lastReviewedAt;
                    final subtitle = lastReviewed == null
                        ? folder.uri
                        : '${folder.name}\n${l.folderLastReviewed(MaterialLocalizations.of(context).formatShortDate(lastReviewed))}\n${folder.uri}';
                    return EpuraSettingsRow(
                      icon: Icons.folder_outlined,
                      title: folder.displayName,
                      subtitle: subtitle,
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: l.renameFolder,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _renameCustomFolder(
                              context,
                              settings,
                              l,
                              folder,
                            ),
                          ),
                          IconButton(
                            tooltip: l.delete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeCustomFolder(
                              context,
                              settings,
                              l,
                              folder,
                            ),
                          ),
                        ],
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
            ),
          ],
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.about,
            children: [
              EpuraSettingsRow(
                icon: Icons.info_outline,
                title: 'Epura',
                subtitle: l.version(appDisplayVersion),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.privacyAndControl,
            children: [
              EpuraSettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: l.privacyPermissions,
                subtitle: l.privacyPermissionsSubtitle,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  EpuraApp.routePrivacyPermissions,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.legal,
            children: [
              EpuraSettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: l.privacyPolicy,
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, EpuraApp.routePrivacyPolicy),
              ),
              const Divider(height: 1),
              EpuraSettingsRow(
                icon: Icons.description_outlined,
                title: l.termsOfService,
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, EpuraApp.routeTermsOfService),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          _SettingsSection(
            title: l.help,
            children: [
              EpuraSettingsRow(
                icon: Icons.help_outline,
                title: l.help,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHelp(context, l),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
        ],
      ),
    );

    if (embedded) return content;
    return Scaffold(body: content);
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final SettingsProvider settings;
  final AppLocalizations l;

  const _ThemeModeSelector({required this.settings, required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppTheme.spaceSM,
        runSpacing: AppTheme.spaceSM,
        children: [
          _buildChoice(value: 'light', label: l.light),
          _buildChoice(value: 'dark', label: l.dark),
          _buildChoice(value: 'system', label: l.systemDefault),
        ],
      ),
    );
  }

  Widget _buildChoice({required String value, required String label}) {
    return _ThemeModeChoice(
      key: ValueKey('theme-choice-$value'),
      label: label,
      selected: settings.themeMode == value,
      onTap: () => settings.setThemeMode(value),
    );
  }
}

class _ThemeModeChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary.withValues(alpha: 0.12);
    final foreground = theme.colorScheme.onSurface;
    final borderColor = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.26)
        : theme.dividerColor;

    return IntrinsicWidth(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? selectedColor : Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: borderColor)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      Icon(Icons.check, size: 20, color: foreground),
                      const SizedBox(width: AppTheme.spaceSM),
                    ],
                    Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpuraSectionHeader(title: title),
        const SizedBox(height: AppTheme.spaceSM),
        EpuraPanel(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _RenameFolderDialog extends StatefulWidget {
  final FolderProfile folder;

  const _RenameFolderDialog({required this.folder});

  @override
  State<_RenameFolderDialog> createState() => _RenameFolderDialogState();
}

class _RenameFolderDialogState extends State<_RenameFolderDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.folder.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l.renameFolder),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: l.folderNickname),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l.save),
        ),
      ],
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
            Text(l.helpStats, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(l.helpStatsBody),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    ),
  );
}
