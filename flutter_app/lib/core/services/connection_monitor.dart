// File: lib/core/services/connection_monitor.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. The Provider
final connectionMonitorProvider = Provider<ConnectionMonitor>((ref) {
  return ConnectionMonitor(ref);
});

class ConnectionMonitor {
  final Ref _ref;
  StreamSubscription? _subscription;

  ConnectionMonitor(this._ref);

  void initialize() {
    // Cancel existing to be safe
    _subscription?.cancel();

    // Listen to stream
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus now returns a List<ConnectivityResult>
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) &&
              Supabase.instance.client.auth.currentSession != null) {
        print("[ConnectionMonitor] Internet Detected! Triggering Sync...");
        _triggerSync();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _triggerSync() async {
    // Optional: Add a small delay to let the connection stabilize
    await Future.delayed(const Duration(seconds: 2));

    try {
      final taskSyncService = _ref.read(taskSyncServiceProvider);
      final userPrefSyncService = _ref.read(userPrefSyncServiceProvider);
      // 1. Push local changes (Create/Update/Delete)
      await taskSyncService.syncAllTasks();
      await userPrefSyncService.syncPreferences();

      print("[DEBUG] ConnectionMonitor Sync Complete.");
    } catch (e) {
      print("[DEBUG] ConnectionMonitor Sync Failed: $e");
    }
  }
}
