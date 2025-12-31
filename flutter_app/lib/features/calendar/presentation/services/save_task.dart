import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

  Future <void> saveTask(WidgetRef ref, Task taskTemplate)async{
    final DateTime selectedDate = taskTemplate.startTime!;
    final controller = ref.read(calendarControllerProvider(selectedDate).notifier); 
    await controller.addTask(taskTemplate);
  }