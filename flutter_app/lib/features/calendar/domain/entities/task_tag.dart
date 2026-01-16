
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TaskTag extends Equatable{
  final String id;
  final String name;

  const TaskTag({
    required this.id,
    required this.name
  });

  factory TaskTag.create({required String name}) {
    return TaskTag(
    id: const Uuid().v4(),
    name: name
    );
  }

  TaskTag copyWith({
    String? id,
    String? name
  }){
    return TaskTag(
    id: id ?? this.id,
    name: name ?? this.name
    );
  }

  @override
  List<Object?> get props => [
    id,
    name
  ];
}