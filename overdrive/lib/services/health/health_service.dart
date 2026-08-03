/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## health_service.dart - Backend health-check client and response models.
 ##
 */

import 'package:dio/dio.dart';

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
		: _dio = dio ?? ApiClient.instance.dio,
		_baseUrl = baseUrl ?? '';

	final Dio _dio;
	
	Future<HealthCheck> getHealth() async {
		try {
			final response = await _dio.get('/health');

			final payload = response.data;

			if (payload is! Map) {
				throw const HealthServiceException(
					'Invalid server response',
				);
			}

			return HealthCheck.fromJson(
				Map<String, dynamic>.from(payload),
			);
		} on DioException catch (exception) {
			throw HealthServiceException(
				_resolveError(exception),
			);
		} on HealthServiceException {
			rethrow;
		} catch (_) {
			throw const HealthServiceException(
				'Invalid server response',
			);
		}
	}

	String _resolveError(DioException exception) {
		final data = exception.response?.data;

		if (data is Map<String, dynamic>) {
			final message = data['error'] ?? data['message'];

			if (message is String && message.trim().isNotEmpty) {
				return message.trim();
			}
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
