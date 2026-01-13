// File: lib/main.dart
// Purpose: Application entry point; initializes services and runs the app.
import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/theme/theme_notifier.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_app/features/calendar/presentation/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/services/local_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = LocalDatabaseService();
  await dbService.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(dbService),
      ],
      child: const MyApp(),
      )
    );
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final dbService = LocalDatabaseService();
//   await dbService.init();

//   // Create a ProviderContainer to interact with Riverpod providers
//   final container = ProviderContainer(
//     overrides: [
//       localStorageServiceProvider.overrideWithValue(dbService),
//     ],
//   );

//   // Quick test: add a task for today
//   final selectedDate = DateTime.now();
//   final controller = container.read(calendarControllerProvider(selectedDate).notifier);

//   await controller.addTask(Task(
//     id: DateTime.now().millisecondsSinceEpoch.toString(),
//     title: 'Test Task',
//     description: 'Added from main() for testing',
//     startTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 14),
//     endTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 15),
//     isAllDay: true
//   ));

//   // Print tasks to check if it's added
//   final tasks = await container.read(calendarControllerProvider(selectedDate).future);
//   print('Tasks for $selectedDate: $tasks');

//   // Run the app normally
//   runApp(
//     ProviderScope(
//       overrides: [
//         localStorageServiceProvider.overrideWithValue(dbService),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }


//themes
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = LocalDatabaseService();
  await dbService.init();

  runApp(ChangeNotifierProvider(
    create: (Context) => ThemeProvider(),
    child: const MyApp(),
    ));
}*/

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const MainCalendar(),
    );
  }
}
