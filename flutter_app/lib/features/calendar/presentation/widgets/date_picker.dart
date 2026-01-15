import 'package:flutter/material.dart';

Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime now = DateTime.now();
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(2020),
    lastDate: lastDate ?? DateTime(2030),
    builder: (context, child) {
      final colorScheme = Theme.of(context).colorScheme;
      
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: colorScheme,
          // --- TARGETING OK AND CANCEL BUTTONS ---
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface, // Text color for OK/Cancel
            ),
          ),
        ),
        child: child!,
      );
    },
  );
  return picked;
}