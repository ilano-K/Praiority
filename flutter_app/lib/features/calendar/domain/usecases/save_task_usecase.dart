import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/schedule_task_notification.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/utils/rrule_utils.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final saveTaskUseCaseProvider = Provider((ref) {
  return SaveTaskUseCase(
    ref.watch(calendarRepositoryProvider),
    ref.watch(scheduleTaskNotificationProvider),
  );
});

class SaveTaskUseCase {
  final CalendarRepository repository;
  final ScheduleTaskNotification scheduleTaskNotification;

  SaveTaskUseCase(this.repository, this.scheduleTaskNotification);

  Future<void> execute(Task task) async {
    if (task.status == TaskStatus.pending) {
      await repository.saveAndUpdateTask(task);
      return;
    }

    if (task.endTime != null) {
      final hasInvalidEndtime = task.endTime!.isBefore(task.startTime!);
      if (hasInvalidEndtime) throw EndBeforeStartException();
    }

    if (task.deadline != null && task.endTime != null) {
      final hasInvalidDeadline = task.deadline!.isBefore(task.endTime!);
      if (hasInvalidDeadline) {
        throw DeadlineConflictException();
      }
    }

    // Run conflict checking whenever task has time
    if (task.type != TaskType.birthday &&
        task.endTime != null &&
        task.status != TaskStatus.pending) {
      final checkStart = startOfDay(task.startTime!);
      final checkEnd = RRuleUtils.getCheckEnd(task);

      final tasksInRange = await repository.getTasksByRange(
        checkStart,
        checkEnd,
      );

      final tasks = tasksInRange.where((t) => t.status != TaskStatus.pending);

      for (final taskCurr in tasks) {
        if (taskCurr.id == task.id) continue;

        if (taskCurr.type == TaskType.birthday ||
            taskCurr.status == TaskStatus.completed) {
          continue;
        }

        if (TaskUtils.timeConflict(taskCurr, task)) {
          final existingBlocks = taskCurr.isConflicting;
          final newBlocks = task.isConflicting;

          if (existingBlocks || newBlocks) {
            throw TimeConflictException();
          }
        }
      }
    }

    await repository.saveAndUpdateTask(task);
  }
}
