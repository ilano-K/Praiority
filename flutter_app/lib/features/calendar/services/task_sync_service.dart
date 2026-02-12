import 'dart:async';
import 'dart:io'; // For SocketException
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/data/models/task_model_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:retry/retry.dart'; // Import this

class TaskSyncService {
  final SupabaseClient _supabase;
  final CalendarLocalDataSource _localDb;

  TaskSyncService(this._supabase, this._localDb);

  // Define retry options: max 3 attempts, random delay to prevent collisions
  final _r = const RetryOptions(maxAttempts: 3);
  bool _isSyncing = false;

  Future<void> syncAllTasks() async {
    if (_isSyncing) {
      _isSyncing = false;
      return;
    }
    if (_supabase.auth.currentUser == null) {
      _isSyncing = false;
      return;
    }
    // Run these in sequence or parallel depending on your conflict logic.
    // Usually, pushing first ensures your latest edits are saved.
    try {
      await pushLocalChanges();
      await pullRemoteChanges();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> pushLocalChanges() async {
    debugPrint("[DEBUG] PUSHING TASK LOCAL CHANGES NOW! ${_isSyncing}");
    if (_isSyncing) {
      _isSyncing = false;
      return;
    }
    _isSyncing = true;

    final unsyncedTasks = await _localDb.getUnsyncedTasks();

    if (unsyncedTasks.isEmpty) {
      _isSyncing = false;
      return;
    }

    // 1. Prepare the BATCH (Much faster than looping)
    final List<Map<String, dynamic>> batchData = unsyncedTasks.map((task) {
      final taskMap = task.toCloudJson();

      taskMap["user_id"] = _supabase.auth.currentUser!.id;
      return taskMap;
    }).toList();

    try {
      // 2. Retry Logic using 'retry' package
      // This handles transient errors (SocketException, Timeout) automatically

      await _r.retry(
        () async {
          // Supabase supports inserting a List<Map> for bulk upsert
          await _supabase.from('tasks').upsert(batchData);
        },
        // Only retry on network-related errors.
        // Don't retry if your data is invalid (e.g. missing fields).
        retryIf: (e) =>
            e is SocketException ||
            e is TimeoutException ||
            e is PostgrestException,
      );

      // 3. Mark all as synced only if the batch succeeded
      // Note: You might need to update your local DB to accept a list of IDs for speed
      for (var task in unsyncedTasks) {
        await _localDb.markTasksAsSynced(task.originalId);
      }

      debugPrint("[DEBUG] Successfully synced ${batchData.length} tasks.");
    } catch (e) {
      _isSyncing = false;
      debugPrint("[DEBUG]: Push BATCH failed after retries: $e");
    } finally {
      _isSyncing = false;
      print("[DEBUG] Syncing set to false ${_isSyncing}");
    }
  }

  Future<void> pullRemoteChanges() async {
    debugPrint(
      "[pullRemoteChanges] PULLING TASK LOCAL CHANGES NOW! ${_isSyncing}",
    );
    if (_isSyncing) {
      _isSyncing = false;
      return;
    }
    ;
    _isSyncing = true;
    try {
      // Retry the pull as well
      final response = await _r.retry(
        () async => await _supabase
            .from("tasks")
            .select()
            .eq('user_id', _supabase.auth.currentUser!.id),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      // Map data
      final List<TaskModel> models = (response as List)
          .map((e) => TaskModelFactory.fromCloudJson(e as Map<String, dynamic>))
          .toList();

      debugPrint("[pullRemoteChanges]: SUCCESFULLY PULLED : ${models.length}");
      await _localDb.updateTasksFromCloud(models);
    } catch (e) {
      debugPrint("[pullRemoteChanges]: PULLING REMOTE CHANGES FAILED: $e");
      _isSyncing = false;
    } finally {
      _isSyncing = false;
    }
  }
}
