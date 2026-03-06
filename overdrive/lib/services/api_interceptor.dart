/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_interceptor.dart - Dio interceptor for request/response lifecycle hooks.
 ##
 */

import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout || DioExceptionType.receiveTimeout =>
        'Connection timeout',
      DioExceptionType.connectionError => 'No internet connection',
      DioExceptionType.badResponse => 'Server error ${err.response?.statusCode}',
      _ => 'Unexpected error',
    };

    handler.next(err.copyWith(error: message));
  }
}
