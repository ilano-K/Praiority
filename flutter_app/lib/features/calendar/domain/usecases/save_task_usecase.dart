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
    final checkStart = startOfDay(task.startTime!);
    final checkEnd = RRuleUtils.getCheckEnd(task);

    // 1. Fetch existing tasks for conflict checking
    final tasksInRange = await repository.getTasksByRange(checkStart, checkEnd);

    // 2. Conflict Validation
    if (task.type != TaskType.birthday) {
      for (var d = checkStart; !d.isAfter(checkEnd); d = d.add(const Duration(days: 1))) {
        if (TaskUtils.checkTaskConflict(tasksInRange, dateOnly(d), task)) {
          throw TaskConflictException();
        }
      }
    }

    if(!validDateTime(task.startTime!, task.endTime!, task.deadline)){
      throw TaskInvalidTimeException();
    }



    // 3. Database Transaction
    await repository.saveAndUpdateTask(task);

    await scheduleTaskNotification.execute(task);

  }
}