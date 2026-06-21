import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/folder_profile.dart';
import '../services/document_access_service.dart';
import '../services/notification_service.dart';
import '../services/review_prompt_policy.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyReminderHour = 'reminderHour';
  static const String _keyReminderMinute = 'reminderMinute';
  static const String _keyScanPhotos = 'scanPhotos';
  static const String _keyScanVideos = 'scanVideos';
  static const String _keyCustomFolders = 'customFolders';
  static const String _keyLastReviewTimestamp = 'lastReviewTimestamp';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyLocale = 'locale';
  static const String _keyNotificationInterval = 'notificationInterval';
  static const String _keyNotificationDayOfWeek = 'notificationDayOfWeek';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyHasAcceptedTerms = 'hasAcceptedTerms';
  static const String _keySuccessfulReviewSessionCount =
      'successfulReviewSessionCount';
  static const String _keyReviewPromptDismissed = 'reviewPromptDismissed';

  final NotificationService _notificationService;
  final DocumentAccessService _documentAccessService;
  late final SharedPreferences _prefs;

  SettingsProvider(this._notificationService, this._documentAccessService);

  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _scanPhotos = true;
  bool _scanVideos = true;
  List<FolderProfile> _customFolders = const [];
  bool _notificationsEnabled = false;
  String? _localeCode;
  DateTime? _lastReviewTimestamp;
  String _notificationInterval = 'daily';
  int _notificationDayOfWeek = DateTime.monday;
  DateTime? _nextNotificationTime;
  String _themeMode = 'system';
  bool _hasAcceptedTerms = false;
  int _successfulReviewSessionCount = 0;
  bool _reviewPromptDismissed = false;

  TimeOfDay get reminderTime => _reminderTime;
  bool get scanPhotos => _scanPhotos;
  bool get scanVideos => _scanVideos;
  List<FolderProfile> get customFolders => List.unmodifiable(_customFolders);
  bool get notificationsEnabled => _notificationsEnabled;
  Locale? get locale => _localeCode != null ? Locale(_localeCode!) : null;
  String? get localeCode => _localeCode;
  DateTime? get lastReviewTimestamp => _lastReviewTimestamp;
  String get notificationInterval => _notificationInterval;
  int get notificationDayOfWeek => _notificationDayOfWeek;
  DateTime? get nextNotificationTime => _nextNotificationTime;
  String get themeMode => _themeMode;
  bool get hasAcceptedTerms => _hasAcceptedTerms;
  int get successfulReviewSessionCount => _successfulReviewSessionCount;
  bool get reviewPromptDismissed => _reviewPromptDismissed;

  ThemeMode get resolvedThemeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final hour = _prefs.getInt(_keyReminderHour) ?? 20;
    final minute = _prefs.getInt(_keyReminderMinute) ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);

    _scanPhotos = _prefs.getBool(_keyScanPhotos) ?? true;
    _scanVideos = _prefs.getBool(_keyScanVideos) ?? true;
    _customFolders = (_prefs.getStringList(_keyCustomFolders) ?? const [])
        .map(
          (raw) =>
              FolderProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    _notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? false;
    _localeCode = _prefs.getString(_keyLocale);
    _notificationInterval =
        _prefs.getString(_keyNotificationInterval) ?? 'daily';
    _notificationDayOfWeek =
        _prefs.getInt(_keyNotificationDayOfWeek) ?? DateTime.monday;
    _themeMode = _prefs.getString(_keyThemeMode) ?? 'system';
    _hasAcceptedTerms = _prefs.getBool(_keyHasAcceptedTerms) ?? false;
    _successfulReviewSessionCount =
        _prefs.getInt(_keySuccessfulReviewSessionCount) ?? 0;
    _reviewPromptDismissed = _prefs.getBool(_keyReviewPromptDismissed) ?? false;

    final timestampStr = _prefs.getString(_keyLastReviewTimestamp);
    _lastReviewTimestamp = timestampStr != null
        ? DateTime.tryParse(timestampStr)
        : null;
  }

  Future<void> _persistCustomFolders() async {
    await _prefs.setStringList(
      _keyCustomFolders,
      _customFolders.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  Future<void> _scheduleIfEnabled() async {
    if (_notificationsEnabled) {
      _nextNotificationTime = await _notificationService.scheduleReminder(
        _reminderTime,
        _notificationInterval,
        _notificationDayOfWeek,
        localeCode: _localeCode,
      );
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (_reminderTime == time) return;
    _reminderTime = time;
    await _prefs.setInt(_keyReminderHour, time.hour);
    await _prefs.setInt(_keyReminderMinute, time.minute);
    notifyListeners();
    await _scheduleIfEnabled();
    notifyListeners();
  }

  Future<void> setScanPhotos(bool value) async {
    if (_scanPhotos == value) return;
    _scanPhotos = value;
    await _prefs.setBool(_keyScanPhotos, value);
    notifyListeners();
  }

  Future<void> setScanVideos(bool value) async {
    if (_scanVideos == value) return;
    _scanVideos = value;
    await _prefs.setBool(_keyScanVideos, value);
    notifyListeners();
  }

  Future<FolderProfile?> addCustomFolder() async {
    final folder = await _documentAccessService.pickFolder();
    if (folder == null ||
        _customFolders.any((entry) => entry.uri == folder.uri)) {
      return null;
    }

    final profile = FolderProfile.fromGrant(folder);
    _customFolders = [..._customFolders, profile];
    await _persistCustomFolders();
    notifyListeners();
    return profile;
  }

  Future<void> removeCustomFolder(FolderProfile folder) async {
    _customFolders = _customFolders
        .where((entry) => entry.uri != folder.uri)
        .toList();
    await _persistCustomFolders();
    await _documentAccessService.releasePersistedUriPermission(folder.uri);
    notifyListeners();
  }

  Future<void> renameCustomFolder(FolderProfile folder, String nickname) async {
    final trimmed = nickname.trim();
    _customFolders = _customFolders.map((entry) {
      if (entry.uri != folder.uri) return entry;
      return entry.copyWith(
        nickname: trimmed.isEmpty ? null : trimmed,
        clearNickname: trimmed.isEmpty,
      );
    }).toList();
    await _persistCustomFolders();
    notifyListeners();
  }

  Future<void> markFolderReviewed(String folderUri, DateTime timestamp) async {
    _customFolders = _customFolders.map((entry) {
      if (entry.uri != folderUri) return entry;
      return entry.copyWith(lastReviewedAt: timestamp);
    }).toList();
    await _persistCustomFolders();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    if (value) {
      final granted = await _notificationService.requestPermission();
      if (!granted) {
        await openAppSettings();
        return;
      }
      _notificationsEnabled = true;
      await _prefs.setBool(_keyNotificationsEnabled, true);
      notifyListeners();
      await _scheduleIfEnabled();
      notifyListeners();
    } else {
      _notificationsEnabled = false;
      _nextNotificationTime = null;
      await _prefs.setBool(_keyNotificationsEnabled, false);
      notifyListeners();
      await _notificationService.cancelReminder();
    }
  }

  Future<void> applyNotificationPermissionResult(bool granted) async {
    _notificationsEnabled = granted;
    await _prefs.setBool(_keyNotificationsEnabled, granted);
    notifyListeners();
    if (granted) {
      await _scheduleIfEnabled();
      notifyListeners();
    }
  }

  Future<void> setNotificationInterval(String interval) async {
    if (_notificationInterval == interval) return;
    _notificationInterval = interval;
    await _prefs.setString(_keyNotificationInterval, interval);
    notifyListeners();
    await _scheduleIfEnabled();
    notifyListeners();
  }

  Future<void> setNotificationDayOfWeek(int day) async {
    if (_notificationDayOfWeek == day) return;
    _notificationDayOfWeek = day;
    await _prefs.setInt(_keyNotificationDayOfWeek, day);
    notifyListeners();
    await _scheduleIfEnabled();
    notifyListeners();
  }

  Future<void> setLocale(String? code) async {
    if (_localeCode == code) return;
    _localeCode = code;
    if (code != null) {
      await _prefs.setString(_keyLocale, code);
    } else {
      await _prefs.remove(_keyLocale);
    }
    notifyListeners();
  }

  Future<void> setLastReviewTimestamp(DateTime timestamp) async {
    _lastReviewTimestamp = timestamp;
    await _prefs.setString(
      _keyLastReviewTimestamp,
      timestamp.toIso8601String(),
    );
    notifyListeners();
  }

  Future<void> clearReviewHistory() async {
    _lastReviewTimestamp = null;
    await _prefs.remove(_keyLastReviewTimestamp);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_keyThemeMode, mode);
    notifyListeners();
  }

  Future<void> setHasAcceptedTerms(bool value) async {
    if (_hasAcceptedTerms == value) return;
    _hasAcceptedTerms = value;
    await _prefs.setBool(_keyHasAcceptedTerms, value);
    notifyListeners();
  }

  bool shouldShowReviewPrompt(int failedDeletionCount) {
    return const ReviewPromptPolicy().shouldShow(
      successfulSessionCount: _successfulReviewSessionCount,
      promptDismissed: _reviewPromptDismissed,
      failedDeletionCount: failedDeletionCount,
    );
  }

  Future<void> recordSuccessfulReviewSession({
    required bool hadFailedDeletions,
  }) async {
    if (hadFailedDeletions) return;
    _successfulReviewSessionCount++;
    await _prefs.setInt(
      _keySuccessfulReviewSessionCount,
      _successfulReviewSessionCount,
    );
    notifyListeners();
  }

  Future<void> dismissReviewPrompt() async {
    if (_reviewPromptDismissed) return;
    _reviewPromptDismissed = true;
    await _prefs.setBool(_keyReviewPromptDismissed, true);
    notifyListeners();
  }
}
