// Returns a DateTime object with only the date components (year, month, day)
DateTime dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}