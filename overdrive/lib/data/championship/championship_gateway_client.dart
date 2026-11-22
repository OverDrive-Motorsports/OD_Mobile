import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../services/auth/auth_refresh_interceptor.dart';

class ChampionshipGatewayClient {
  ChampionshipGatewayClient({Dio? dio, String? baseUrl})
    : _dio = dio ?? _buildDio(baseUrl ?? _resolveBaseUrl()) {
    if (dio != null) {
      _dio.interceptors.add(AuthRefreshInterceptor(_dio));
    }
  }

  final Dio _dio;

  static Dio _buildDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    dio.interceptors.add(AuthRefreshInterceptor(dio));

    return dio;
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final path = '/v1/championship$endpoint';
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path, method: 'GET'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    debugPrint('Championship API response: ${response.data}');
    return response;
  }

  static String _resolveBaseUrl([String? explicitBaseUrl]) {
    final targetPlatform = defaultTargetPlatform;

    final fromExplicit = (explicitBaseUrl ?? '').trim();
    final explicitCandidate = _normalizeHostForPlatform(
      fromExplicit,
      platform: targetPlatform,
    );

    if (_isValidUrl(explicitCandidate)) {
      return explicitCandidate;
    }

    var envUrl = '';

    if (dotenv.isInitialized) {
      envUrl =
          (dotenv.env['GATEWAY_BASE_URL'] ?? dotenv.env['API_BASE_URL'] ?? '')
              .trim();
    }

    final gatewayCandidate = _normalizeHostForPlatform(
      envUrl,
      platform: targetPlatform,
    );

    if (_isValidUrl(gatewayCandidate)) {
      return gatewayCandidate;
    }

    return targetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  static bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String _normalizeHostForPlatform(
    String value, {
    TargetPlatform? platform,
  }) {
    if (value.trim().isEmpty) {
      return value;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      return value;
    }

    final targetPlatform = platform ?? defaultTargetPlatform;
    final isAndroidLocalhost =
        targetPlatform == TargetPlatform.android &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');

    if (isAndroidLocalhost) {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return uri.toString();
  }
}
