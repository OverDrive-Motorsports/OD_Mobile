import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'telemetry_dto.dart';

class TelemetryGatewayClient {
    TelemetryGatewayClient({
        Dio? dio,
        String? baseUrl,
        FlutterSecureStorage? secureStorage,
    })  : _dio = dio ?? Dio(),
          _baseUrl = _resolveBaseUrl(baseUrl),
          _secureStorage =
              secureStorage ?? const FlutterSecureStorage() {
        _dio.options
          ..connectTimeout = const Duration(seconds: 15)
          ..receiveTimeout = const Duration(seconds: 60)
          ..sendTimeout = const Duration(seconds: 15);
    }

    final Dio _dio;
    final String _baseUrl;
    final FlutterSecureStorage _secureStorage;

    static String _resolveBaseUrl(String? explicitBaseUrl) {
        final configuredUrl = explicitBaseUrl ??
            dotenv.env['GATEWAY_BASE_URL'] ??
            dotenv.env['API_BASE_URL'] ??
            'http://localhost:3000';

        final uri = Uri.parse(configuredUrl);

        if (uri.host == 'localhost' &&
            defaultTargetPlatform == TargetPlatform.android) {
            return uri.replace(host: '10.0.2.2').toString();
        }

        return configuredUrl;
    }

    Future<Map<String, dynamic>> _get(
        String path, {
        Map<String, dynamic>? queryParameters,
    }) async {
        final token = await _secureStorage.read(
            key: 'od_access_token',
        );

        if (token == null || token.isEmpty) {
            throw StateError(
                'Access token is missing. Please authenticate first.',
            );
        }

        final response = await _dio.get<dynamic>(
            '$_baseUrl/v1/race-data$path',
            queryParameters: queryParameters,
            options: Options(
                headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                },
            ),
        );

        final data = response.data;

        if (data is Map<String, dynamic>) {
            return data;
        }

        throw FormatException(
            'Expected a JSON object from $path.',
        );
    }

    Future<List<dynamic>> _getList(
        String path, {
        Map<String, dynamic>? queryParameters,
    }) async {
        final token = await _secureStorage.read(
            key: 'od_access_token',
        );

        if (token == null || token.isEmpty) {
            throw StateError(
                'Access token is missing. Please authenticate first.',
            );
        }

        final response = await _dio.get<dynamic>(
            '$_baseUrl/v1/race-data$path',
            queryParameters: queryParameters,
            options: Options(
                headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                },
            ),
        );

        final data = response.data;

        if (data is List) {
            return data;
        }

        throw FormatException(
            'Expected a JSON array from $path.',
        );
    }

    Future<List<TelemetrySpeedDto>> getSpeed({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final data = await _getList(
            '/sessions/$sessionId/drivers/$driverNumber/telemetry/speed',
            queryParameters: {
                if (lapNumber != null) 'lapNumber': lapNumber,
            },
        );

        return data
            .map(
                (item) => TelemetrySpeedDto.fromJson(
                    Map<String, dynamic>.from(item as Map),
                ),
            )
            .toList();
    }

    Future<List<TelemetryEngineDto>> getEngine({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final data = await _getList(
            '/sessions/$sessionId/drivers/$driverNumber/telemetry/engine',
            queryParameters: {
                if (lapNumber != null) 'lapNumber': lapNumber,
            },
        );

        return data
            .map(
                (item) => TelemetryEngineDto.fromJson(
                    Map<String, dynamic>.from(item as Map),
                ),
            )
            .toList();
    }

    Future<List<TelemetryLocationDto>> getLocation({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final data = await _getList(
            '/sessions/$sessionId/drivers/$driverNumber/telemetry/location',
            queryParameters: {
                if (lapNumber != null) 'lapNumber': lapNumber,
            },
        );

        return data
            .map(
                (item) => TelemetryLocationDto.fromJson(
                    Map<String, dynamic>.from(item as Map),
                ),
            )
            .toList();
    }

    Future<TelemetryIntervalDto> getIntervals({
        required String sessionId,
        required int driverNumber,
    }) async {
        final data = await _get(
            '/sessions/$sessionId/drivers/$driverNumber/telemetry/intervals',
        );

        return TelemetryIntervalDto.fromJson(data);
    }


    Future<RaceLapsDto> getLaps({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
            if (lapNumber != null) 'lapNumber': lapNumber,
        };

        final data = await _get(
            '/sessions/$sessionId/race/laps',
            queryParameters: queryParameters,
        );

        return RaceLapsDto.fromJson(data);
    }

   
    Future<List<RacePositionDto>> getPositions({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
            if (lapNumber != null) 'lapNumber': lapNumber,
        };

        final token = await _secureStorage.read(
            key: 'od_access_token',
        );

        if (token == null || token.isEmpty) {
            throw StateError(
                'Access token is missing. Please authenticate first.',
            );
        }

        final response = await _dio.get<dynamic>(
            '$_baseUrl/v1/race-data/sessions/$sessionId/race/position',
            queryParameters: queryParameters,
            options: Options(
                headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                },
            ),
        );

        final data = response.data;

        if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(RacePositionDto.fromJson)
                .toList();
        }

        if (data is Map<String, dynamic>) {
            return [RacePositionDto.fromJson(data)];
        }

        throw const FormatException(
            'Expected a JSON object or array from race positions.',
        );
    }


    Future<List<RaceStintDto>> getStints({
        required String sessionId,
        int? driverNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
        };

        final data = await _getList(
            '/sessions/$sessionId/race/stints',
            queryParameters: queryParameters,
        );

        return data
            .map((json) => RaceStintDto.fromJson(json))
            .toList();
    }

    Future<List<RacePitStopDto>> getPitStops({
        required String sessionId,
        int? driverNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
        };

        final data = await _getList(
            '/sessions/$sessionId/race/pitstops',
            queryParameters: queryParameters,
        );

        return data
            .map((json) => RacePitStopDto.fromJson(json))
            .toList();
    }

    Future<List<RaceWeatherDto>> getWeather({
        required String sessionId,
    }) async {
        final data = await _getList(
            '/v1/race-data/sessions/$sessionId/race/weather',
        );

        return data
            .map((json) => RaceWeatherDto.fromJson(json))
            .toList();
    }


    Future<List<RaceControlDto>> getRaceControl({
        required String sessionId,
    }) async {
        final token = await _secureStorage.read(
            key: 'od_access_token',
        );

        if (token == null || token.isEmpty) {
            throw StateError(
                'Access token is missing. Please authenticate first.',
            );
        }

        final response = await _dio.post<dynamic>(
            '$_baseUrl/v1/race-data/sessions/$sessionId/race/control',
            options: Options(
                headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                },
            ),
        );

        final data = response.data;

        if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(RaceControlDto.fromJson)
                .toList();
        }

        if (data is Map<String, dynamic>) {
            return [RaceControlDto.fromJson(data)];
        }

        throw const FormatException(
            'Expected a JSON object or array from race control.',
        );
    }


    Future<List<RaceRadioDto>> getRadio({
        required String sessionId,
        int? driverNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
        };

        final data = await _getList(
            '/sessions/$sessionId/race/radio',
            queryParameters: queryParameters,
        );

        return data
            .map((json) => RaceRadioDto.fromJson(json))
            .toList();
    }

    Future<Map<String, dynamic>> getReplay({
        required String sessionId,
        int? driverNumber,
    }) async {
        final queryParameters = <String, dynamic>{
            if (driverNumber != null) 'driverNumber': driverNumber,
        };

        return _get(
            '/sessions/$sessionId/race/replay',
            queryParameters: queryParameters,
        );
    }
}
