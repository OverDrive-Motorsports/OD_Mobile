/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_client.dart - Shared Dio client with auth token injection and refresh support.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_service.dart';

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

		_dio.interceptors.add(InterceptorsWrapper(
			onRequest: (options, handler) async {
				if (options.path.endsWith('/auth/refresh')) {
					return handler.next(options);
				}

				final token = await AuthService.instance.accessToken;
				if (token != null && token.isNotEmpty) {
					options.headers['Authorization'] = 'Bearer $token';
				}

				return handler.next(options);
			},
			onError: (error, handler) async {
				final response = error.response;
				final requestOptions = error.requestOptions;

				final shouldRetry = response?.statusCode == 401 &&
						requestOptions.extra['refresh_attempted'] != true &&
						!requestOptions.path.endsWith('/auth/login') &&
						!requestOptions.path.endsWith('/auth/signup') &&
						!requestOptions.path.endsWith('/auth/refresh');

				if (!shouldRetry) {
					return handler.next(error);
				}

				try {
					final tokens = await AuthService.instance.refreshTokens();
					final retryOptions = Options(
						method: requestOptions.method,
						headers: requestOptions.headers,
						responseType: requestOptions.responseType,
						contentType: requestOptions.contentType,
						extra: {...requestOptions.extra, 'refresh_attempted': true},
						followRedirects: requestOptions.followRedirects,
						validateStatus: requestOptions.validateStatus,
						receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
						sendTimeout: requestOptions.sendTimeout,
						receiveTimeout: requestOptions.receiveTimeout,
					);

					retryOptions.headers?['Authorization'] = 'Bearer ${tokens.accessToken}';
					final retryResponse = await _dio.request<dynamic>(
						requestOptions.path,
						data: requestOptions.data,
						queryParameters: requestOptions.queryParameters,
						options: retryOptions,
						cancelToken: requestOptions.cancelToken,
						onReceiveProgress: requestOptions.onReceiveProgress,
						onSendProgress: requestOptions.onSendProgress,
					);

					return handler.resolve(retryResponse);
				} on AuthServiceException {
					await AuthService.instance.logout();
					return handler.next(error);
				} catch (_) {
					return handler.next(error);
				}
			},
		));
	}

	static final ApiClient instance = ApiClient._privateConstructor();

	final Dio _dio;
	final String _baseUrl;

	Dio get dio => _dio;

	static String _resolveBaseUrl(String? explicitBaseUrl) {
		final fromArg = (explicitBaseUrl ?? '').trim();
		if (_isValidUrl(fromArg)) {
			return fromArg;
		}

		final fromEnv = dotenv.isInitialized
				? (dotenv.env['API_BASE_URL'] ?? '').trim()
				: '';
		if (_isValidUrl(fromEnv)) {
			return fromEnv;
		}

		if (kIsWeb) {
			return 'http://localhost:8080';
		}

		if (defaultTargetPlatform == TargetPlatform.android) {
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
}
