import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_warning_dialog.dart';

class AppDialogs {
  /// Shows a standard warning/error alert
  static Future<void> showWarning(BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppWarningDialog(title: title, message: message),
    );
  }

  /// Shows a confirmation dialog (Yes/No style)
  static Future<void> showConfirmation(BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = "Confirm",
    bool isDestructive = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
  }
}