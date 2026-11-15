import 'telemetry_repository.dart';
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

class GetTelemetrySpeed {
    GetTelemetrySpeed(this.repository);

    final TelemetryRepository repository;

    Future<List<TelemetrySpeed>> call({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) {
        return repository.getSpeed(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
    }
}

class GetTelemetryEngine {
    GetTelemetryEngine(this.repository);

    final TelemetryRepository repository;

    Future<List<TelemetryEngine>> call({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) {
        return repository.getEngine(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
    }
}

class GetTelemetryLocation {
    GetTelemetryLocation(this.repository);

    final TelemetryRepository repository;

    Future<List<TelemetryLocation>> call({
        required String sessionId,
        required int driverNumber,
        int? lapNumber,
    }) {
        return repository.getLocation(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
    }
}

class GetTelemetryIntervals {
    GetTelemetryIntervals(this.repository);

    final TelemetryRepository repository;

    Future<TelemetryIntervals> call({
        required String sessionId,
        required int driverNumber,
    }) {
        return repository.getIntervals(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
    }
}

class GetRaceLaps {
    GetRaceLaps(this.repository);

    final TelemetryRepository repository;

    Future<RaceLaps> call({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) {
        return repository.getLaps(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
    }
}

class GetRacePositions {
    GetRacePositions(this.repository);

    final TelemetryRepository repository;

    Future<List<RacePosition>> call({
        required String sessionId,
        int? driverNumber,
        int? lapNumber,
    }) {
        return repository.getPositions(
            sessionId: sessionId,
            driverNumber: driverNumber,
            lapNumber: lapNumber,
        );
    }
}

class GetRaceStints {
    GetRaceStints(this.repository);

    final TelemetryRepository repository;

    Future<List<RaceStint>> call({
        required String sessionId,
        int? driverNumber,
    }) {
        return repository.getStints(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
    }
}

class GetRacePitStops {
    GetRacePitStops(this.repository);

    final TelemetryRepository repository;

    Future<List<RacePitStop>> call({
        required String sessionId,
        int? driverNumber,
    }) {
        return repository.getPitStops(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
    }
}

class GetRaceWeather {
    GetRaceWeather(this.repository);

    final TelemetryRepository repository;

    Future<List<RaceWeather>> call({
        required String sessionId,
    }) {
        return repository.getWeather(sessionId: sessionId);
    }
}

class GetRaceControl {
    GetRaceControl(this.repository);

    final TelemetryRepository repository;

    Future<List<RaceControl>> call({
        required String sessionId,
    }) {
        return repository.getRaceControl(sessionId: sessionId);
    }
}

class GetRaceRadio {
    GetRaceRadio(this.repository);

    final TelemetryRepository repository;

    Future<List<RaceRadio>> call({
        required String sessionId,
        int? driverNumber,
    }) {
        return repository.getRadio(
            sessionId: sessionId,
            driverNumber: driverNumber,
        );
    }
}
