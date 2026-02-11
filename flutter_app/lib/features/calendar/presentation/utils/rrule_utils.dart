import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

class RRuleUtils {
  static DateTime getCheckEnd(Task task) {
    final rr = task.recurrenceRule;
    if (rr == null || rr.trim().isEmpty || rr == 'None') {
      return endOfDay(task.startTime!);
    }

    final untilMatch = RegExp(
      r'UNTIL=([0-9T]+Z?)',
      caseSensitive: false,
    ).firstMatch(rr);
    if (untilMatch != null) {
      String s = untilMatch.group(1)!;
      try {
        if (!s.contains('-')) {
          if (s.contains('T')) {
            final y = s.substring(0, 4);
            final m = s.substring(4, 6);
            final d = s.substring(6, 8);
            final time = s.substring(8);
            s = '$y-$m-$d$time'; // Simplified for DateTime.parse
          } else {
            final y = s.substring(0, 4);
            final m = s.substring(4, 6);
            final d = s.substring(6, 8);
            s = '$y-$m-$d';
          }
        }
        return endOfDay(DateTime.parse(s).toLocal());
      } catch (_) {
        return startOfDay(task.startTime!).add(const Duration(days: 365));
      }
    }
    return startOfDay(task.startTime!).add(const Duration(days: 365));
  }
}
