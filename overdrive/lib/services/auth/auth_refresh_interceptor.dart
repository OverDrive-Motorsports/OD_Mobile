
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

class AuthRefreshInterceptor extends Interceptor {
    AuthRefreshInterceptor(this._dio);

    final Dio _dio;

    static Future<void>? _refreshFuture;

    static const String _retryKey = 'authRefreshRetried';

    @override
    void onRequest(
        RequestOptions options,
        RequestInterceptorHandler handler,
    ) async {
        try {
            final token = await AuthService.instance.accessToken;

            if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
        } catch (error) {
            handler.reject(
                DioException(
                    requestOptions: options,
                    error: error,
                    type: DioExceptionType.unknown,
                ),
            );
        }
    }

    @override
    void onError(
        DioException error,
        ErrorInterceptorHandler handler,
    ) async {
        final request = error.requestOptions;

        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshRequest = request.uri.path.endsWith('/refresh');
        final alreadyRetried = request.extra[_retryKey] == true;

        if (!isUnauthorized || isRefreshRequest || alreadyRetried) {
            handler.next(error);
            return;
        }

        try {
            final refreshFuture =
                _refreshFuture ??= AuthService.instance.refreshTokens();

            try {
                await refreshFuture;
            } finally {
                if (identical(_refreshFuture, refreshFuture)) {
                    _refreshFuture = null;
                }
            }
        } catch (refreshError) {
            debugPrint('Token refresh failed: $refreshError');

            try {
                await AuthService.instance.logout();
            } catch (logoutError) {
                debugPrint('Logout after refresh failure failed: $logoutError');
            }

            handler.next(error);
            return;
        }

        final token = await AuthService.instance.accessToken;

        if (token == null || token.isEmpty) {
            handler.next(error);
            return;
        }

        request.headers['Authorization'] = 'Bearer $token';
        request.extra[_retryKey] = true;

        try {
            final response = await _dio.fetch<dynamic>(request);
            handler.resolve(response);
        } on DioException catch (retryError) {
            handler.next(retryError);
        } catch (retryError) {
            handler.next(
                DioException(
                    requestOptions: request,
                    error: retryError,
                    type: DioExceptionType.unknown,
                ),
            );
        }
    }
}
