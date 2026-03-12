/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## health_service.dart - Typed backend health-check service.
 ##
 */

import 'api_response.dart';
import 'api_service.dart';

class HealthStatus {
  const HealthStatus({
    required this.status,
    this.timestamp,
  });

  final String status;
  final DateTime? timestamp;

  bool get isHealthy => status.toLowerCase() == 'ok';

  String get timestampLabel {
    if (timestamp == null) {
      return 'n/a';
    }
    return timestamp!.toIso8601String();
  }

  static HealthStatus fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'];
    final status =
        statusRaw is String && statusRaw.trim().isNotEmpty
            ? statusRaw.trim()
            : 'unknown';

    DateTime? parsedTime;
    final timeRaw = json['time'];
    if (timeRaw is String && timeRaw.trim().isNotEmpty) {
      parsedTime = DateTime.tryParse(timeRaw.trim());
    }

    return HealthStatus(status: status, timestamp: parsedTime);
  }
}

class HealthService {
  HealthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<ApiResponse<HealthStatus>> checkHealth() async {
    final response = await _apiService.checkHealth();
    if (!response.isSuccess) {
      return ApiResponse.failure(response.error ?? 'Health check failed');
    }

    final payload = response.data;
    if (payload == null) {
      return const ApiResponse.failure('Empty health response');
    }

    return ApiResponse.success(HealthStatus.fromJson(payload));
  }
}
