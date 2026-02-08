import 'package:dio/dio.dart';
import 'package:flutter_app/core/consants/api_constants.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class ApiClient {
  final Dio _dio; //HTTP CLIENT
  
  ApiClient()
    : _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type' : 'application/json',
        'Accept': 'application/json',
      },
    ));
  
  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    try{
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null){
        throw UnauthenticatedException();
      }

      // access token
      final token = session.accessToken;  

      // bearer
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final response = await _dio.post(
        endpoint,
        data: data,
        options: options,
      );

      return response;
    } on DioException catch (dioError) {
      // dio errors'
      developer.log(
        'DioException: ${dioError.response?.data ?? dioError.message}',
        name: 'ApiClient',
        error: dioError,
      );
      if (dioError.response != null) {
        // Convert HTTP status code to AppException
        final statusCode = dioError.response!.statusCode ?? 500;
        final message = dioError.response!.data.toString();

        throw ApiExceptionFactory.fromStatusCode(
          statusCode,
          message: message,
        );
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
                dioError.type == DioExceptionType.sendTimeout ||
                dioError.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      } else {
        throw ServerException();
      }
    } catch (error) {
      throw ServerException();
    }
  }
}