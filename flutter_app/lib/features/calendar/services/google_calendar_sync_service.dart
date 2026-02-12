import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/data/datasources/google_remote_data_source.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:uuid/uuid.dart';

class GoogleCalendarSyncService {
  final GoogleRemoteDataSource _remoteDataSource;
  final CalendarLocalDataSource _localDb;
  final _uuid = const Uuid();

  GoogleCalendarSyncService(this._remoteDataSource, this._localDb);

  Future<void> syncGoogleData() async {
    try {
      print("[GOOGLE SYNC SERVICE] Starting master sync (Events & Tasks).");

      // 1. Get existing IDs to prevent duplicates for both types
      final existingIds = await _localDb.getAllGoogleEventIds();
      final List<TaskModel> newModels = [];

      // --- HANDLE CALENDAR EVENTS ---
      final googleEvents = await _remoteDataSource.fetchEvents();
      for (var event in googleEvents) {
        if (existingIds.contains(event.id)) continue;
        if (event.start?.dateTime == null && event.start?.date == null) {
          continue;
        }

        final newTask = TaskModel()
          ..originalId = _uuid.v4()
          ..title = event.summary ?? "Untitled Event"
          ..description = event.description
          ..type = TaskType.event
          ..status = TaskStatus.scheduled
          ..priority = TaskPriority.none
          ..isSynced = false
          ..googleEventId = event.id
          ..tags = const []
          ..reminderMinutes = const []
          ..isAiMovable = false
          ..isConflicting = false;

        if (event.start!.date != null) {
          newTask.isAllDay = true;
          newTask.startTime = event.start!.date;
          newTask.endTime = event.end!.date;
        } else {
          newTask.isAllDay = false;
          newTask.startTime = event.start!.dateTime!.toLocal();
          newTask.endTime = event.end!.dateTime!.toLocal();
        }
        newModels.add(newTask);
      }

      // --- HANDLE GOOGLE TASKS ---
      final googleTasks = await _remoteDataSource.fetchTasks();
      for (var gTask in googleTasks) {
        if (existingIds.contains(gTask.id)) continue;

        // Google Task dates are strings (RFC 3339)
        DateTime? dueTime = gTask.due != null
            ? DateTime.parse(gTask.due!).toLocal()
            : null;

        final newTask = TaskModel()
          ..originalId = _uuid.v4()
          ..title = gTask.title ?? "Untitled Task"
          ..description = gTask.notes
          ..type = TaskType
              .task // Identify as task
          ..status = gTask.status == 'completed'
              ? TaskStatus.completed
              : TaskStatus.scheduled
          ..priority = TaskPriority
              .none // Default priority for tasks
          ..isSynced = false
          ..googleEventId = gTask.id
          ..tags = const []
          ..reminderMinutes = const []
          ..isAiMovable = false
          ..isConflicting = false;

        // Since Google Tasks don't have duration, we set a default 30-min block
        if (dueTime != null) {
          newTask.isAllDay = false; // Usually has a specific due time
          newTask.startTime = dueTime;
          newTask.endTime = dueTime.add(const Duration(minutes: 30));
        } else {
          // Fallback for tasks without due dates so 'late' fields don't crash
          newTask.isAllDay = true;
          newTask.startTime = DateTime.now();
          newTask.endTime = DateTime.now().add(const Duration(hours: 1));
        }
        newModels.add(newTask);
      }

      // 2. Save everything in one batch
      if (newModels.isNotEmpty) {
        print(
          "[GOOGLE SYNC SERVICE] Saving ${newModels.length} new items to Isar.",
        );
        await _localDb.saveTasksFromGoogle(newModels);
      }
    } catch (e) {
      print("[GOOGLE SYNC SERVICE] Error during sync: $e");
      rethrow;
    }
  }
}
