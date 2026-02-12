import 'dart:io'; // For SocketException
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

class GoogleCalendarRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<List<Event>> fetchEvents() async {
    try {
      // 1. Check Login
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      if (googleUser == null) {
        throw UnauthenticatedException();
      }

      // 2. Request Permissions
      final scopes = [CalendarApi.calendarEventsReadonlyScope];
      final GoogleSignInClientAuthorization authz = await googleUser
          .authorizationClient
          .authorizeScopes(scopes);

      // 3. Create Client
      final httpClient = authz.authClient(scopes: scopes);
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
      // 4. Map External Errors to AppExceptions
      throw _handleGoogleError(e);
    }
  }

  /// Helper to convert Google/Network errors into your AppExceptions
  AppException _handleGoogleError(Object error) {
    if (error is AppException) return error;

    // Network Errors
    if (error is SocketException) return NetworkException();

    // Google Sign-In Specific Errors
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.interrupted) {
        return NetworkException();
      }
      if (error.code == GoogleSignInExceptionCode.canceled) {
        // But mapped to ValidationException for now as it's a user action
        return ValidationException("Sign-in was canceled.");
      }
    }

    // Google API Specific Errors (e.g. 403 Forbidden, 401 Invalid Token)
    if (error is DetailedApiRequestError) {
      final status = error.status; // Extract to a local variable

      if (status == 401) return UnauthenticatedException();
      if (status == 403) return UnauthorizedException();

      // Use a fallback (??) if status is null to avoid the "!" error
      if (status != null && status >= 500) {
        return ServerException(statusCode: status);
      }
    }
    return ServerException();
  }
}
