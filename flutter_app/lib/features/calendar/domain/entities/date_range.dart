import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

enum CalendarScope {day, week, month}

class DateRange{
  CalendarScope? scope;
  final DateTime startTime;
  DateTime? endTime;

  DateRange({
    this.scope,
    required this.startTime,
    this.endTime
  });

  DateTime get start {
    final map = {
      CalendarScope.day: startOfDay(startTime),
      CalendarScope.week: startOfWeek(startTime),
      CalendarScope.month: startOfMonth(startTime)
    };
    return map[scope] ?? startTime;
  }

  DateTime get end {
    final map = {
      CalendarScope.day: endOfDay(startTime),
      CalendarScope.week: endOfWeek(startTime),
      CalendarScope.month: endOfMonth(startTime)
    };
    return map[scope] ?? endTime!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DateRange &&
      other.scope == scope &&
      other.startTime.isAtSameMomentAs(startTime) &&
      ((other.endTime == null && endTime == null) || (other.endTime != null && endTime != null && other.endTime!.isAtSameMomentAs(endTime!)));
  }

  @override
  int get hashCode => Object.hash(
    scope,
    startTime.toUtc().millisecondsSinceEpoch,
    endTime?.toUtc().millisecondsSinceEpoch ?? 0,
  );
}