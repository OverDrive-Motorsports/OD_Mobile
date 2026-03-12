/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## f1_service.dart - Typed F1 API service for standings endpoints.
 ##
 */

import 'api_response.dart';
import 'api_service.dart';

class DriverStanding {
  const DriverStanding({
    required this.position,
    required this.driverName,
    required this.points,
  });

  final int position;
  final String driverName;
  final double points;

  String get pointsLabel {
    if (points == points.roundToDouble()) {
      return points.toInt().toString();
    }
    return points.toStringAsFixed(1);
  }

  static DriverStanding? fromJson(Map<String, dynamic> json) {
    final position = _readInt(json, const ['position_current', 'position']);
    if (position == null || position <= 0) {
      return null;
    }

    final name =
        _readString(json, const ['driver_name', 'full_name', 'broadcast_name']) ??
        (() {
          final driverNumber = _readInt(json, const ['driver_number']);
          if (driverNumber == null || driverNumber <= 0) {
            return null;
          }
          return 'Driver #$driverNumber';
        })();

    if (name == null || name.trim().isEmpty) {
      return null;
    }

    final points =
        _readDouble(
          json,
          const [
            'points_start',
            'pointsStart',
            'points_current',
            'pointsCurrent',
            'points',
          ],
        ) ??
        0;

    return DriverStanding(
      position: position,
      driverName: name.trim(),
      points: points,
    );
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
        final parsedDouble = double.tryParse(value.trim());
        if (parsedDouble != null) {
          return parsedDouble.toInt();
        }
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is double) {
        return value;
      }
      if (value is int) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

class F1Service {
  F1Service({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<ApiResponse<List<DriverStanding>>> getDriverStandings() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/api/v1/race/championship/drivers',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
      receiveTimeout: const Duration(seconds: 90),
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(response.error ?? 'Unable to fetch standings');
    }

    final payload = response.data;
    if (payload == null) {
      return const ApiResponse.failure('Empty standings response');
    }

    final data = payload['data'];
    if (data is! List) {
      return const ApiResponse.failure('Invalid standings payload');
    }

    final standings = <DriverStanding>[];
    for (final row in data) {
      if (row is! Map) {
        continue;
      }
      final standing = DriverStanding.fromJson(
        Map<String, dynamic>.from(row),
      );
      if (standing != null) {
        standings.add(standing);
      }
    }

    standings.sort((a, b) {
      if (a.position == b.position) {
        return a.driverName.compareTo(b.driverName);
      }
      return a.position.compareTo(b.position);
    });

    return ApiResponse.success(standings);
  }
}
