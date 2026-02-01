import 'package:flutter_app/core/errors/task_invalid_time_exception.dart';
import 'package:flutter_app/features/calendar/domain/usecases/schedule_task_notification.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/utils/rrule_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/task_conflict_exception.dart';
import '../entities/enums.dart';
import '../entities/task.dart';
import '../repositories/calendar_repository.dart';
import '../../presentation/utils/task_utils.dart';
import '../../presentation/utils/time_utils.dart';

final saveTaskUseCaseProvider = Provider((ref) {
  return SaveTaskUseCase(ref.watch(calendarRepositoryProvider),
                         ref.watch(scheduleTaskNotificationProvider));
});

class SaveTaskUseCase {
  final CalendarRepository repository;
  final ScheduleTaskNotification scheduleTaskNotification;

  SaveTaskUseCase(this.repository, this.scheduleTaskNotification);

  Future<void> execute(Task task) async {
    // 1. VALIDATION FIRST (Fail fast)
    // Check if start is before end, etc.
    if (!validDateTime(task.startTime!, task.endTime!, task.deadline) && task.isAllDay != true) {
      throw TaskInvalidTimeException();
    }

    // 2. CONFLICT CHECKING
    // We only check for conflicts if:
    // A. It is NOT a Birthday/Holiday (TaskType.task)
    // B. The user enabled "Strict Mode" (task.isConflicting == true)
    if (task.type != TaskType.birthday && task.isConflicting) {
      
      final checkStart = startOfDay(task.startTime!);
      final checkEnd = RRuleUtils.getCheckEnd(task);

      print("[DEBUG] CHECKING CONFLICTS FOR: ${task.title}");

      // Fetch potential conflicts
      final tasksInRange = await repository.getTasksByRange(checkStart, checkEnd);

      for (final taskCurr in tasksInRange) {
        // Skip comparing to itself
        if (taskCurr.id == task.id) continue;

        // Skip non-blocking tasks (like Birthdays or Completed tasks)
        // ✅ FIX: Changed 'return false' to 'continue'
        if (taskCurr.type == TaskType.birthday || taskCurr.status == TaskStatus.completed || !taskCurr.isConflicting ) {
          continue; 
        }

        // Check for actual time overlap
        if (TaskUtils.timeConflict(taskCurr, task)) {
          print("[DEBUG] CONFLICT FOUND WITH: ${taskCurr.title}");
          throw TaskConflictException();
        }
      }
    } else {
      print("[DEBUG] SKIPPING CONFLICT CHECK: ${task.title}");
    }

    // 3. DATABASE TRANSACTION
    await repository.saveAndUpdateTask(task);

    // 4. NOTIFICATION
    await scheduleTaskNotification.execute(task);
  }
}