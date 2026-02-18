// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/core/consants/auth_constants.dart';
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
    url: AuthConstants.supabaseUrl,
    anonKey: AuthConstants.anonKey,
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
