import 'package:intl/intl.dart';

/// Converts UI state into an RRule string
String? repeatToRRule(
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

  // --- 1. HANDLE STANDARD OPTIONS ---
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
    'year': 'YEARLY'
  };

  String rrule = "FREQ=${freqMap[unit]};INTERVAL=${interval ?? 1}";

  if (unit == 'month' && start != null) {
    if (monthlyType == 'position') {
      final dayCode = dayCodes[start.weekday % 7];
      final weekIndex = ((start.day - 1) / 7).floor() + 1;
      rrule += ";BYDAY=$weekIndex$dayCode";
    } else {
      rrule += ";BYMONTHDAY=${start.day}";
    }
  }

  if (unit == 'week' && selectedDays != null && selectedDays.isNotEmpty) {
    final sortedDays = selectedDays.toList()..sort();
    final byDay = sortedDays.map((i) => dayCodes[i]).join(',');
    rrule += ";BYDAY=$byDay";
  }

  // --- 3. END CONDITIONS ---
  if (endOption == 'on' && endDate != null) {
    final formattedDate = DateFormat('yyyyMMdd').format(endDate);
    rrule += ";UNTIL=$formattedDate";
  } else if (endOption == 'after' && occurrences != null) {
    rrule += ";COUNT=$occurrences";
  }

  return rrule;
}

/// Converts an RRule string back into a UI label
String rruleToRepeat(String? rrule) {
  if (rrule == null || rrule.isEmpty) return "None";

  // Check standard presets (must have INTERVAL=1 and no end conditions for basic presets)
  if (rrule.contains("FREQ=DAILY;INTERVAL=1") && !rrule.contains("UNTIL") && !rrule.contains("COUNT")) {
    return "Daily";
  }
  
  if (rrule.contains("FREQ=WEEKLY;INTERVAL=1") && !rrule.contains("UNTIL") && !rrule.contains("COUNT")) {
    // If it only has one day (the standard preset logic)
    if (rrule.contains("BYDAY=") && !rrule.contains(",")) return "Weekly";
  }

  if (rrule.contains("FREQ=MONTHLY;INTERVAL=1") && !rrule.contains("UNTIL") && !rrule.contains("COUNT")) {
    return "Monthly";
  }

  if (rrule.contains("FREQ=YEARLY")) {
    return "Yearly";
  }

  // If it doesn't match the simple presets, it's a Custom rule
  return "Custom";
}