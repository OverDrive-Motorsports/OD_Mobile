class TelemetrySpeedDto {
    const TelemetrySpeedDto({
        required this.speed,
        required this.gear,
        required this.timestamp,
    });

    final num? speed;
    final int? gear;
    final DateTime? timestamp;

    factory TelemetrySpeedDto.fromJson(Map<String, dynamic> json) {
        return TelemetrySpeedDto(
            speed: json['speed'] as num?,
            gear: json['gear'] as int?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

class TelemetryEngineDto {
    const TelemetryEngineDto({
        required this.rpm,
        required this.gear,
        required this.throttlePercent,
        required this.brakePercent,
        required this.drsActive,
        required this.timestamp,
    });

    final num? rpm;
    final int? gear;
    final num? throttlePercent;
    final num? brakePercent;
    final bool? drsActive;
    final DateTime? timestamp;

    factory TelemetryEngineDto.fromJson(Map<String, dynamic> json) {
        return TelemetryEngineDto(
            rpm: json['rpm'] as num?,
            gear: json['gear'] as int?,
            throttlePercent: json['throttlePercent'] as num?,
            brakePercent: json['brakePercent'] as num?,
            drsActive: json['drsActive'] as bool?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

class TelemetryLocationDto {
    const TelemetryLocationDto({
        required this.x,
        required this.y,
        required this.z,
        required this.timestamp,
    });

    final num? x;
    final num? y;
    final num? z;
    final DateTime? timestamp;

    factory TelemetryLocationDto.fromJson(Map<String, dynamic> json) {
        return TelemetryLocationDto(
            x: json['x'] as num?,
            y: json['y'] as num?,
            z: json['z'] as num?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

class TelemetryIntervalDto {
    const TelemetryIntervalDto({
        required this.driverNumber,
        required this.gapToLeader,
        required this.gapAhead,
        required this.timestamp,
    });

    final int? driverNumber;
    final num? gapToLeader;
    final num? gapAhead;
    final DateTime? timestamp;

    factory TelemetryIntervalDto.fromJson(Map<String, dynamic> json) {
        return TelemetryIntervalDto(
            driverNumber: json['driverNumber'] as int?,
            gapToLeader: json['gapToLeader'] as num?,
            gapAhead: json['gapAhead'] as num?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

class RaceLapDto {
    const RaceLapDto({
        required this.lapNumber,
        required this.lapDuration,
        required this.sector1,
        required this.sector2,
        required this.sector3,
        required this.isPitOutLap,
    });

    final int? lapNumber;
    final num? lapDuration;
    final num? sector1;
    final num? sector2;
    final num? sector3;
    final bool? isPitOutLap;

    factory RaceLapDto.fromJson(Map<String, dynamic> json) {
        return RaceLapDto(
            lapNumber: json['lapNumber'] as int?,
            lapDuration: json['lapDuration'] as num?,
            sector1: json['sector1'] as num?,
            sector2: json['sector2'] as num?,
            sector3: json['sector3'] as num?,
            isPitOutLap: json['isPitOutLap'] as bool?,
        );
    }
}


class RaceLapsDto {
    const RaceLapsDto({
        this.laps = const [],
        this.bestLap,
        this.averageLap,
    });

    final List<RaceLapDto> laps;
    final num? bestLap;
    final num? averageLap;

    factory RaceLapsDto.fromJson(Map<String, dynamic> json) {
        final rawLaps = json['laps'] as List<dynamic>? ?? [];

        return RaceLapsDto(
            laps: rawLaps
                .whereType<Map<String, dynamic>>()
                .map(RaceLapDto.fromJson)
                .toList(),
            bestLap: json['bestLap'] as num?,
            averageLap: json['averageLap'] as num?,
        );
    }
}


class RacePositionDto {
    const RacePositionDto({
        required this.driverNumber,
        required this.position,
        required this.gapToLeader,
        required this.gapAhead,
        required this.gapBehind,
        required this.lapsCompleted,
        required this.timestamp,
    });

    final int? driverNumber;
    final int? position;
    final num? gapToLeader;
    final num? gapAhead;
    final num? gapBehind;
    final int? lapsCompleted;
    final DateTime? timestamp;

    factory RacePositionDto.fromJson(Map<String, dynamic> json) {
        return RacePositionDto(
            driverNumber: json['driverNumber'] as int?,
            position: json['position'] as int?,
            gapToLeader: json['gapToLeader'] as num?,
            gapAhead: json['gapAhead'] as num?,
            gapBehind: json['gapBehind'] as num?,
            lapsCompleted: json['lapsCompleted'] as int?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

class RaceStintDto {
    const RaceStintDto({
        required this.driverNumber,
        required this.stintNumber,
        required this.compound,
        required this.lapStart,
        required this.lapEnd,
        required this.tyreAgeAtStart,
    });

    final int? driverNumber;
    final int? stintNumber;
    final String? compound;
    final int? lapStart;
    final int? lapEnd;
    final int? tyreAgeAtStart;

    factory RaceStintDto.fromJson(Map<String, dynamic> json) {
        return RaceStintDto(
            driverNumber: json['driverNumber'] as int?,
            stintNumber: json['stintNumber'] as int?,
            compound: json['compound'] as String?,
            lapStart: json['lapStart'] as int?,
            lapEnd: json['lapEnd'] as int?,
            tyreAgeAtStart: json['tyreAgeAtStart'] as int?,
        );
    }
}

class RacePitStopDto {
    const RacePitStopDto({
        required this.driverNumber,
        required this.lapNumber,
        required this.pitDuration,
    });

    final int? driverNumber;
    final int? lapNumber;
    final num? pitDuration;

    factory RacePitStopDto.fromJson(Map<String, dynamic> json) {
        return RacePitStopDto(
            driverNumber: json['driverNumber'] as int?,
            lapNumber: json['lapNumber'] as int?,
            pitDuration: json['pitDuration'] as num?,
        );
    }
}

class RaceWeatherDto {
    const RaceWeatherDto({
        required this.timestamp,
        required this.airTemperature,
        required this.trackTemperature,
        required this.humidity,
        required this.windSpeed,
        required this.rainfall,
    });

    final DateTime? timestamp;
    final num? airTemperature;
    final num? trackTemperature;
    final num? humidity;
    final num? windSpeed;
    final num? rainfall;

    factory RaceWeatherDto.fromJson(Map<String, dynamic> json) {
        return RaceWeatherDto(
            timestamp: _parseDateTime(json['timestamp']),
            airTemperature: json['airTemperature'] as num?,
            trackTemperature: json['trackTemperature'] as num?,
            humidity: json['humidity'] as num?,
            windSpeed: json['windSpeed'] as num?,
            rainfall: json['rainfall'] as num?,
        );
    }
}

class RaceControlDto {
    const RaceControlDto({
        required this.category,
        required this.flag,
        required this.penality,
        required this.safetyCar,
        required this.message,
        required this.lapNumber,
        required this.timestamp,
    });

    final String? category;
    final String? flag;
    final String? penality;
    final String? safetyCar;
    final String? message;
    final int? lapNumber;
    final DateTime? timestamp;

    factory RaceControlDto.fromJson(Map<String, dynamic> json) {
        return RaceControlDto(
            category: json['category'] as String?,
            flag: json['flag'] as String?,
            penality: json['penality'] as String?,
            safetyCar: json['safetyCar'] as String?,
            message: json['message'] as String?,
            lapNumber: json['lapNumber'] as int?,
            timestamp: _parseDateTime(json['timestamp']),
        );
    }
}

DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
        return null;
    }

    return DateTime.tryParse(value);
}


class RaceRadioDto {
    const RaceRadioDto({
        this.driverNumber,
        this.timestamp,
        this.audioUrl,
    });

    final int? driverNumber;
    final DateTime? timestamp;
    final String? audioUrl;

    factory RaceRadioDto.fromJson(Map<String, dynamic> json) {
        return RaceRadioDto(
            driverNumber: (json['driverNumber'] as num?)?.toInt(),
            timestamp: _parseDateTime(json['timestamp']),
            audioUrl: json['audioUrl'] as String?,
        );
    }
}
