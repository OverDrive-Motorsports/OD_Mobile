/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_service.dart - Base service for backend API communication.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_interceptor.dart';
import 'api_response.dart';

class ApiService {
  late final Dio _dio;
  late final String _baseUrl;

  ApiService() {
    _baseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.addAll([
      ApiInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    final baseUri = Uri.tryParse(_baseUrl);
    if (_baseUrl.isEmpty || baseUri == null || baseUri.host.isEmpty) {
      return const ApiResponse.failure(
        'API_BASE_URL is missing or invalid in .env',
      );
    }

    try {
      final response = await _dio.get(path);
      return ApiResponse.success(
        fromJson != null ? fromJson(response.data) : response.data,
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkHealth() {
    return get<Map<String, dynamic>>(
      '/health',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        return 'Server error ${e.response?.statusCode}';
      case DioExceptionType.unknown:
        final errorText = e.error?.toString() ?? '';
        final messageText = e.message ?? '';
        final details = '$errorText $messageText'.toLowerCase();

        if (details.contains('cleartext')) {
          return 'HTTP blocked by Android cleartext policy';
        }

        if (details.contains('connection refused')) {
          return 'Cannot reach backend at ${dotenv.env['API_BASE_URL'] ?? ''}';
        }

        if (messageText.trim().isNotEmpty) {
          return messageText;
        }

        if (errorText.trim().isNotEmpty) {
          return errorText;
        }

        return 'Unexpected network error';
      default:
        return 'Unexpected error';
    }
  }
}
