import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init(Function(NotificationResponse)? onResponse) async {
    tz.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        print('NotificationService: Local location set to ${tz.local.name}');
      } catch (e) {
        print(
          'NotificationService: Failed to set local location, using UTC: $e',
        );
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onResponse,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      print(
        'NotificationService: Time $hour:$minute has already passed for today. Triggering immediate notification.',
      );

      // Trigger immediate notification for today's dose if added late
      await showImmediateNotification(
        id: id + 100000, // Offset to avoid ID collision
        title: '$title (Today\'s Dose)',
        body:
            'Reminder for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}: $body',
      );

      // Schedule for tomorrow
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print(
      'NotificationService: Scheduling recurring at $scheduledDate (TZ: ${tz.local.name})',
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminder_channel_v2', // Changed ID to ensure update
          'Medicine Reminders',
          channelDescription: 'Channel for medicine reminders',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          ticker: 'Medicine Reminder',
          styleInformation: BigTextStyleInformation(''),
          enableVibration: true,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'Time to take $title: $body',
    );
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_reminder_channel_test',
        'Test Reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    );
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'Time to take $title: $body',
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }
}
