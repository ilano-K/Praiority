import 'dart:async';
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/core/services/notification_service.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationScheduler(repository, notificationService);
});

class NotificationScheduler {
  final CalendarRepository _repository;
  final NotificationService _notificationService;
  
  // FIXED: Track Notification IDs (hash ^ offset), NOT Task IDs
  Set<int> _scheduledNotificationIds = {};
  StreamSubscription? _subscription;

  NotificationScheduler(this._repository, this._notificationService);

  void initialize() {
    _subscription?.cancel();
    _subscription = _repository.watchFutureTasks().listen((tasks) {
      _manageNotifications(tasks);
    });
  }

  Future<void> _manageNotifications(List<Task> tasks) async {
    final now = DateTime.now();
    final List<_PendingNotification> desiredNotifications = [];

    // 1. FLATTEN: Convert Tasks -> Pending Notifications
    for (var task in tasks) {
      // Skip completed or invalid tasks
      if (task.startTime == null || task.status == TaskStatus.completed) continue;

      for (var offset in task.reminderOffsets) {
        final triggerTime = task.startTime!.subtract(offset);

        // Only schedule if the trigger time is in the future
        if (triggerTime.isAfter(now)) {
          // Generate Unique ID: TaskHash XOR OffsetMinutes
          // This allows multiple reminders per task to have distinct IDs
          final uniqueId = task.id.hashCode ^ offset.inMinutes;

          desiredNotifications.add(_PendingNotification(
            id: uniqueId,
            title: "Reminder: ${task.title}",
            body: _getBodyText(offset),
            triggerDate: triggerTime,
          ));
        }
      }
    }

    // 2. CALCULATE DIFF (The Magic Step)
    final desiredIds = desiredNotifications.map((n) => n.id).toSet();

    // Find IDs that are currently scheduled but NOT in the new list (To Cancel)
    final idsToCancel = _scheduledNotificationIds.difference(desiredIds);
    
    // 3. EXECUTE CANCELLATIONS
    for (var id in idsToCancel) {
      await _notificationService.cancel(id);
    }

    // 4. EXECUTE SCHEDULES (Updates existing ones automatically)
    for (var notification in desiredNotifications) {
      await _notificationService.schedule(
        notification.id,
        notification.title,
        notification.body,
        notification.triggerDate,
      );
    }

    // 5. UPDATE CACHE
    _scheduledNotificationIds = desiredIds;
  }

  String _getBodyText(Duration offset) {
    if (offset.inMinutes == 0) return "Happening now!";
    if (offset.inMinutes < 60) return "Starting in ${offset.inMinutes} minutes.";
    if (offset.inHours == 1) return "Starting in 1 hour.";
    return "Starting in ${offset.inHours} hours.";
  }

  void dispose() {
    _subscription?.cancel();
  }
}

// Helper Class
class _PendingNotification {
  final int id;
  final String title;
  final String body;
  final DateTime triggerDate;

  _PendingNotification({
    required this.id, 
    required this.title, 
    required this.body, 
    required this.triggerDate
  });
}