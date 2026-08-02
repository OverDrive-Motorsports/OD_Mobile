/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## health_service.dart - Backend health-check client and response models.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api_client.dart';

class HealthCheck {
	const HealthCheck({required this.status, this.timestamp});

	final String status;
	final DateTime? timestamp;

	String get timestampLabel {
		if (timestamp == null) {
			return 'n/a';
		}

		return timestamp!.toIso8601String();
	}

	factory HealthCheck.fromJson(Map<String, dynamic> json) {
		final statusRaw = json['status'];
		final status = statusRaw is String && statusRaw.trim().isNotEmpty
				? statusRaw.trim()
				: 'unknown';

		DateTime? parsedTimestamp;
		final timestampRaw = json['time'];
		if (timestampRaw is String && timestampRaw.trim().isNotEmpty) {
			parsedTimestamp = DateTime.tryParse(timestampRaw.trim());
		}

		return HealthCheck(status: status, timestamp: parsedTimestamp);
	}
}

class HealthService {
	HealthService({Dio? dio, String? baseUrl})
		: _baseUrl = _resolveBaseUrl(baseUrl),
			_dio = dio ?? ApiClient.instance.dio {
		if (_isValidUrl(_baseUrl)) {
			_dio.options.baseUrl = _baseUrl;
		}
	}

	final Dio _dio;
	final String _baseUrl;

	Future<HealthCheck> getHealth() async {
		if (!_isValidUrl(_baseUrl)) {
			throw const HealthServiceException(
				'API base URL is invalid. Expected something like http://localhost:8080.',
			);
		}

		try {
			final response = await _dio.get('/health');
			final payload = response.data;
			if (payload is! Map) {
				throw const HealthServiceException('Invalid server response');
			}

			return HealthCheck.fromJson(Map<String, dynamic>.from(payload));
		} on DioException catch (exception) {
			throw HealthServiceException(_resolveError(exception));
		} on HealthServiceException {
			rethrow;
		} catch (_) {
			throw const HealthServiceException('Invalid server response');
		}
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
}

class HealthServiceException implements Exception {
	const HealthServiceException(this.message);

	final String message;

	@override
	String toString() => message;
}
