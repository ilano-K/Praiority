// lib/core/utils/error_utils.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AppException parseError(Object error) {
  // 1. Network (Internet)
  if (error is SocketException || error is TimeoutException) {
    return NetworkException();
  }

  // 2. Auth
  if (error is AuthException) {
    return AuthExceptionWrapper(error.message);
  }

  // 3. Server (Cloud/Database)
  if (error is PostgrestException) {
    return ServerException();
  }

  // 4. Fallback
  return AppException("An unexpected error occurred", "Error");
}