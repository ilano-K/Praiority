// File: lib/features/auth/presentation/pages/auth_gate.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_notfier.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_app/features/settings/presentation/pages/work_hours.dart';

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
  // Prevent duplicate syncs
  bool _isSyncing = false;
  String? _lastSyncedUserId;

  @override
  void initState() {
    super.initState();

    // ✅ SUCCESS LOGOUT MESSAGE
    if (widget.showLogoutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final colorScheme = Theme.of(context).colorScheme;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully logged out",
              textAlign: TextAlign.left,
              style: TextStyle(color: colorScheme.surface),
            ),
            behavior: SnackBarBehavior.fixed,
            backgroundColor: colorScheme.onSurface,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }

    // Existing sync logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _lastSyncedUserId = user.id;
        ref.read(taskSyncServiceProvider).syncAllTasks();
        ref.read(userPrefSyncServiceProvider).syncPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 1. LISTENER (Side Effects)
    // -------------------------------------------------------------------------
    ref.listen(authStateProvider, (previous, next) async {
      final prevSession = previous?.valueOrNull?.session;
      final nextSession = next.valueOrNull?.session;
      final currentUserId = nextSession?.user.id;

      // ✅ CASE: LOGOUT
      if (prevSession != null && nextSession == null) {
        // Double check: If we have a local session, ignore this "logout" event
        // (it might be a network glitch)
        if (Supabase.instance.client.auth.currentSession != null) return;

        ref.read(_isLoadingUIProvider.notifier).state = false;
        _isSyncing = false;
        _lastSyncedUserId = null;
        unawaited(ref.read(calendarDataSourceProvider).clearAllTasks());
      }
      // ✅ CASE: LOGIN
      else if (prevSession == null && nextSession != null) {
        if (currentUserId == _lastSyncedUserId) return;
        if (_isSyncing) return;

        _isSyncing = true;
        _lastSyncedUserId = currentUserId;

        // Turn on Spinner
        ref.read(_isLoadingUIProvider.notifier).state = true;

        try {
          // clear database first
          await ref.read(localStorageServiceProvider).clearDatabase();

          // Timeout Protection (3 seconds)
          await ref
              .read(taskSyncServiceProvider)
              .syncAllTasks()
              .timeout(const Duration(seconds: 3));

          await ref
              .read(userPrefSyncServiceProvider)
              .pullRemoteChanges()
              .timeout(const Duration(seconds: 3));

          final userPrefsController = ref.read(
            settingsControllerProvider.notifier,
          );
          final userPrefs = await userPrefsController.loadUserSettings();

          // Check Work Hours
          if (userPrefs == null || userPrefs.startWorkHours == null) {
            if (context.mounted) {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WorkHours()));
            }
          }
        } catch (e) {
          print("[AuthGate] Sync Error or Timeout: $e");
        } finally {
          // ALWAYS Unlock UI
          if (mounted) {
            ref.read(_isLoadingUIProvider.notifier).state = false;
          }
          _isSyncing = false;
        }
      }
    });

    // -------------------------------------------------------------------------
    // 2. HELPER: CONTENT BUILDER
    // -------------------------------------------------------------------------
    Widget buildAuthenticatedContent() {
      final userPrefs = ref.watch(settingsControllerProvider).valueOrNull;

      // If offline, prefs might be null.
      // If we are truly new, we need WorkHours.
      // If we are just offline, ideally we show Calendar, but safety first:
      if (userPrefs == null || userPrefs.startWorkHours == null) {
        return const WorkHours();
      }

      return const MainCalendar();
    }

    // -------------------------------------------------------------------------
    // 3. BUILDER (The UI)
    // -------------------------------------------------------------------------
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(_isLoadingUIProvider);

    // ✅ PRIORITY 1: LOADING SPINNER
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ PRIORITY 2: AUTH STATE (Offline-Capable)
    return authState.when(
      data: (state) {
        // Standard check
        if (state.session != null) return buildAuthenticatedContent();

        // Fallback: Check local storage (Fixes flicker)
        if (Supabase.instance.client.auth.currentSession != null) {
          return buildAuthenticatedContent();
        }

        return const AuthPage();
      },
      loading: () {
        // OFFLINE FIX: If loading, but we have a session on disk, show App immediately
        if (Supabase.instance.client.auth.currentSession != null) {
          return buildAuthenticatedContent();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (err, stack) {
        // OFFLINE FIX: If network error, but we have session on disk, IGNORE error
        if (Supabase.instance.client.auth.currentSession != null) {
          return buildAuthenticatedContent();
        }
        return const AuthPage();
      },
    );
  }
}
