import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); // Required for scheduling at specific times
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // This triggers when a user taps the notification
        print("Notification tapped: ${details.payload}");
        // logic here maybe
      },
    );
  }
  static Future<void> requestPermissions() async {
  // Request notification permission (iOS and Android 13+)
  await _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  // Request Exact Alarm permission (Crucial for Calendar Apps)
  await _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
  }
  Future<void> scheduleCalendarEvent({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id.hashCode.abs(),
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'calendar_reminders', 
          'Calendar Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  Future<void> cancelNotification(String id) async {
    int notificationId = id.hashCode.abs();
    await _plugin.cancel(notificationId);
    print("Notification $notificationId (Original ID: $id) canceled.");
  }
}