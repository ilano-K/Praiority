// Returns a DateTime object with only the date components (year, month, day)

DateTime dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime startOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day);
}
DateTime endOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

DateTime startOfWeek(DateTime date) {
  final sunday = date.subtract(Duration(days: date.weekday % 7));
  return DateTime(sunday.year, sunday.month, sunday.day);
}

DateTime endOfWeek(DateTime date) {
  final saturday = date.add(Duration(days: 6 - (date.weekday % 7)));
  return DateTime(saturday.year, saturday.month, saturday.day, 23, 59, 59);
}


DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1); 
  }
DateTime endOfMonth(DateTime date) {
    final firstOfNextMonth = (date.month < 12) 
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1); // handle December
    return firstOfNextMonth.subtract(const Duration(seconds: 1));
  }

bool validDateTime(DateTime startTime, DateTime endTime, DateTime? deadline){
  if(!startTime.isBefore(endTime)){
    return false;
  }
  // if task type is task 
  if(deadline != null){
    return !deadline.isBefore(endTime);
  }
  return true;
}