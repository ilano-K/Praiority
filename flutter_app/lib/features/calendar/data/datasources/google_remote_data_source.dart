import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_app/core/consants/auth_constants.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/tasks/v1.dart' as tasks_api; // Added Tasks API

class GoogleRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Combined Scopes
  static const _scopes = [
    CalendarApi.calendarEventsReadonlyScope,
    tasks_api.TasksApi.tasksReadonlyScope,
  ];

  /// --- FETCH GOOGLE CALENDAR EVENTS ---
  Future<List<Event>> fetchEvents() async {
    try {
      await _googleSignIn.initialize(serverClientId: AuthConstants.webClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();
      if (googleUser == null) throw UnauthenticatedException();

      final GoogleSignInClientAuthorization authz = await googleUser
          .authorizationClient
          .authorizeScopes(_scopes);
      final httpClient = authz.authClient(scopes: _scopes);
      final calendarApi = CalendarApi(httpClient);

      final now = DateTime.now();

      try {
        final events = await calendarApi.events.list(
          'primary',
          timeMin: now.subtract(const Duration(days: 30)).toUtc(),
          timeMax: now.add(const Duration(days: 90)).toUtc(),
          singleEvents: true,
          orderBy: 'startTime',
        );
        return events.items ?? [];
      } finally {
        httpClient.close();
      }
    } catch (e) {
      print("[GOOGLE REMOTE DATA SOURCE] CALENDAR ERROR: $e");
      throw _handleGoogleError(e);
    }
  }

  /// --- FETCH GOOGLE TASKS ---
  Future<List<tasks_api.Task>> fetchTasks() async {
    try {
      // Re-initialize for safety
      await _googleSignIn.initialize(serverClientId: AuthConstants.webClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();
      if (googleUser == null) throw UnauthenticatedException();

      final GoogleSignInClientAuthorization authz = await googleUser
          .authorizationClient
          .authorizeScopes(_scopes);
      final httpClient = authz.authClient(scopes: _scopes);
      final tasksApi = tasks_api.TasksApi(httpClient);

      try {
        // 1. Google Tasks requires getting the "Task Lists" first
        final taskLists = await tasksApi.tasklists.list();
        final List<tasks_api.Task> allTasks = [];

        if (taskLists.items != null) {
          // 2. Loop through each list (e.g., Default, Personal, Work)
          for (var list in taskLists.items!) {
            final tasks = await tasksApi.tasks.list(list.id!);
            if (tasks.items != null) {
              allTasks.addAll(tasks.items!);
            }
          }
        }
        return allTasks;
      } finally {
        httpClient.close();
      }
    } catch (e) {
      print("[GOOGLE REMOTE DATA SOURCE] TASKS ERROR: $e");
      throw _handleGoogleError(e);
    }
  }

  /// Helper to convert Google/Network errors into your AppExceptions
  AppException _handleGoogleError(Object error) {
    if (error is AppException) return error;

    if (error is SocketException) return NetworkException();

    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.interrupted) {
        return NetworkException();
      }
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return ValidationException("Sign-in was canceled.");
      }
    }

    if (error is DetailedApiRequestError) {
      final status = error.status;
      if (status == 401) return UnauthenticatedException();
      if (status == 403) return UnauthorizedException();
      if (status != null && status >= 500) {
        return ServerException(statusCode: status);
      }
    }
    return ServerException();
  }
}
