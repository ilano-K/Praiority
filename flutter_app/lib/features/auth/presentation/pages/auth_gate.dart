import 'dart:async'; // Needed for unawaited
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS (Adjust paths if necessary)
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_notfier.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_app/features/settings/presentation/pages/work_hours.dart';

// Tracks if we are currently running the initial setup sync
final _isPerformingLoginSyncProvider = StateProvider<bool>((ref) => false);

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
    // 1. COLD START SYNC (Optimistic)
    // -------------------------------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Run quietly in background
        ref.read(taskSyncServiceProvider).syncAllTasks();
        ref.read(userPrefSyncServiceProvider).syncPreferences(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 2. LISTENER (Handles Active Login/Logout Side Effects)
    // -------------------------------------------------------------------------
    ref.listen(authStateProvider, (previous, next) async {
      final prevSession = previous?.value?.session;
      final nextSession = next.value?.session;

      // ✅ CASE: LOGOUT DETECTED
      if (prevSession != null && nextSession == null) {
        // Ensure Spinner is off
        ref.read(_isPerformingLoginSyncProvider.notifier).state = false;
        
        // Clear Data (Fire and Forget - do NOT await)
        unawaited(ref.read(calendarDataSourceProvider).clearAllTasks());
      }
      
      // ✅ CASE: LOGIN DETECTED
      else if (prevSession == null && nextSession != null) {
        ref.read(_isPerformingLoginSyncProvider.notifier).state = true;

        try {
          await ref.read(taskSyncServiceProvider).syncAllTasks();
          await ref.read(userPrefSyncServiceProvider).pullRemoteChanges();
          
          final userPrefsController = ref.read(settingsControllerProvider.notifier);
          final userPrefs = await userPrefsController.loadUserSettings();
          
          ref.read(_isPerformingLoginSyncProvider.notifier).state = false;

          if (userPrefs == null || userPrefs.startWorkHours == null) {
             if (context.mounted) {
               Navigator.of(context).push(
                 MaterialPageRoute(builder: (_) => const WorkHours())
               );
             }
          }
        } catch (e) {
           ref.read(_isPerformingLoginSyncProvider.notifier).state = false;
        }
      }
    });

    // -------------------------------------------------------------------------
    // 3. THE "NUCLEAR" FIX: BYPASS CACHE
    // -------------------------------------------------------------------------
    // We check the Supabase client DIRECTLY. If this is null, we are logged out.
    // This ignores any lag in the Riverpod provider.
    final currentSession = Supabase.instance.client.auth.currentSession;
    
    if (currentSession == null) {
      return const AuthPage(); // Force Login Page immediately
    }

    // -------------------------------------------------------------------------
    // 4. NORMAL UI STATE
    // -------------------------------------------------------------------------
    final isSyncing = ref.watch(_isPerformingLoginSyncProvider);
    
    // If we are here, currentSession is NOT null.
    // If we are actively syncing (just logged in), show spinner.
    if (isSyncing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Otherwise, show the app.
    return const MainCalendar();
  }
}