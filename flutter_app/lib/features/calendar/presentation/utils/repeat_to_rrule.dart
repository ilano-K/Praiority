import 'package:intl/intl.dart';

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

  // --- Handle Standard Options ---
  if (repeat != "Custom") {
    Map<String, String> baseMap = {
      "Daily": "FREQ=DAILY;INTERVAL=1",
      "Weekly": "FREQ=WEEKLY;INTERVAL=1",
      "Monthly": "FREQ=MONTHLY;INTERVAL=1",
      "Yearly": "FREQ=YEARLY;INTERVAL=1",
    };

    String rrule = baseMap[repeat] ?? "FREQ=DAILY;INTERVAL=1";

    if (repeat == 'Weekly' && start != null) {
      const days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      rrule += ';BYDAY=${days[(start.weekday - 1) % 7]}';
    }

    if (repeat == 'Yearly') {
      rrule += ';UNTIL=20991231';
    }
    return rrule;
  }

  // --- Handle Custom Logic ---
  if (unit == null) return "FREQ=DAILY;INTERVAL=1";
  
  final freqMap = {
    'day': 'DAILY',
    'week': 'WEEKLY',
    'month': 'MONTHLY',
    'year': 'YEARLY'
  };

  String rrule = "FREQ=${freqMap[unit]};INTERVAL=${interval ?? 1}";

  // ✅ New Monthly Logic
  if (unit == 'month' && start != null) {
    if (monthlyType == 'position') {
      const dayCodes = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
      final dayCode = dayCodes[start.weekday % 7];
      final weekIndex = ((start.day - 1) / 7).floor() + 1;
      rrule += ";BYDAY=$weekIndex$dayCode";
    } else {
      rrule += ";BYMONTHDAY=${start.day}";
    }
  }

  // Weekly Days logic
  if (unit == 'week' && selectedDays != null && selectedDays.isNotEmpty) {
    const dayCodes = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
    final byDay = selectedDays.map((i) => dayCodes[i]).join(',');
    rrule += ";BYDAY=$byDay";
  }

  // End Conditions
  if (endOption == 'on' && endDate != null) {
    rrule += ";UNTIL=${DateFormat('yyyyMMdd').format(endDate)}";
  } else if (endOption == 'after' && occurrences != null) {
    rrule += ";COUNT=$occurrences";
  }

  return rrule;
}