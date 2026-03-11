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

  TimeOfDay get reminderTime => _reminderTime;
  bool get scanPhotos => _scanPhotos;
  bool get scanVideos => _scanVideos;
  bool get scanDownloads => _scanDownloads;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale? get locale => _localeCode != null ? Locale(_localeCode!) : null;
  String? get localeCode => _localeCode;
  DateTime? get lastReviewTimestamp => _lastReviewTimestamp;

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

    final timestampStr = _prefs.getString(_keyLastReviewTimestamp);
    _lastReviewTimestamp =
        timestampStr != null ? DateTime.tryParse(timestampStr) : null;
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (_reminderTime == time) return;
    _reminderTime = time;
    await _prefs.setInt(_keyReminderHour, time.hour);
    await _prefs.setInt(_keyReminderMinute, time.minute);
    notifyListeners();
    await _notificationService.scheduleDailyReminder(time);
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
        // Permission denied — open system settings so user can grant manually
        await openAppSettings();
        return; // don't flip the toggle
      }
      _notificationsEnabled = true;
      await _prefs.setBool(_keyNotificationsEnabled, true);
      notifyListeners();
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      _notificationsEnabled = false;
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
      await _notificationService.scheduleDailyReminder(_reminderTime);
    }
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
}
