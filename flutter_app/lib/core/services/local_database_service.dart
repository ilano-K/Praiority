import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/calendar/data/models/task_model.dart';

class LocalDatabaseService {
  late Isar isar;

  Future<void> init() async {
    // app directory
    final appDir = await getApplicationDocumentsDirectory();

    // open local database (isar)
    isar = await Isar.open(
      [TaskModelSchema],
      directory: appDir.path,
      inspector: true, // debug
      );
  }
}