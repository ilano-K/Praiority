import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_page.dart'; // Your Toggle Page
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart'; // Your Home Page


class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {

  @override
  void initState() {
    super.initState();
    // -------------------------------------------------------------------------
    // 1. COLD START SYNC (When user opens app and is ALREADY logged in)
    // -------------------------------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Run sync in background (fire and forget)
        ref.read(taskSyncServiceProvider).syncAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 2. ACTIVE LOGIN SYNC (When user clicks "Sign In" successfully)
    // -------------------------------------------------------------------------
    ref.listen(authStateProvider, (previous, next) async {
      final prevSession = previous?.value?.session;
      final nextSession = next.value?.session;

      if (prevSession == null && nextSession != null) {
        // LOGIN: sync tasks
        ref.read(taskSyncServiceProvider).syncAll();
      } else if (prevSession != null && nextSession == null) {
        // LOGOUT: clear all local data
        await ref.read(calendarDataSourceProvider).clearAllTasks();
      }
    });

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
           // User is authenticated -> Show App
           return const MainCalendar(); 
        }
        // User is not authenticated -> Show Login/Signup Toggle
        return const AuthPage(); 
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const AuthPage(), // Fallback to login on error
    );
  }
}