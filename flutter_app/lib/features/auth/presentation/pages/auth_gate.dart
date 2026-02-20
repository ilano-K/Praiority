// File: lib/features/auth/presentation/pages/auth_gate.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/pages/new_pass_page.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/managers/user_preferences_provider.dart';
import 'package:flutter_app/features/settings/presentation/pages/work_hours.dart';
import 'package:flutter_app/core/theme/theme_notifier.dart';
import 'package:flutter_app/core/theme/themes.dart';

// Lock for UI Loading State
final _isLoadingUIProvider = StateProvider<bool>((ref) => false);

class AuthGate extends ConsumerStatefulWidget {
  // Flag to show logout success message
  final bool showLogoutMessage;

  const AuthGate({
    super.key,
    this.showLogoutMessage = false, // Default to false
  });

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  // We keep these to prevent the "Double Sync" on app startup
  bool _isSyncing = false;
  String? _lastSyncedUserId;

  @override
  void initState() {
    super.initState();
    // ✅ Keep ONLY the snackbar here.
    // The Sync logic is now handled exclusively by the ref.listen below.
    if (widget.showLogoutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Successfully logged out")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 1. LISTENER (Centralized Sync & Navigation Logic)
    // -------------------------------------------------------------------------
    ref.listen(authStateProvider, (previous, next) async {
      final data = next.valueOrNull;
      final event = data?.event;
      final session = data?.session;

      // Handle Password Recovery
      if (event == AuthChangeEvent.passwordRecovery) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPassPage()));
        return;
      }

      // Handle Logout
      if (previous?.valueOrNull?.session != null && session == null) {
        if (Supabase.instance.client.auth.currentSession != null) return;
        _isSyncing = false;
        _lastSyncedUserId = null;
        ref.read(_isLoadingUIProvider.notifier).state = false;
        return;
      }

      // Handle Login / Initial Session
      if (session != null &&
          !_isSyncing &&
          session.user.id != _lastSyncedUserId) {
        _isSyncing = true;
        _lastSyncedUserId = session.user.id;
        ref.read(_isLoadingUIProvider.notifier).state = true;

        try {
          await ref
              .read(taskSyncServiceProvider)
              .syncAllTasks()
              .timeout(const Duration(seconds: 3));

          ref.invalidate(calendarControllerProvider);
          await ref
              .read(userPrefSyncServiceProvider)
              .pullRemoteChanges()
              .timeout(const Duration(seconds: 3));

          // After pulling remote prefs into local storage, apply the
          // stored theme immediately so the UI updates on login.
          try {
            final repo = ref.read(userPreferencesRepositoryProvider);
            final prefs = await repo.getPreferences();
            if (prefs != null) {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(prefs.isDarkMode ? darkMode : lightMode);
            }
          } catch (_) {
            // ignore errors here; provider listener will still pick up prefs
          }

          // Refresh the UI provider after pulling from cloud
          ref.invalidate(userPreferencesControllerProvider);
        } catch (e) {
          debugPrint("Sync Error: $e");
        } finally {
          if (mounted) ref.read(_isLoadingUIProvider.notifier).state = false;
          _isSyncing = false;
        }
      }
    });

    // -------------------------------------------------------------------------
    // 2. STATE WATCHING
    // -------------------------------------------------------------------------
    final authState = ref.watch(authStateProvider);
    final isSyncing = ref.watch(_isLoadingUIProvider);
    final userPrefsAsync = ref.watch(userPreferencesControllerProvider);

    // ✅ PRIORITY 1: GLOBAL LOADING (Consolidated)
    // If we are syncing or auth is loading, show spinner.
    if (isSyncing || authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ PRIORITY 2: AUTH GATING
    return authState.when(
      data: (state) {
        final session =
            state.session ?? Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // ✅ PRIORITY 3: PREFERENCES GATING
          return userPrefsAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            data: (prefs) {
              if (prefs == null || prefs.startWorkHours == null) {
                return const WorkHours();
              }
              return const MainCalendar();
            },
          );
        }
        return const AuthPage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const AuthPage(),
    );
  }
}
