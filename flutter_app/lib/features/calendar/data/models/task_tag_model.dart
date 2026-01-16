import 'package:flutter_app/features/calendar/domain/entities/task_tag.dart';
import 'package:isar/isar.dart';

part 'task_tag_model.g.dart';

@Collection()
class TaskTagModel{
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String name;

  TaskTag toEntity() {
    return TaskTag(
      id: originalId,
      name: name
    );
  }

  static TaskTagModel fromEntity(TaskTag tag){
    return TaskTagModel()
      ..originalId = tag.id
      ..name = tag.name;
  }
}