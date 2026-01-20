// lib/src/shared/widgets/dialogs/app_warning_dialog.dart
import 'package:flutter/material.dart';

class AppWarningDialog extends StatelessWidget {
  final String title;
  final String message;

  const AppWarningDialog({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }
}