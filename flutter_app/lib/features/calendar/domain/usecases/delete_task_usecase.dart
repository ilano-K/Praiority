
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/schedule_task_notification.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final deleteTaskUseCaseProvider = Provider((ref) {
  return DeleteTaskUseCase(ref.watch(calendarRepositoryProvider),
                           ref.watch(scheduleTaskNotificationProvider)
                           );
});

class DeleteTaskUseCase {
  final CalendarRepository repository;
  final ScheduleTaskNotification scheduleTaskNotification;

  DeleteTaskUseCase(this.repository, this.scheduleTaskNotification);

  Future<void> execute(Task task) async {
    await repository.deleteTask(task.id);
  }
}