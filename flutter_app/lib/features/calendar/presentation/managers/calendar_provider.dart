import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source_impl.dart';
import 'package:flutter_app/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:flutter_app/core/services/local_database_service.dart';
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageServiceProvider = Provider<LocalDatabaseService>((ref) {
  throw UnimplementedError('OVERRIDE TO NG MAIN LATER');
});

final calendarDataSourceProvider = Provider<CalendarLocalDataSource>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return CalendarLocalDataSourceImpl(storageService.isar);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final dataSource = ref.watch(calendarDataSourceProvider);
  return CalendarRepositoryImpl(dataSource);
});

