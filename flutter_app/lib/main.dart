// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/core/services/connection_monitor.dart';
import 'package:flutter_app/core/services/notification_service.dart';
import 'package:flutter_app/core/theme/theme_notifier.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:flutter_app/features/calendar/presentation/managers/notification_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/services/local_database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://hilgjdxewhfgpzdkqfyi.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbGdqZHhld2hmZ3B6ZGtxZnlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNzg3NDQsImV4cCI6MjA4NDg1NDc0NH0.BJPHc7yXNt91YjKmpUJ-y45fflSDFdWJGeiUHyfowyk",
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final dbService = LocalDatabaseService();
  await dbService.init();

  final container = ProviderContainer(
    overrides: [localStorageServiceProvider.overrideWithValue(dbService)],
  );

  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();

  container.read(notificationSchedulerProvider).initialize();
  container.read(connectionMonitorProvider).initialize();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      // --- CHANGE THIS FROM MainCalendar TO AuthPage ---
      home: const AuthGate(),
    );
  }
}
