import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/data/datasources/google_remote_data_source.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';

class GoogleCalendarSyncService {
  final GoogleCalendarRemoteDataSource _remoteDataSource;
  final CalendarLocalDataSource _localDb;

  GoogleCalendarSyncService(this._remoteDataSource, this._localDb);

  Future<void> syncGoogleEvents() async {
    try {
      print("[GOOGLE SYNC SERVICE] Starting sync.");

      // fetch the events, handles the authentication as well
      final googleEvents = await _remoteDataSource.fetchEvents();
      if (googleEvents.isEmpty) return;

      // check for duplicates
      final existingIds = await _localDb.getAllGoogleEventIds();
      final List<TaskModel> newTasks = [];

      for (var event in googleEvents) {
        if (existingIds.contains(event.id)) continue;
        if (event.start?.dateTime == null && event.start?.date == null) {
          continue;
        }

        //map events to task model
        final newTask = TaskModel()
          ..title = event.summary ?? "Untitled Event"
          ..description = event.description
          ..type = TaskType.event
          ..status = TaskStatus.scheduled
          ..priority = TaskPriority.none
          ..isSynced = false
          ..googleEventId = event.id
          ..isAiMovable = false
          ..isConflicting = false
          ..recurrenceRule;

        // handle date time
        if (event.start!.date != null) {
          newTask.isAllDay = true;
          newTask.startTime = event.start!.date;
          newTask.endTime = event.end!.date;
        } else {
          newTask.isAllDay = false;
          newTask.startTime = event.start!.dateTime!.toLocal();
          newTask.endTime = event.end!.dateTime!.toLocal();
        }
        // add to the list
        newTasks.add(newTask);
      }
      // save to local db
      if (newTasks.isNotEmpty) {
        await _localDb.saveTasksFromGoogle(newTasks);
      }
    } catch (e) {
      rethrow;
    }
  }
}
