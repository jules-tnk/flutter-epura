import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyReminderHour = 'reminderHour';
  static const String _keyReminderMinute = 'reminderMinute';
  static const String _keyScanPhotos = 'scanPhotos';
  static const String _keyScanVideos = 'scanVideos';
  static const String _keyScanDownloads = 'scanDownloads';
  static const String _keyLastReviewTimestamp = 'lastReviewTimestamp';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyLocale = 'locale';
  static const String _keyNotificationInterval = 'notificationInterval';
  static const String _keyNotificationDayOfWeek = 'notificationDayOfWeek';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyHasAcceptedTerms = 'hasAcceptedTerms';

  final NotificationService _notificationService;
  late final SharedPreferences _prefs;

  SettingsProvider(this._notificationService);

  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _scanPhotos = true;
  bool _scanVideos = true;
  bool _scanDownloads = true;
  bool _notificationsEnabled = false;
  String? _localeCode;
  DateTime? _lastReviewTimestamp;
  String _notificationInterval = 'daily';
  int _notificationDayOfWeek = DateTime.monday;
  DateTime? _nextNotificationTime;
  String _themeMode = 'system';
  bool _hasAcceptedTerms = false;

  TimeOfDay get reminderTime => _reminderTime;
  bool get scanPhotos => _scanPhotos;
  bool get scanVideos => _scanVideos;
  bool get scanDownloads => _scanDownloads;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale? get locale => _localeCode != null ? Locale(_localeCode!) : null;
  String? get localeCode => _localeCode;
  DateTime? get lastReviewTimestamp => _lastReviewTimestamp;
  String get notificationInterval => _notificationInterval;
  int get notificationDayOfWeek => _notificationDayOfWeek;
  DateTime? get nextNotificationTime => _nextNotificationTime;
  String get themeMode => _themeMode;
  bool get hasAcceptedTerms => _hasAcceptedTerms;

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
    _scanDownloads = _prefs.getBool(_keyScanDownloads) ?? true;
    _notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? false;
    _localeCode = _prefs.getString(_keyLocale);
    _notificationInterval = _prefs.getString(_keyNotificationInterval) ?? 'daily';
    _notificationDayOfWeek = _prefs.getInt(_keyNotificationDayOfWeek) ?? DateTime.monday;
    _themeMode = _prefs.getString(_keyThemeMode) ?? 'system';
    _hasAcceptedTerms = _prefs.getBool(_keyHasAcceptedTerms) ?? false;

    final timestampStr = _prefs.getString(_keyLastReviewTimestamp);
    _lastReviewTimestamp =
        timestampStr != null ? DateTime.tryParse(timestampStr) : null;
  }

  /// Schedules the reminder if notifications are enabled.
  /// Does NOT call notifyListeners — callers are responsible for that.
  Future<void> _scheduleIfEnabled() async {
    if (_notificationsEnabled) {
      _nextNotificationTime = await _notificationService.scheduleReminder(
        _reminderTime,
        _notificationInterval,
        _notificationDayOfWeek,
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

  Future<void> setScanDownloads(bool value) async {
    if (_scanDownloads == value) return;
    _scanDownloads = value;
    await _prefs.setBool(_keyScanDownloads, value);
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
        _keyLastReviewTimestamp, timestamp.toIso8601String());
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
}
