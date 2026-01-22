import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> init(Function(NotificationResponse)? onResponse) async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onResponse,
      );
      _isInitialized = true;
      print('NotificationService: Initialized successfully');
    } catch (e) {
      print('NotificationService: Initialization failed: $e');
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> selectedDays,
  }) async {
    final now = DateTime.now();
    
    for (int dayOfWeek in selectedDays) {
      var scheduledDate = _getNextScheduledDate(now, dayOfWeek, hour, minute);
      
      await _notificationsPlugin.zonedSchedule(
        id + dayOfWeek, // Unique ID for each day
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminder_channel_v2',
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
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'medicine_id:$id',
      );
    }
  }

  static DateTime _getNextScheduledDate(DateTime now, int dayOfWeek, int hour, int minute) {
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Calculate days until target day of week (1=Monday, 7=Sunday)
    int currentDayOfWeek = now.weekday;
    int daysUntilTarget = (dayOfWeek - currentDayOfWeek) % 7;
    
    if (daysUntilTarget == 0) {
      // Same day - check if time has passed
      if (scheduledDate.isBefore(now)) {
        daysUntilTarget = 7; // Schedule for next week
      }
    }
    
    return scheduledDate.add(Duration(days: daysUntilTarget));
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

  static Future<void> cancelNotification(int id, List<int> selectedDays) async {
    for (int dayOfWeek in selectedDays) {
      await _notificationsPlugin.cancel(id + dayOfWeek);
    }
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
