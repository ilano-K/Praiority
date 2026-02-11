// File: lib/features/calendar/repository/calendar_repository_impl.dart
// Purpose: Repository implementation that mediates between domain logic
// and the local data source for calendar tasks.
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';

class CalendarRepository {
  final CalendarLocalDataSource localDataSource;

  CalendarRepository(this.localDataSource);

  Future<void> saveAndUpdateTask(Task task) async {
    // final model = TaskModel.fromEntity(task);
    await localDataSource.saveAndUpdateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }

  Future<void> saveTag(String tag) async {
    print("saving");
    await localDataSource.saveTag(tag);
  }

  Future<void> deleteTag(String tag) async {
    await localDataSource.deleteTag(tag);
  }

  Future<Task?> getTaskById(String id) async {
    final model = await localDataSource.getTaskById(id);
    return model?.toEntity();
  }

  Future<List<Task>> getTasksByRange(DateTime start, DateTime end) async {
    final models = await localDataSource.getTasksByRange(start, end);
    final entities = models.map((model) => model.toEntity()).toList();

    print("[GET TASKS BY RANGE (entity)] TASKS: ${models}");

    return entities
        .where((task) => TaskUtils.validTaskModelForDate(task, start, end))
        .toList();
  }

  Future<List<Task>> getTasksByCondition({
    DateTime? start,
    DateTime? end,
    TaskCategory? category,
    TaskType? type,
    TaskStatus? status,
    String? tag,
    TaskPriority? priority,
  }) async {
    final models = await localDataSource.getTasksByCondition(
      start: start,
      end: end,
      category: category,
      type: type,
      priority: priority,
      status: status,
      tag: tag,
    );
    final tasksWithTime = models.where(
      (t) => t.startTime != null && t.endTime != null,
    );

    DateTime earliest = tasksWithTime.first.startTime!;
    DateTime latest = tasksWithTime.first.endTime!;

    for (var t in tasksWithTime) {
      if (t.startTime!.isBefore(earliest)) earliest = t.startTime!;
      if (t.endTime!.isAfter(latest)) latest = t.endTime!;
    }

    final startRange = start ?? earliest;
    final endRange = end ?? latest;

    final entities = models.map((model) => model.toEntity()).toList();
    return entities
        .where(
          (task) => TaskUtils.validTaskModelForDate(task, startRange, endRange),
        )
        .toList();
  }

  Stream<List<Task>> watchFutureTasks() {
    // 1. Listen to the data source
    return localDataSource.watchFutureTasks().map((taskModels) {
      // 2. Convert List<TaskModel> -> List<Task>
      return taskModels.map((model) => model.toEntity()).toList();
    });
  }

  Future<List<String>> getAllTagNames() async {
    final tags = await localDataSource.getAllTagNames();
    return tags.map((t) => t.name).toList();
  }
}
