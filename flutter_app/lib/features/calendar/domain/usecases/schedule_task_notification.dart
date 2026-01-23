// features/calendar/domain/usecases/schedule_task_notification.dart
import 'package:flutter_app/core/services/notification_service.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final scheduleTaskNotificationProvider = Provider<ScheduleTaskNotification>((ref) {
  // We grab the core service we just created
  final service = ref.watch(notificationServiceProvider);
  return ScheduleTaskNotification(service);
});

class ScheduleTaskNotification {
  final NotificationService notificationService;

  ScheduleTaskNotification(this.notificationService);

  Future<void> execute(Task task) async {
    // BUSINESS LOGIC: Don't schedule if task is completed
    if (task.status == TaskStatus.completed) return;

    // BUSINESS LOGIC: Notification time (e.g., 10 mins early)
    final reminderTime = task.startTime!.subtract(const Duration(minutes: 10));

    // If the time has already passed, don't schedule
    if (reminderTime.isBefore(DateTime.now())) return;

    await notificationService.schedule(
      task.id.hashCode.abs(),
      'Upcoming Task: ${task.title}',
      'Starting at ${task.startTime}',
      reminderTime,
    );
  }
}