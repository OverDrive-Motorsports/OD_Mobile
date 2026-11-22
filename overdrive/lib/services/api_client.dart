/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_client.dart - Shared Dio client with auth token injection and refresh support
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth/auth_refresh_interceptor.dart';
import 'auth/auth_service.dart';

class ApiClient {
    ApiClient._privateConstructor()
        : _baseUrl = _resolveBaseUrl(null),
          _dio = Dio(
            BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
            ),
          ) {
        if (_isValidUrl(_baseUrl)) {
            _dio.options.baseUrl = _baseUrl;
        }

        _dio.interceptors.add(
            AuthRefreshInterceptor(_dio),
        );
    }

    static final ApiClient instance = ApiClient._privateConstructor();

    final Dio _dio;
    final String _baseUrl;

    Dio get dio => _dio;

    static String _resolveBaseUrl(String? explicitBaseUrl) {
        return AuthService.resolveApiBaseUrlForPlatform(
            explicitBaseUrl,
            platform: defaultTargetPlatform,
        );
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
}
