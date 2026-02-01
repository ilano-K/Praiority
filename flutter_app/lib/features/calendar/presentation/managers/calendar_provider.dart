import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source_impl.dart';
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:flutter_app/features/calendar/services/task_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final calendarDataSourceProvider = Provider<CalendarLocalDataSource>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return CalendarLocalDataSourceImpl(storageService.isar);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final dataSource = ref.watch(calendarDataSourceProvider);
  return CalendarRepositoryImpl(dataSource);
});

final taskSyncServiceProvider = Provider<TaskSyncService>((ref){
  final localDb = ref.watch(calendarDataSourceProvider);
  final supabase = Supabase.instance.client;
  return TaskSyncService(supabase, localDb);
});

