import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/data/datasources/google_remote_data_source.dart';
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository.dart';
import 'package:flutter_app/features/calendar/presentation/managers/google_sync_notifier.dart';
import 'package:flutter_app/features/calendar/services/google_calendar_sync_service.dart';
import 'package:flutter_app/features/calendar/services/task_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final calendarDataSourceProvider = Provider<CalendarLocalDataSource>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return CalendarLocalDataSource(storageService.isar);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final dataSource = ref.watch(calendarDataSourceProvider);
  return CalendarRepository(dataSource);
});

final taskSyncServiceProvider = Provider<TaskSyncService>((ref) {
  final localDb = ref.watch(calendarDataSourceProvider);
  final supabase = Supabase.instance.client;
  return TaskSyncService(supabase, localDb);
});

final googleCalendarRemoteDataSourceProvider = Provider<GoogleRemoteDataSource>(
  (ref) {
    return GoogleRemoteDataSource();
  },
);

final googleCalendarSyncServiceProvider = Provider<GoogleCalendarSyncService>((
  ref,
) {
  final remoteDataSource = ref.watch(googleCalendarRemoteDataSourceProvider);
  final localDb = ref.watch(calendarDataSourceProvider);

  return GoogleCalendarSyncService(remoteDataSource, localDb);
});

// 3. The Controller (Notifier) to manage Loading/Error states
// We use AutoDispose so it resets when the user leaves the settings page
final googleSyncNotifierProvider =
    AsyncNotifierProvider<GoogleSyncNotifier, void>(() {
      return GoogleSyncNotifier();
    });
