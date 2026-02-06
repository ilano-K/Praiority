import 'dart:async';

enum AppErrorType {
  network,
  unauthenticated,
  unauthorized,
  invalidCredentials,
  server,
  validation,
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
  // Already an AppException → just return it
  if (error is AppException) return error;

  // Timeout / network issues
  if (error is TimeoutException) return NetworkException();
  // Fallback to generic server error
  return ServerException();
}
