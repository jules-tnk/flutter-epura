import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const int _reminderId = 0;
  static const String _channelId = 'epura_reminders';
  static const String _channelName = 'Cleanup Reminders';
  static const String _title = 'Time to clean up!';
  static const String _body = 'Take a moment to review your files';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? _androidPlugin;

  Future<void> init() async {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    _androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await _androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      ),
    );
  }

  Future<bool> requestExactAlarmPermission() async {
    if (_androidPlugin == null) return true;

    final canSchedule = await _androidPlugin!.canScheduleExactNotifications();
    if (canSchedule ?? false) return true;

    final granted = await _androidPlugin!.requestExactAlarmsPermission();
    return granted ?? false;
  }

  Future<bool> requestPermission() async {
    if (_androidPlugin == null) return true;

    final notifGranted =
        await _androidPlugin!.requestNotificationsPermission();
    if (!(notifGranted ?? false)) return false;

    await requestExactAlarmPermission();

    return true;
  }

  /// Schedules a reminder and returns the exact [DateTime] it is scheduled for.
  Future<DateTime> scheduleReminder(
    TimeOfDay time,
    String interval,
    int dayOfWeek,
  ) async {
    await cancelReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final DateTimeComponents matchComponents;

    if (interval == 'weekly') {
      while (scheduledDate.weekday != dayOfWeek) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }
      matchComponents = DateTimeComponents.dayOfWeekAndTime;
    } else {
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      matchComponents = DateTimeComponents.time;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    if (_androidPlugin != null) {
      final canExact = await _androidPlugin!.canScheduleExactNotifications();
      if (!(canExact ?? false)) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: _title,
      body: _body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: matchComponents,
    );

    return scheduledDate;
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(id: _reminderId);
  }
}
