import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChampionshipGatewayClient {
  ChampionshipGatewayClient({Dio? dio, String? baseUrl})
    : _dio = dio ?? _buildDio(baseUrl ?? _resolveBaseUrl());

  final Dio _dio;

  static Dio _buildDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'od_access_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );

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

    return response;
  }

  static String _resolveBaseUrl([String? explicitBaseUrl]) {
    final targetPlatform = defaultTargetPlatform;
    final fromExplicit = (explicitBaseUrl ?? '').trim();
    final explicitCandidate = _normalizeHostForPlatform(
      fromExplicit,
      platform: targetPlatform,
    );
    if (explicitCandidate.isNotEmpty && Uri.tryParse(explicitCandidate) != null) {
      return explicitCandidate;
    }

    final envUrl =
        dotenv.env['GATEWAY_BASE_URL'] ?? dotenv.env['API_BASE_URL'];
    final gatewayUrl = _normalizeHostForPlatform(
      envUrl ?? 'http://localhost:3000',
      platform: targetPlatform,
    );

    return gatewayUrl;
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
    final isAndroidLocalhost = targetPlatform == TargetPlatform.android &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');

    if (isAndroidLocalhost) {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return uri.toString();
  }
}
