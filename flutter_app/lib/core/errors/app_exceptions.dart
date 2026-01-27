class AppException implements Exception {
  final String message;
  final String title;

  AppException(this.message, this.title);

  @override  
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException() : super("Please check your internet connection.", "No Internet");
}

class AuthExceptionWrapper extends AppException {
  AuthExceptionWrapper(String msg) : super(msg, "Authentication Failed");
}

class ServerException extends AppException {
  ServerException() : super("Our servers are having trouble. Please try again.", "Server Error");
} 