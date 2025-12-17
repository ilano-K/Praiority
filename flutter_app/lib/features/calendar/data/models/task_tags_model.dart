import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/task_tags.dart';
import 'package:isar/isar.dart';

part 'task_tags_model.g.dart';

@Collection()
class TaskTagsModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String name;

  @Backlink(to: 'tags')
  final tasks = IsarLinks<TaskModel>();

  TaskTags toEntity(){
    return TaskTags(
      id: id,
      name: name
    );
  }

  static TaskTagsModel fromEntity(TaskTags tag) {
    return TaskTagsModel()
      ..name = tag.name;
  }
}