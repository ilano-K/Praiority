import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future <void> deleteTask(WidgetRef ref, String taskId) async {
  final controller = ref.read(calendarControllerProvider.notifier);
  await controller.deleteTask(taskId);

  final notificationService = ref.read(notificationServiceProvider);
  notificationService.cancelNotification(taskId);
}