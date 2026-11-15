import '../../domain/telemetry/telemetry_repository.dart';
import '../../domain/telemetry/race_lap.dart';
import '../../domain/telemetry/race_position.dart';
import '../../domain/telemetry/race_stint.dart';
import '../../domain/telemetry/race_pit_stop.dart';
import '../../domain/telemetry/race_weather.dart';
import '../../domain/telemetry/race_control.dart';
import '../../domain/telemetry/race_radio.dart';
import '../../domain/telemetry/telemetry_speed.dart';
import '../../domain/telemetry/telemetry_engine.dart';
import '../../domain/telemetry/telemetry_location.dart';
import '../../domain/telemetry/telemetry_intervals.dart';

import 'telemetry_gateway_client.dart';
import 'telemetry_mappers.dart';

class TelemetryGatewayRepository implements TelemetryRepository {
    TelemetryGatewayRepository({
        TelemetryGatewayClient? client,
    }) : _client = client ?? TelemetryGatewayClient();

    final TelemetryGatewayClient _client;

    @override
    Future<List<TelemetrySpeed>> getSpeed({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final dtos = await _client.getSpeed(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
        return TelemetryMappers.speeds(dtos);
    }

    @override
    Future<List<TelemetryEngine>> getEngine({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final dtos = await _client.getEngine(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
        return TelemetryMappers.engines(dtos);
    }

    @override
    Future<List<TelemetryLocation>> getLocation({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) async {
        final dtos = await _client.getLocation(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
        return TelemetryMappers.locations(dtos);
    }

    @override
    Future<TelemetryIntervals> getIntervals({
        required String sessionId,
        required int driverNumber,
    }) async {
        final dto = await _client.getIntervals(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
        return TelemetryMappers.intervals(dto);
    }

    @override
    Future<RaceLaps> getLaps({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) async {
        final dto = await _client.getLaps(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
        return TelemetryMappers.raceLaps(dto);
    }

    @override
    Future<List<RacePosition>> getPositions({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) async {
        final dtos = await _client.getPositions(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
        return TelemetryMappers.positions(dtos);
    }

    @override
    Future<List<RaceStint>> getStints({
        required String sessionId,
        int? driverNumber,
    }) async {
        final dtos = await _client.getStints(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
        return TelemetryMappers.stints(dtos);
    }

    @override
    Future<List<RacePitStop>> getPitStops({
        required String sessionId,
        int? driverNumber,
    }) async {
        final dtos = await _client.getPitStops(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
        return TelemetryMappers.pitStops(dtos);
    }

    @override
    Future<List<RaceWeather>> getWeather({
        required String sessionId,
    }) async {
        final dtos = await _client.getWeather(
            sessionId: sessionId,
        );
        return TelemetryMappers.weatherHistory(dtos);
    }

    @override
    Future<List<RaceControl>> getRaceControl({
        required String sessionId,
    }) async {
        final dtos = await _client.getRaceControl(
            sessionId: sessionId,
        );
        return TelemetryMappers.raceControlEvents(dtos);
    }

    @override
    Future<List<RaceRadio>> getRadio({
        required String sessionId,
        int? driverNumber,
    }) async {
        final dtos = await _client.getRadio(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
        return TelemetryMappers.radios(dtos);
    }
}
