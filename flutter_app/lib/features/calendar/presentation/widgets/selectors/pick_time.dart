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
            dialBackgroundColor: colorScheme.surfaceContainerHighest,
            dayPeriodTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
            dayPeriodColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? colorScheme.primary
                  : Colors.transparent,
            ),
            dayPeriodBorderSide: BorderSide(color: colorScheme.primary),
          ),
          // --- TARGETING OK AND CANCEL BUTTONS ---
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Set to Black
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}