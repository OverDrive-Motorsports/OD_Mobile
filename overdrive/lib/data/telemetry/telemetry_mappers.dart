import '../../domain/telemetry/telemetry_engine.dart';
import '../../domain/telemetry/telemetry_intervals.dart';
import '../../domain/telemetry/telemetry_location.dart';
import '../../domain/telemetry/telemetry_speed.dart';
import '../../domain/telemetry/race_control.dart';
import '../../domain/telemetry/race_lap.dart';
import '../../domain/telemetry/race_pit_stop.dart';
import '../../domain/telemetry/race_position.dart';
import '../../domain/telemetry/race_stint.dart';
import '../../domain/telemetry/race_weather.dart';
import '../../domain/telemetry/race_radio.dart';
import 'telemetry_dto.dart';

class TelemetryMappers {
    const TelemetryMappers._();

    static double? _toDouble(num? value) {
        return value?.toDouble();
    }

    static TelemetrySpeed speed(TelemetrySpeedDto dto) {
        return TelemetrySpeed(
            speed: _toDouble(dto.speed),
            gear: dto.gear,
            timestamp: dto.timestamp,
        );
    }

    static TelemetryEngine engine(TelemetryEngineDto dto) {
        return TelemetryEngine(
            rpm: _toDouble(dto.rpm),
            gear: dto.gear,
            throttlePercent: _toDouble(dto.throttlePercent),
            brakePercent: _toDouble(dto.brakePercent),
            drsActive: dto.drsActive,
            timestamp: dto.timestamp,
        );
    }

    static TelemetryLocation location(TelemetryLocationDto dto) {
        return TelemetryLocation(
            x: _toDouble(dto.x),
            y: _toDouble(dto.y),
            z: _toDouble(dto.z),
            timestamp: dto.timestamp,
        );
    }

    static TelemetryIntervals intervals(TelemetryIntervalDto dto) {
        return TelemetryIntervals(
            driverNumber: dto.driverNumber,
            gapToLeader: _toDouble(dto.gapToLeader),
            gapAhead: _toDouble(dto.gapAhead),
            timestamp: dto.timestamp,
        );
    }

    static RaceLap lap(RaceLapDto dto) {
        return RaceLap(
            lapNumber: dto.lapNumber,
            lapDuration: _toDouble(dto.lapDuration),
            sector1: _toDouble(dto.sector1),
            sector2: _toDouble(dto.sector2),
            sector3: _toDouble(dto.sector3),
            isPitOutLap: dto.isPitOutLap,
        );
    }

    static RacePosition position(RacePositionDto dto) {
        return RacePosition(
            driverNumber: dto.driverNumber,
            position: dto.position,
            gapToLeader: _toDouble(dto.gapToLeader),
            gapAhead: _toDouble(dto.gapAhead),
            gapBehind: _toDouble(dto.gapBehind),
            lapsCompleted: dto.lapsCompleted,
            timestamp: dto.timestamp,
        );
    }

    static RaceStint stint(RaceStintDto dto) {
        return RaceStint(
            driverNumber: dto.driverNumber,
            stintNumber: dto.stintNumber,
            compound: dto.compound,
            lapStart: dto.lapStart,
            lapEnd: dto.lapEnd,
            tyreAgeAtStart: dto.tyreAgeAtStart,
        );
    }

    static RacePitStop pitStop(RacePitStopDto dto) {
        return RacePitStop(
            driverNumber: dto.driverNumber,
            lapNumber: dto.lapNumber,
            pitDuration: _toDouble(dto.pitDuration),
        );
    }

    static RaceWeather weather(RaceWeatherDto dto) {
        return RaceWeather(
            timestamp: dto.timestamp,
            airTemperature: _toDouble(dto.airTemperature),
            trackTemperature: _toDouble(dto.trackTemperature),
            humidity: _toDouble(dto.humidity),
            windSpeed: _toDouble(dto.windSpeed),
            rainfall: _toDouble(dto.rainfall),
        );
    }

    static RaceControl raceControl(RaceControlDto dto) {
        return RaceControl(
            category: dto.category,
            flag: dto.flag,
            penalty: dto.penality,
            safetyCar: dto.safetyCar,
            message: dto.message,
            lapNumber: dto.lapNumber,
            timestamp: dto.timestamp,
        );
    }

    static List<TelemetrySpeed> speeds(
        List<TelemetrySpeedDto> dtos,
    ) {
        return dtos.map(speed).toList();
    }

    static List<TelemetryEngine> engines(
        List<TelemetryEngineDto> dtos,
    ) {
        return dtos.map(engine).toList();
    }

    static List<TelemetryLocation> locations(
        List<TelemetryLocationDto> dtos,
    ) {
        return dtos.map(location).toList();
    }

    static List<RaceLap> laps(List<RaceLapDto> dtos) {
        return dtos.map(lap).toList();
    }

    static List<RacePosition> positions(
        List<RacePositionDto> dtos,
    ) {
        return dtos.map(position).toList();
    }

    static List<RaceStint> stints(List<RaceStintDto> dtos) {
        return dtos.map(stint).toList();
    }

    static List<RacePitStop> pitStops(
        List<RacePitStopDto> dtos,
    ) {
        return dtos.map(pitStop).toList();
    }

    static List<RaceWeather> weatherHistory(
        List<RaceWeatherDto> dtos,
    ) {
        return dtos.map(weather).toList();
    }

    static List<RaceControl> raceControlEvents(
        List<RaceControlDto> dtos,
    ) {
        return dtos.map(raceControl).toList();
    }

    static RaceLaps raceLaps(RaceLapsDto dto) {
        return RaceLaps(
            laps: dto.laps.map(lap).toList(),
            bestLap: _toDouble(dto.bestLap),
            averageLap: _toDouble(dto.averageLap),
        );
    }

    static RaceRadio radio(RaceRadioDto dto) {
        return RaceRadio(
            driverNumber: dto.driverNumber,
            timestamp: dto.timestamp,
            audioUrl: dto.audioUrl,
        );
    }

    static List<RaceRadio> radios(List<RaceRadioDto> dtos) {
        return dtos.map(radio).toList();
    }
}
