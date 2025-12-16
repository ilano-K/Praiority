import 'package:flutter/material.dart';

Future<TimeOfDay?> pickTime(BuildContext context, {TimeOfDay? initialTime}) async {
  final colorScheme = Theme.of(context).colorScheme;

  return showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: colorScheme.surface,
            dialHandColor: colorScheme.primary,
            dialTextColor: colorScheme.onSurface,
            dialBackgroundColor: colorScheme.surfaceVariant,
            dayPeriodTextColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.selected)
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
            dayPeriodColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.selected)
                  ? colorScheme.primary
                  : Colors.transparent,
            ),
            dayPeriodBorderSide: BorderSide(color: colorScheme.primary),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ),
        child: child!,
      );
    },
  );
}
