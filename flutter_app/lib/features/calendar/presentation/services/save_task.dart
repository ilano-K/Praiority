import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

  Future <void> saveTask(WidgetRef ref, Task taskTemplate)async{
    // Use dateOnly so the DateRange equals the one used by the UI
    final DateRange dateRange = DateRange(scope: CalendarScope.day, startTime: dateOnly(taskTemplate.startTime!));
    final controller = ref.read(calendarControllerProvider.notifier); 
    await controller.addTask(taskTemplate);
  }