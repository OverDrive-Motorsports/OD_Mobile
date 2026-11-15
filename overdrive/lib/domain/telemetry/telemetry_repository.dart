import 'race_lap.dart';
import 'race_position.dart';
import 'race_stint.dart';
import 'race_pit_stop.dart';
import 'race_weather.dart';
import 'race_control.dart';
import 'race_radio.dart';
import 'telemetry_speed.dart';
import 'telemetry_engine.dart';
import 'telemetry_location.dart';
import 'telemetry_intervals.dart';

abstract class TelemetryRepository {
    Future<List<TelemetrySpeed>> getSpeed({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    });

    Future<List<TelemetryEngine>> getEngine({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    });

    Future<List<TelemetryLocation>> getLocation({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    });

    Future<TelemetryIntervals> getIntervals({
        required String sessionId,
        required int driverNumber,
    });

    Future<RaceLaps> getLaps({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    });

    Future<List<RacePosition>> getPositions({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    });

    Future<List<RaceStint>> getStints({
        required String sessionId,
        int? driverNumber,
    });

    Future<List<RacePitStop>> getPitStops({
        required String sessionId,
        int? driverNumber,
    });

    Future<List<RaceWeather>> getWeather({
        required String sessionId,
    });

    Future<List<RaceControl>> getRaceControl({
        required String sessionId,
    });

    Future<List<RaceRadio>> getRadio({
        required String sessionId,
        int? driverNumber,
    });
}
