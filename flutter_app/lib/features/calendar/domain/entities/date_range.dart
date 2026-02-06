// File: lib/features/calendar/domain/entities/date_range_helper.dart

enum CalendarScope { day, week, month }

/// Immutable object holding a start and end DateTime
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  String toString() => 'DateRange(start: $start, end: $end)';
}

/// Helper class for generating standard DateRanges
class DateRangeHelper {
  static DateRange dayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return DateRange(start: start, end: end);
  }

  static DateRange weekRange(DateTime date) {
    int daysToSubtract = date.weekday % 7; 
    final start = DateTime(date.year, date.month, date.day - daysToSubtract, 0, 0, 0);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return DateRange(start: start, end: end);
  }

  static DateRange monthRange(DateTime date) {
    final start = DateTime(date.year, date.month, 1, 0, 0, 0);
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    final end = DateTime(date.year, date.month, lastDay, 23, 59, 59);
    return DateRange(start: start, end: end);
  }
}

extension DateRangeExtension on DateTime {
  DateRange range(CalendarScope scope) {
    switch (scope) {
      case CalendarScope.day: return DateRangeHelper.dayRange(this);
      case CalendarScope.week: return DateRangeHelper.weekRange(this);
      case CalendarScope.month: return DateRangeHelper.monthRange(this);
    }
  }

  /// AGGRESSIVE BUFFER: Fetches huge chunks of data to ensure smooth scrolling.
  DateRange buffered(CalendarScope scope) {
    DateTime start;
    DateTime end;

    switch (scope) {
      case CalendarScope.day:
        // BUFFER: +/- 30 Days (2 Months total)
        // This allows the user to swipe 30 times before we need to fetch again.
        final base = DateRangeHelper.dayRange(this);
        start = base.start.subtract(const Duration(days: 30)); 
        end = base.end.add(const Duration(days: 30));          
        break;

      case CalendarScope.week:
        // BUFFER: +/- 12 Weeks (3 Months total)
        final base = DateRangeHelper.weekRange(this);
        start = base.start.subtract(const Duration(days: 84)); 
        end = base.end.add(const Duration(days: 84));          
        break;

      case CalendarScope.month:
        // BUFFER: +/- 1 Year (2 Years total)
        start = DateTime(year - 1, month, 1);

        final endOfTargetMonth = DateTime(year + 1, month + 1, 0);
        end = DateTime(
          endOfTargetMonth.year,
          endOfTargetMonth.month,
          endOfTargetMonth.day,
          23,
          59,
          59,
        );
        break;
    }
    return DateRange(start: start, end: end);
  }
}