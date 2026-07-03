/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## auth_service.dart - Authentication service and secure session storage.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
	AuthTokens({
		required this.accessToken,
		required this.refreshToken,
		this.expiresAt,
	});

	final String accessToken;
	final String refreshToken;
	final DateTime? expiresAt;

	bool get isExpired {
		if (expiresAt == null) {
			return false;
		}
		return DateTime.now().isAfter(expiresAt!);
	}
}

class AuthServiceException implements Exception {
	const AuthServiceException(this.message);

	final String message;

	@override
	String toString() => message;
}

class AuthService {
	AuthService._privateConstructor()
			: _storage = const FlutterSecureStorage(),
				_baseUrl = _resolveBaseUrl(null),
				_dio = Dio(
					BaseOptions(
						connectTimeout: const Duration(seconds: 15),
						receiveTimeout: const Duration(seconds: 60),
					),
				) {
		if (_isValidUrl(_baseUrl)) {
			_dio.options.baseUrl = _baseUrl;
		}
	}

	static final AuthService instance = AuthService._privateConstructor();

	static const _accessTokenKey = 'od_access_token';
	static const _refreshTokenKey = 'od_refresh_token';
	static const _expiresAtKey = 'od_expires_at';

	final Dio _dio;
	final FlutterSecureStorage _storage;
	final String _baseUrl;

	Future<AuthTokens> login(String email, String password) async {
		return _authenticate(
			'/auth/login',
			{'email': email.trim(), 'password': password.trim()},
		);
	}

	Future<AuthTokens> signup(String email, String password) async {
		return _authenticate(
			'/auth/signup',
			{'email': email.trim(), 'password': password.trim()},
		);
	}

	Future<AuthTokens> refreshTokens() async {
		final refreshToken = await _storage.read(key: _refreshTokenKey);
		if (refreshToken == null || refreshToken.isEmpty) {
			throw const AuthServiceException('Refresh token is missing.');
		}

		try {
			final response = await _dio.post(
				'/auth/refresh',
				data: {'refresh_token': refreshToken},
			);

			final payload = _validatePayload(response.data);
			final tokens = _extractTokens(payload);
			await _persistTokens(tokens);
			return tokens;
		} on DioException catch (exception) {
			throw AuthServiceException(_resolveError(exception));
		} catch (_) {
			throw const AuthServiceException('Invalid authentication response');
		}
	}

	Future<bool> hasValidSession() async {
		final tokens = await _readTokens();
		if (tokens == null) {
			return false;
		}

		if (!tokens.isExpired) {
			return true;
		}

		try {
			await refreshTokens();
			return true;
		} catch (_) {
			await logout();
			return false;
		}
	}

	Future<void> logout() async {
		await _storage.delete(key: _accessTokenKey);
		await _storage.delete(key: _refreshTokenKey);
		await _storage.delete(key: _expiresAtKey);
	}

	Future<String?> get accessToken async {
		final tokens = await _readTokens();
		return tokens?.accessToken;
	}

	Future<AuthTokens> _authenticate(String path, Map<String, dynamic> body) async {
		if (!_isValidUrl(_baseUrl)) {
			throw const AuthServiceException(
				'API base URL is invalid. Expected something like http://localhost:8080.',
			);
		}

		try {
			final response = await _dio.post(path, data: body);
			final payload = _validatePayload(response.data);
			final tokens = _extractTokens(payload);
			await _persistTokens(tokens);
			return tokens;
		} on DioException catch (exception) {
			throw AuthServiceException(_resolveError(exception));
		} catch (_) {
			throw const AuthServiceException('Invalid authentication response');
		}
	}

	Future<void> _persistTokens(AuthTokens tokens) async {
		await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
		await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);

		if (tokens.expiresAt != null) {
			await _storage.write(
				key: _expiresAtKey,
				value: tokens.expiresAt!.toIso8601String(),
			);
		} else {
			await _storage.delete(key: _expiresAtKey);
		}
	}

	Future<AuthTokens?> _readTokens() async {
		final accessToken = await _storage.read(key: _accessTokenKey);
		final refreshToken = await _storage.read(key: _refreshTokenKey);
		if (accessToken == null || refreshToken == null) {
			return null;
		}

		final expiresAtString = await _storage.read(key: _expiresAtKey);
		DateTime? expiresAt;
		if (expiresAtString != null && expiresAtString.isNotEmpty) {
			expiresAt = DateTime.tryParse(expiresAtString);
		}

		return AuthTokens(
			accessToken: accessToken,
			refreshToken: refreshToken,
			expiresAt: expiresAt,
		);
	}

	Map<String, dynamic> _validatePayload(dynamic payload) {
		if (payload is! Map<String, dynamic>) {
			throw const AuthServiceException('Invalid server response.');
		}
		return payload;
	}

	AuthTokens _extractTokens(Map<String, dynamic> payload) {
		final accessToken = _stringValue(payload['access_token'] ?? payload['accessToken'] ?? payload['token']);
		final refreshToken = _stringValue(payload['refresh_token'] ?? payload['refreshToken']);

		if (accessToken.isEmpty || refreshToken.isEmpty) {
			throw const AuthServiceException('Missing authentication tokens in response.');
		}

		final expiresIn = _intValue(payload['expires_in'] ?? payload['expiresIn']);
		final expiresAt = expiresIn != null ? DateTime.now().add(Duration(seconds: expiresIn)) : null;

		return AuthTokens(
			accessToken: accessToken,
			refreshToken: refreshToken,
			expiresAt: expiresAt,
		);
	}

	String _stringValue(dynamic value) {
		if (value is String) {
			return value.trim();
		}
		return '';
	}

	int? _intValue(dynamic value) {
		if (value is int) {
			return value;
		}
		if (value is String) {
			return int.tryParse(value.trim());
		}
		return null;
	}

	String _resolveError(DioException exception) {
		final usesAndroidEmulatorHost = _baseUrl.contains('10.0.2.2');
		final isNetworkError =
				exception.type == DioExceptionType.connectionTimeout ||
				exception.type == DioExceptionType.receiveTimeout ||
				exception.type == DioExceptionType.connectionError;

		if (usesAndroidEmulatorHost && isNetworkError) {
			return 'Timeout on 10.0.2.2. On a real phone, set API_BASE_URL to your computer LAN IP.';
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
