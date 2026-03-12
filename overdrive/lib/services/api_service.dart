/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_service.dart - Base service for backend API communication.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_interceptor.dart';
import 'api_response.dart';

class ApiService {
  ApiService({Dio? dio, String? baseUrl})
      : _baseUrl = _resolveBaseUrl(baseUrl),
        _dio =
            dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
              ),
            ) {
    if (_hasValidBaseUrl) {
      _dio.options.baseUrl = _baseUrl;
    }

    _dio.interceptors.addAll([
      ApiInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }
  final Dio _dio;
  final String _baseUrl;

  static String _resolveBaseUrl(String? explicitBaseUrl) {
    final fromArg = (explicitBaseUrl ?? '').trim();
    if (_isValidUrl(fromArg)) {
      return fromArg;
    }

    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (_isValidUrl(fromEnv)) {
      return fromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator must use 10.0.2.2 to reach host localhost.
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static bool _isValidUrl(String value) {
    if (value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  bool get _hasValidBaseUrl {
    return _isValidUrl(_baseUrl);
  }

  String get _baseUrlError =>
      'API base URL is invalid: $_baseUrl '
      '(expected e.g. http://10.0.2.2:8080)';

  String _resolveDioError(DioException exception) {
    final looksLikeAndroidEmulatorHost = _baseUrl.contains('10.0.2.2');
    final isNetworkTimeout =
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError;

    if (looksLikeAndroidEmulatorHost && isNetworkTimeout) {
      return 'Timeout on 10.0.2.2. On a real phone, set API_BASE_URL to your computer LAN IP (example: http://192.168.1.42:8080).';
    }

    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['error'] ?? data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    final message = exception.error;
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    return exception.message ?? 'Unexpected error';
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    if (!_hasValidBaseUrl) {
      return ApiResponse.failure(_baseUrlError);
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
        ),
      );
      final payload = response.data;
      final parsed = fromJson != null ? fromJson(payload) : payload as T;

      return ApiResponse.success(
        parsed,
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_resolveDioError(e));
    } catch (_) {
      return const ApiResponse.failure('Invalid server response');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkHealth() {
    return get<Map<String, dynamic>>(
      '/health',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
  }
}
