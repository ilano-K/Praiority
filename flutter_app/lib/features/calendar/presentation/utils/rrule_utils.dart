import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:intl/intl.dart';

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

  static String? repeatToRRule(
    String repeat, {
    DateTime? start,
    int? interval,
    String? unit,
    Set<int>? selectedDays,
    String? endOption,
    DateTime? endDate,
    int? occurrences,
    String? monthlyType, // 'day' or 'position'
  }) {
    if (repeat == "None") return null;

    const dayCodes = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

    // --- 1. HANDLE STANDARD PRESETS ---
    if (repeat != "Custom") {
      String freq;
      String extra = "";

      switch (repeat) {
        case "Daily":
          freq = "DAILY";
          break;
        case "Weekly":
          freq = "WEEKLY";
          if (start != null) {
            final startIndex = start.weekday % 7;
            extra = ";BYDAY=${dayCodes[startIndex]}";
          }
          break;
        case "Monthly":
          freq = "MONTHLY";
          if (start != null) extra = ";BYMONTHDAY=${start.day}";
          break;
        case "Yearly":
          freq = "YEARLY";
          if (start != null) {
            extra = ";BYMONTH=${start.month};BYMONTHDAY=${start.day}";
          }
          break;
        default:
          freq = "DAILY";
      }

      return "FREQ=$freq;INTERVAL=1$extra";
    }

    // --- 2. HANDLE CUSTOM LOGIC ---
    if (unit == null) return "FREQ=DAILY;INTERVAL=1";

    final freqMap = {
      'day': 'DAILY',
      'week': 'WEEKLY',
      'month': 'MONTHLY',
      'year': 'YEARLY',
    };

    String freq = freqMap[unit] ?? 'DAILY';
    int ivl = interval ?? 1;
    String rrule = "FREQ=$freq;INTERVAL=$ivl";

    // --- CUSTOM UNIT HANDLERS ---

    // Year: Pin to the start date's month and day
    if (unit == 'year' && start != null) {
      rrule += ";BYMONTH=${start.month};BYMONTHDAY=${start.day}";
    }

    // Month: Handle "Day 10" vs "Second Tuesday"
    if (unit == 'month' && start != null) {
      if (monthlyType == 'position') {
        final dayCode = dayCodes[start.weekday % 7];
        // Calculate week index (1st, 2nd, 3rd, 4th)
        int weekIndex = ((start.day - 1) / 7).floor() + 1;
        // Google uses -1 for the 5th week to represent "Last [Day]"
        if (weekIndex > 4) weekIndex = -1;
        rrule += ";BYDAY=$weekIndex$dayCode";
      } else {
        rrule += ";BYMONTHDAY=${start.day}";
      }
    }

    // Week: Handle multiple selected days
    if (unit == 'week' && selectedDays != null && selectedDays.isNotEmpty) {
      final sortedDays = selectedDays.toList()..sort();
      final byDay = sortedDays.map((i) => dayCodes[i]).join(',');
      rrule += ";BYDAY=$byDay";
    }

    // --- 3. END CONDITIONS ---
    if (endOption == 'on' && endDate != null) {
      final utcDate = endDate.toUtc();
      final formattedDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(utcDate);
      rrule += ";UNTIL=$formattedDate";
    } else if (endOption == 'after' && occurrences != null) {
      rrule += ";COUNT=$occurrences";
    }

    return rrule;
  }

  static String? sanitizeRRule(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;

    // Regex to find "BYDAY=+2WE", "BYDAY=2WE", or "BYDAY=-1FR"
    // Captures: Group 1 (Number), Group 2 (Day Code)
    final regex = RegExp(r'BYDAY=([+-]?\d+)([A-Z]{2})');

    if (regex.hasMatch(rrule)) {
      // Transform "BYDAY=2WE" -> "BYDAY=WE;BYSETPOS=2"
      return rrule.replaceAllMapped(regex, (match) {
        final number = match.group(1);
        final day = match.group(2);
        return 'BYDAY=$day;BYSETPOS=$number';
      });
    }

    return rrule;
  }

  /// Converts an RRule string back into a UI label.
  static String rruleToRepeat(String? rrule) {
    if (rrule == null || rrule.isEmpty) return "None";

    // Check for complexity first (if it's not a simple preset, it's Custom)
    bool hasEndCondition = rrule.contains("UNTIL") || rrule.contains("COUNT");
    bool hasComplexInterval =
        rrule.contains("INTERVAL=") && !rrule.contains("INTERVAL=1");
    bool hasMultipleDays = rrule.contains(",") && rrule.contains("BYDAY=");

    if (hasEndCondition || hasComplexInterval || hasMultipleDays)
      return "Custom";

    // Strict Preset Matching
    if (rrule.contains("FREQ=DAILY")) return "Daily";

    if (rrule.contains("FREQ=WEEKLY")) return "Weekly";

    if (rrule.contains("FREQ=MONTHLY")) {
      // If it's a relative position (BYDAY), we show it as "Custom" to avoid UI confusion
      return rrule.contains("BYDAY") ? "Custom" : "Monthly";
    }

    if (rrule.contains("FREQ=YEARLY")) return "Yearly";

    return "Custom";
  }
}
