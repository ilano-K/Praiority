Map<String, String?> repeatToRRuleMap = {
  "None": null,
  "Daily": "FREQ=DAILY;INTERVAL=1",
  "Weekly": "FREQ=WEEKLY;INTERVAL=1",
  "Monthly": "FREQ=MONTHLY;INTERVAL=1",
  "Yearly": "FREQ=YEARLY;INTERVAL=1",
};

String? repeatToRRule(String repeat) {
  return repeatToRRuleMap[repeat];
} 