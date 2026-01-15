import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_app/features/calendar/presentation/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future <void> deleteTask(WidgetRef ref, String taskId) async {
  final controller = ref.read(calendarControllerProvider.notifier);
  await controller.deleteTask(taskId);

  final notificationService = ref.read(notificationServiceProvider);
  notificationService.cancelNotification(taskId);
}