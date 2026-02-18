import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppErrorType {
  network,
  unauthenticated,
  unauthorized,
  invalidCredentials,
  server,
  validation,
  taskConflict,
  unknown,
}

abstract class AppException implements Exception {
  final String message;
  final String title;
  final AppErrorType type;
  final int? statusCode;

  AppException({
    required this.message,
    required this.title,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AppException(type: $type, statusCode: $statusCode, title: $title, message: $message)';
  }
}

// --- AUTH & API EXCEPTIONS ---

class UnauthenticatedException extends AppException {
  UnauthenticatedException()
    : super(
        title: "Session Expired",
        message: "Please log in again to continue.",
        type: AppErrorType.unauthenticated,
        statusCode: 401,
      );
}

class UnauthorizedException extends AppException {
  UnauthorizedException()
    : super(
        title: "Access Denied",
        message: "You don’t have permission to perform this action.",
        type: AppErrorType.unauthorized,
        statusCode: 403,
      );
}

class InvalidCredentialsException extends AppException {
  InvalidCredentialsException()
    : super(
        title: "Login Failed",
        message: "Incorrect email or password.",
        type: AppErrorType.invalidCredentials,
        statusCode: 401,
      );
}

class NetworkException extends AppException {
  NetworkException()
    : super(
        title: "No Internet",
        message: "Please check your internet connection.",
        type: AppErrorType.network,
      );
}

class ServerException extends AppException {
  ServerException({int? statusCode})
    : super(
        title: "Server Error",
        message: "Something went wrong on our end. Please try again.",
        type: AppErrorType.server,
        statusCode: statusCode,
      );
}

class ValidationException extends AppException {
  ValidationException(String message)
    : super(
        title: "Invalid Input",
        message: message,
        type: AppErrorType.validation,
        statusCode: 400,
      );
}

// --- SCHEDULING & TASK CONFLICT EXCEPTIONS ---

class EndBeforeStartException extends AppException {
  EndBeforeStartException([String? customMessage])
    : super(
        title: "Invalid Time Range",
        message:
            customMessage ??
            "The end time cannot be set before the start time.",
        type: AppErrorType.taskConflict,
      );
}

class DeadlineConflictException extends AppException {
  DeadlineConflictException([String? customMessage])
    : super(
        title: "Deadline Exceeded",
        message:
            customMessage ??
            "The scheduled time goes beyond the task deadline.",
        type: AppErrorType.taskConflict,
      );
}

class TimeConflictException extends AppException {
  TimeConflictException([String? customMessage])
    : super(
        title: "Schedule Conflict",
        message:
            customMessage ?? "This time slot overlaps with an existing task.",
        type: AppErrorType.taskConflict,
      );
}

// --- API EXCEPTION FACTORY ---
class ApiExceptionFactory {
  static AppException fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 401:
        return UnauthenticatedException();
      case 403:
        return UnauthorizedException();
      case 400:
        return ValidationException(message ?? "Invalid input.");
      case 500:
      default:
        return ServerException(statusCode: statusCode);
    }
  }
}

// --- GLOBAL PARSE ERROR FUNCTION ---
// Converts any thrown error into an AppException
AppException parseError(Object error) {
  // 1. If it is already our custom exception, pass it through
  if (error is AppException) return error;

  // 2. Handle Supabase Auth Errors
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
      case 'bad_oauth_callback':
        return InvalidCredentialsException();
      case 'user_already_exists':
      case 'signup_disabled':
        return ValidationException("This email is already in use.");
      case 'weak_password':
        return ValidationException("Password is too weak.");
      case 'otp_expired':
        return ValidationException("The code has expired.");
      case 'email_not_confirmed':
        return ValidationException("Please confirm your email address.");
      case 'same_password':
        return ValidationException("New password should be different from the old password.");
    }

    // Fallback message check
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid email')) {
      return InvalidCredentialsException();
    }

    return ServerException(statusCode: int.tryParse(error.statusCode ?? '500'));
  }

  // 3. Handle Google Sign-In Errors
  if (error is GoogleSignInException) {
    if (error.code == 'sign_in_canceled' ||
        error.code == 'canceled' ||
        error.toString().contains('canceled')) {
      return ValidationException("Sign in canceled.");
    }

    // Check for network issues specific to Google (common on Android)
    if (error.code == 'network_error') {
      return NetworkException();
    }

    return ServerException();
  }

  // 4. Handle Network Errors
  if (error is SocketException || error is TimeoutException) {
    return NetworkException();
  }

  // 5. Handle String errors (manually thrown)
  if (error is String) {
    return ValidationException(error);
  }

  // 6. Default catch-all
  print("Unknown Error Caught: $error"); // Helpful for debugging
  return ServerException();
}
