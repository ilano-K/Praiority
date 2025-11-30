import 'package:flutter/widgets.dart';
import 'package:flutter_app/features/calendar/datasources/calendar_local_data_source_impl.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/repository/calendar_repository_impl.dart';

//main things to test
import 'core/services/local_database_service.dart'; // database service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("RUNNING TEST!!!");

  try{
    print("Initializing database");
    final storageService = LocalDatabaseService();
    await storageService.init();

    final dataSource = CalendarLocalDataSourceImpl(storageService.isar);
    final repository = CalendarRepositoryImpl(dataSource);

    final testTask = Task.create(title: "test task",
      type: TaskType.task,
      description: "This is for testing only.",
      startTime: DateTime(2025, 11, 28, 4, 0),
      endTime: DateTime(2025, 11, 30, 5, 30),
      status: TaskStatus.unscheduled,
      tags: ["Testing tag"],
      duration: const Duration(minutes: 45));
    
    // final testTask1 = Task(
    //   id: "11",
    //   title: "test task",
    //   type: TaskType.task,
    //   description: "This is for testing only.",
    //   startTime: DateTime(2025, 11, 30, 4, 0),
    //   endTime: DateTime(2025, 11, 30, 5, 30),
    //   status: TaskStatus.unscheduled,
    //   tags: ["Testing tag"],
    //   duration: const Duration(minutes: 45)
    // );

    await repository.saveAndUpdateTask(testTask);
    // await repository.saveAndUpdateTask(testTask1);
    print("task is saved");

    final tasksToday = await repository.getTasksWeek(DateTime.now());

    if (tasksToday.isNotEmpty){
      for(final task in tasksToday){
        final test = task.id;
        print(test);
      }
    }


  }catch (e, stack){
    print(e);
    print(stack);
  }
  print("end of test");
}