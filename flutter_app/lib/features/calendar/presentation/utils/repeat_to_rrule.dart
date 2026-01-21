Map<String, String?> _baseMap = {
  "None": null,
  "Daily": "FREQ=DAILY;INTERVAL=1",
  "Weekly": "FREQ=WEEKLY;INTERVAL=1",
  "Monthly": "FREQ=MONTHLY;INTERVAL=1",
  "Yearly": "FREQ=YEARLY;INTERVAL=1",
};

String? repeatToRRule(String repeat, {DateTime? start}) {
  final base = _baseMap[repeat];
  if (base == null) return null;

  // For weekly recurrences, include the BYDAY token derived from the start
  // date so calendar renderers know which weekday to repeat on.
  if (repeat == 'Weekly' && start != null) {
    const days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    final byday = days[(start.weekday - 1) % 7];
    return '$base;BYDAY=$byday';
  }

  return base;
}

String rruleToRepeat(String? rrule) {
  if (rrule == null || rrule.isEmpty) return "None";

  // Check for the Frequency keywords defined in your _baseMap
  if (rrule.contains("FREQ=DAILY")) return "Daily";
  if (rrule.contains("FREQ=WEEKLY")) return "Weekly";
  if (rrule.contains("FREQ=MONTHLY")) return "Monthly";
  if (rrule.contains("FREQ=YEARLY")) return "Yearly";

  return "None";
}