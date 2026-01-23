import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  Future<void> init() async {
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermissions() async {
    // 1. Request General Notification Permissions (iOS & Android 13+)
    // This is for the "App would like to send you notifications" popup
    final bool? granted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 2. Request Exact Alarm Permissions (Android 12+)
    // CRITICAL for Calendar apps. Without this, Android might delay your 
    // notification to save battery.
    final bool? exactAlarmGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // 3. iOS Specific permissions are usually handled during .initialize(),
    // but you can also request them explicitly if needed.
    final bool? iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (granted ?? false) || (iosGranted ?? false);
  }

  // Purely technical method: schedules a raw time and body
  Future<void> schedule(int id, String title, String body, DateTime date) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
 