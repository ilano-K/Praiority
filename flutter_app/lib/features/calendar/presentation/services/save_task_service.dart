import 'package:flutter/cupertino.dart';
import 'package:flutter_app/core/errors/task_invalid_time_exception.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

Future <void> saveTask(WidgetRef ref, Task taskTemplate)async{
  // if invalid time slot. ex: jan 1, 10pm - jan 1, 5am
  if(taskTemplate.type == TaskType.task){
    if(!validDateTime(taskTemplate.startTime!, taskTemplate.endTime!, 
    taskTemplate.deadline!)){throw TaskInvalidTimeException();}
  }

  // controller and notif service
  final controller = ref.read(calendarControllerProvider.notifier); 
  final notificationService = ref.read(notificationServiceProvider);

  if(taskTemplate.startTime != null){
    final DateTime scheduledTime = taskTemplate.startTime!;

    if(scheduledTime.isAfter(DateTime.now())){
      await notificationService.scheduleCalendarEvent(
        id: taskTemplate.id, 
        title: taskTemplate.title, 
        body: taskTemplate.description ?? "", 
        scheduledDate: scheduledTime
        );
    }
  }
  await controller.addTask(taskTemplate);
}