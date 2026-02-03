
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskSyncService {
  final SupabaseClient _supabase;
  final CalendarLocalDataSource _localDb;

  TaskSyncService(this._supabase, this._localDb);

  Future<void> syncAllTasks() async {
    if(_supabase.auth.currentUser == null) return;
    await pushLocalChanges();
    await pullRemoteChanges();
  }

  Future<void> pushLocalChanges() async {
    debugPrint("[DEBUG] PUSHING TASK LOCAL CHANGES NOW!");
    final unsyncedTasks = await _localDb.getUnsyncedTasks();

    for(final task in unsyncedTasks){
      try{
        final taskMap = task.toCloudJsonFormat();
        taskMap["user_id"] = _supabase.auth.currentUser!.id;
        await _supabase.from('tasks').upsert(taskMap);
        await _localDb.markTasksAsSynced(task.originalId);
      }catch(e){
        debugPrint("[DEBUG]: Push failed for task ${task.id}: $e");
      }

    }
  }

  Future<void> pullRemoteChanges() async {
    debugPrint("[DEBUG] PULLING TASK REMOTE CHANGES NOW!");
    try{
      final response = await _supabase
        .from("tasks")
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);


      final List<TaskModel> models = response
        .map((e) => TaskModel.fromCloudJson(e))
        .toList();
      
      await _localDb.updateTasksFromCloud(models);
    }catch(e){
      debugPrint("[DEBUG]: PULLING OF TASK REMOTE CHANGES FAILED WITH ERROR: $e");
    }
  }
}