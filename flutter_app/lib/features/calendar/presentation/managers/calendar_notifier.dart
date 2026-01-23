import 'dart:async';
import 'package:flutter_app/core/errors/task_conflict_exception.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';

import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';

final calendarControllerProvider = AsyncNotifierProvider<CalendarStateController, List<Task>>(CalendarStateController.new);

class CalendarStateController extends AsyncNotifier<List<Task>>{
  DateRange? _currentRange;
  @override
  FutureOr<List<Task>> build() {
    _currentRange ??=
      DateRange(scope: CalendarScope.day, startTime: DateTime.now());
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
  }
  Future<void>setRange(DateRange range) async {
    _currentRange = range;
    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
    state = AsyncData(updatedList);
  }
  Future<void>addTask(Task task) async {
    final repository = ref.read(calendarRepositoryProvider);
    // Determine the span to check for conflicts.
    // Non-recurring: check only the task's day. Recurring: try to parse UNTIL, else fallback to 1 year horizon.
    final dayStart = startOfDay(task.startTime!);
    DateTime checkStart = dayStart;
    DateTime checkEnd;

    final rr = task.recurrenceRule;
    if (rr == null || rr.trim().isEmpty || rr == 'None') {
      checkEnd = endOfDay(task.startTime!);
    } else {
      // Try to extract UNTIL from RRULE (works with either 'RRULE:...' or raw rule string)
      final untilMatch = RegExp(r'UNTIL=([0-9T]+Z?)', caseSensitive: false).firstMatch(rr);
      if (untilMatch != null) {
        String s = untilMatch.group(1)!;
        try {
          // Normalize formats like YYYYMMDD or YYYYMMDDThhmmssZ to ISO-like before parsing
          if (!s.contains('-')) {
            if (s.contains('T')) {
              final y = s.substring(0, 4);
              final m = s.substring(4, 6);
              final d = s.substring(6, 8);
              final time = s.substring(8); // ThhmmssZ
              final hh = time.substring(1, 3);
              final mm = time.substring(3, 5);
              final ss = time.substring(5, 7);
              final rest = time.length > 7 ? time.substring(7) : '';
              s = '$y-$m-$d$time$hh:$mm:$ss$rest';
            } else {
              final y = s.substring(0, 4);
              final m = s.substring(4, 6);
              final d = s.substring(6, 8);
              s = '$y-$m-$d';
            }
          }
          final until = DateTime.parse(s).toLocal();
          checkEnd = endOfDay(until);
        } catch (_) {
          checkEnd = startOfDay(task.startTime!).add(const Duration(days: 365));
        }
      } else {
        checkEnd = startOfDay(task.startTime!).add(const Duration(days: 365));
      }
    }

    // Fetch all tasks once for the whole span, then check day-by-day for conflicts.
    final tasksInRange = await repository.getTasksByRange(checkStart, checkEnd);

    if(task.type != TaskType.birthday){
      for (var d = checkStart; !d.isAfter(checkEnd); d = d.add(const Duration(days: 1))) {
        if (TaskUtils.checkTaskConflict(tasksInRange, dateOnly(d), task)) {
          throw TaskConflictException();
        }
      }
    }
    await repository.saveAndUpdateTask(task);

    final currentTasks = state.value ?? [];
    final isEdit = currentTasks.any((t) => t.id == task.id);

    List<Task> updatedList;
    if (isEdit) {
      updatedList = currentTasks.map((t) => t.id == task.id ? task : t).toList();
    } else {
      // If it's a new task, we add it. 
      // Note: You might want to sort it by time here so it appears in the right spot!
      updatedList = [...currentTasks, task];
      updatedList.sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
    }

    // 3. Directly set the state to AsyncData
    // This causes Flutter to update the UI tiles smoothly without "blinking"
    state = AsyncData(updatedList);
  }

  Future<void>deleteTask(String taskId) async {
    final repository = ref.read(calendarRepositoryProvider);
    await repository.deleteTask(taskId);
    final currentTasks = state.value ?? [];
    final updatedList = currentTasks.where((t) => t.id != taskId).toList();
    state = AsyncData(updatedList);
  }

  Future<void>addTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider); 
    await repository.saveTag(tag);

    //to ensure no blinking
    final currentTasks = state.value ?? [];
    state = AsyncData(currentTasks);
  }

  Future<void>deleteTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider); 
    await repository.deleteTag(tag);
  }

  Future<void>getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag,
                                              }) async {
    final repository = ref.read(calendarRepositoryProvider);
    state = await AsyncValue.guard(() async {
      return repository.getTasksByCondition(
                                            start: start, end: end, 
                                            category: category, type: type, 
                                            status: status, tag: tag
                                            );
    });
  }
}

