import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

// Track-level ambient data shared across all drivers — not per-lap, queried via TelemetrySimulator.getTrackConditions().
class TrackConditions {
  const TrackConditions({
    required this.trackTemp,
    required this.airTemp,
    required this.humidity,
    required this.conditions,
    required this.windSpeed,
  });

  final double trackTemp;
  final double airTemp;
  final double humidity;
  final String conditions;
  final double windSpeed;
}

// Immutable snapshot of one driver's telemetry state, emitted every 200 ms by TelemetrySimulator.
class TelemetrySnapshot {
  const TelemetrySnapshot({
    required this.speed,
    required this.gear,
    required this.throttle,
    required this.brake,
    required this.rpm,
    required this.drs,
    required this.ersLevel,
    required this.ersMode,
    required this.gLat,
    required this.gLon,
    required this.tyreTemp,
    required this.sectorTimes,
    required this.bestSectorTimes,
    required this.currentLapTime,
    required this.bestLapTime,
    required this.gapToLeader,
    required this.trend,
    required this.maxSpeedLap,
    required this.avgSpeedLap,
    required this.fuelLoad,
    required this.fuelPerLap,
    required this.tyreAge,
    required this.tyreCompound,
    required this.waterTemp,
    required this.oilTemp,
    required this.engineMode,
    required this.pitWindowOpen,
  });

  final double speed;
  final int gear;
  final double throttle;
  final double brake;
  final int rpm;
  final bool drs;
  final double ersLevel;
  final String ersMode;
  final double gLat;
  final double gLon;
  final Map<String, double> tyreTemp;
  final List<double?> sectorTimes;
  final List<double> bestSectorTimes;
  final double currentLapTime;
  final double bestLapTime;
  final String gapToLeader;
  final String trend;
  final double maxSpeedLap;
  final double avgSpeedLap;
  final double fuelLoad;
  final double fuelPerLap;
  final int tyreAge;
  final String tyreCompound;
  final double waterTemp;
  final double oilTemp;
  final String engineMode;
  final bool pitWindowOpen;
}

class TelemetryMockData {
  TelemetryMockData._();

  static const List<Map<String, dynamic>> drivers = [
    {'id': 'VER', 'name': 'Verstappen', 'team': 'Red Bull Racing', 'position': 1},
    {'id': 'LEC', 'name': 'Leclerc', 'team': 'Ferrari', 'position': 2},
    {'id': 'NOR', 'name': 'Norris', 'team': 'McLaren', 'position': 3},
  ];

  static Map<String, dynamic> driverById(String id) =>
      drivers.firstWhere((d) => d['id'] == id, orElse: () => drivers.first);
}

class _DriverState {
  _DriverState({
    required this.speed,
    required this.gear,
    required this.throttle,
    required this.brake,
    required this.rpm,
    required this.drs,
    required this.ersLevel,
    required this.ersMode,
    required this.gLat,
    required this.gLon,
    required this.flTemp,
    required this.frTemp,
    required this.rlTemp,
    required this.rrTemp,
    required this.s1Time,
    required this.s2Time,
    required this.s3Time,
    required this.bestS1,
    required this.bestS2,
    required this.bestS3,
    required this.currentLapTime,
    required this.bestLapTime,
    required this.gapToLeader,
    required this.trend,
    required this.maxSpeedLap,
    required this.avgSpeedLap,
    required this.s1Target,
    required this.s2Target,
    required this.lapTarget,
    required this.fuelLoad,
    required this.fuelPerLap,
    required this.tyreAge,
    required this.tyreCompound,
    required this.waterTemp,
    required this.oilTemp,
    required this.engineMode,
    required this.pitWindowOpen,
  });

  double speed;
  int gear;
  double throttle;
  double brake;
  int rpm;
  bool drs;
  double ersLevel;
  String ersMode;
  double gLat;
  double gLon;
  double flTemp, frTemp, rlTemp, rrTemp;
  double? s1Time, s2Time, s3Time;
  double bestS1, bestS2, bestS3;
  double currentLapTime;
  double bestLapTime;
  String gapToLeader;
  String trend;
  double maxSpeedLap;
  double avgSpeedLap;
  final double s1Target;
  final double s2Target;
  final double lapTarget;
  double fuelLoad;
  double fuelPerLap;
  int tyreAge;
  String tyreCompound;
  double waterTemp;
  double oilTemp;
  String engineMode;
  bool pitWindowOpen;

  void update(math.Random rng) {
    speed = (speed + rng.nextDouble() * 28 - 14).clamp(80.0, 340.0);
    gear = ((speed / 42) + 1).clamp(1, 8).toInt();
    rpm = ((speed / 340) * 13000 + 2000 + rng.nextDouble() * 600 - 300)
        .clamp(2000.0, 15000.0)
        .toInt();

    final r = rng.nextDouble();
    if (r < 0.45) {
      throttle = (throttle + rng.nextDouble() * 0.14 - 0.04).clamp(0.0, 1.0);
      brake = 0.0;
    } else if (r < 0.6) {
      brake = (brake + rng.nextDouble() * 0.2 - 0.08).clamp(0.0, 1.0);
      throttle = 0.0;
    } else {
      throttle = (throttle + rng.nextDouble() * 0.04 - 0.02).clamp(0.0, 1.0);
      brake = 0.0;
    }

    if (speed > 270 && rng.nextDouble() < 0.04) {
      drs = !drs;
    } else if (speed < 220) {
      drs = false;
    }

    if (ersMode == 'Deploy') {
      ersLevel = (ersLevel - 0.004 + rng.nextDouble() * 0.001).clamp(0.0, 1.0);
      if (ersLevel < 0.08) {
        ersMode = 'Harvest';
      }
    } else if (ersMode == 'Harvest') {
      ersLevel = (ersLevel + 0.003 + rng.nextDouble() * 0.001).clamp(0.0, 1.0);
      if (ersLevel > 0.92) {
        ersMode = 'Deploy';
      }
    }

    gLat = (gLat + rng.nextDouble() * 0.5 - 0.25).clamp(-4.0, 4.0);
    gLon = (gLon + rng.nextDouble() * 0.4 - 0.2).clamp(-5.0, 3.0);

    flTemp = (flTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    frTemp = (frTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    rlTemp = (rlTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    rrTemp = (rrTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);

    waterTemp = (waterTemp + rng.nextDouble() * 0.4 - 0.2).clamp(82.0, 108.0);
    oilTemp = (oilTemp + rng.nextDouble() * 0.5 - 0.25).clamp(98.0, 132.0);

    if (rng.nextDouble() < 0.002) {
      engineMode = switch (engineMode) {
        'Party' => 'Standard',
        'Standard' => 'Conservation',
        _ => 'Party',
      };
    }

    currentLapTime += 0.2;
    if (speed > maxSpeedLap) {
      maxSpeedLap = speed;
    }
    avgSpeedLap = avgSpeedLap * 0.996 + speed * 0.004;

    if (s1Time == null && currentLapTime >= s1Target) {
      s1Time = currentLapTime;
      if (s1Time! < bestS1) {
        bestS1 = s1Time!;
      }
    }
    if (s1Time != null && s2Time == null && currentLapTime >= s2Target) {
      s2Time = currentLapTime - s1Time!;
      if (s2Time! < bestS2) {
        bestS2 = s2Time!;
      }
    }
    if (s2Time != null && s3Time == null && currentLapTime >= lapTarget) {
      s3Time = currentLapTime - s1Time! - s2Time!;
      if (s3Time! < bestS3) {
        bestS3 = s3Time!;
      }
    }

    if (currentLapTime >= lapTarget + 1.5) {
      if (currentLapTime < bestLapTime) {
        bestLapTime = currentLapTime;
      }
      currentLapTime = 0;
      s1Time = null;
      s2Time = null;
      s3Time = null;
      maxSpeedLap = speed;
      tyreAge++;
      fuelLoad = (fuelLoad - fuelPerLap + rng.nextDouble() * 0.1 - 0.05)
          .clamp(0.0, 110.0);
      pitWindowOpen = tyreAge >= 15 && tyreAge <= 35; // typical undercut window in a 60-lap race
      final tr = rng.nextDouble();
      trend = tr < 0.33 ? 'gaining' : tr < 0.66 ? 'losing' : 'stable';
    }
  }

  TelemetrySnapshot toSnapshot() => TelemetrySnapshot(
        speed: speed,
        gear: gear,
        throttle: throttle,
        brake: brake,
        rpm: rpm,
        drs: drs,
        ersLevel: ersLevel,
        ersMode: ersMode,
        gLat: gLat,
        gLon: gLon,
        tyreTemp: {'fl': flTemp, 'fr': frTemp, 'rl': rlTemp, 'rr': rrTemp},
        sectorTimes: [s1Time, s2Time, s3Time],
        bestSectorTimes: [bestS1, bestS2, bestS3],
        currentLapTime: currentLapTime,
        bestLapTime: bestLapTime,
        gapToLeader: gapToLeader,
        trend: trend,
        maxSpeedLap: maxSpeedLap,
        avgSpeedLap: avgSpeedLap,
        fuelLoad: fuelLoad,
        fuelPerLap: fuelPerLap,
        tyreAge: tyreAge,
        tyreCompound: tyreCompound,
        waterTemp: waterTemp,
        oilTemp: oilTemp,
        engineMode: engineMode,
        pitWindowOpen: pitWindowOpen,
      );
}

// ChangeNotifier owned by a provider at TelemetryPage root.
// 200 ms tick matches the ~5 Hz broadcast rate used in real F1 telemetry feeds.
class TelemetrySimulator extends ChangeNotifier {
  TelemetrySimulator() {
    _initDrivers();
    _timer = Timer.periodic(const Duration(milliseconds: 200), _tick);
  }

  late final Map<String, _DriverState> _drivers;
  Timer? _timer;
  final math.Random _rng = math.Random(42);

  TrackConditions _trackConditions = const TrackConditions(
    trackTemp: 48.2,
    airTemp: 28.5,
    humidity: 42.0,
    conditions: 'Dry',
    windSpeed: 12.0,
  );

  void _initDrivers() {
    _drivers = {
      'VER': _DriverState(
        speed: 285,
        gear: 7,
        throttle: 0.92,
        brake: 0.0,
        rpm: 12800,
        drs: true,
        ersLevel: 0.72,
        ersMode: 'Deploy',
        gLat: 1.2,
        gLon: -0.3,
        flTemp: 92,
        frTemp: 94,
        rlTemp: 88,
        rrTemp: 90,
        s1Time: 28.142,
        s2Time: 32.018,
        s3Time: null,
        bestS1: 27.891,
        bestS2: 31.745,
        bestS3: 24.312,
        currentLapTime: 60.16,
        bestLapTime: 84.102,
        gapToLeader: 'LEADER',
        trend: 'stable',
        maxSpeedLap: 320,
        avgSpeedLap: 198,
        s1Target: 28.0,
        s2Target: 60.0,
        lapTarget: 84.0,
        fuelLoad: 78.4,
        fuelPerLap: 2.18,
        tyreAge: 12,
        tyreCompound: 'Medium',
        waterTemp: 94.2,
        oilTemp: 112.5,
        engineMode: 'Party',
        pitWindowOpen: false,
      ),
      'LEC': _DriverState(
        speed: 261,
        gear: 6,
        throttle: 0.78,
        brake: 0.05,
        rpm: 11200,
        drs: false,
        ersLevel: 0.54,
        ersMode: 'Harvest',
        gLat: -0.8,
        gLon: 1.4,
        flTemp: 108,
        frTemp: 112,
        rlTemp: 104,
        rrTemp: 107,
        s1Time: 28.891,
        s2Time: null,
        s3Time: null,
        bestS1: 28.211,
        bestS2: 32.104,
        bestS3: 24.788,
        currentLapTime: 28.891,
        bestLapTime: 85.234,
        gapToLeader: '+2.1s',
        trend: 'losing',
        maxSpeedLap: 316,
        avgSpeedLap: 192,
        s1Target: 29.0,
        s2Target: 62.0,
        lapTarget: 86.0,
        fuelLoad: 71.2,
        fuelPerLap: 2.22,
        tyreAge: 18,
        tyreCompound: 'Soft',
        waterTemp: 97.8,
        oilTemp: 118.1,
        engineMode: 'Standard',
        pitWindowOpen: true,
      ),
      'NOR': _DriverState(
        speed: 312,
        gear: 8,
        throttle: 1.0,
        brake: 0.0,
        rpm: 14100,
        drs: true,
        ersLevel: 0.88,
        ersMode: 'Deploy',
        gLat: 0.1,
        gLon: -1.8,
        flTemp: 76,
        frTemp: 79,
        rlTemp: 74,
        rrTemp: 77,
        s1Time: 28.432,
        s2Time: 31.988,
        s3Time: 24.521,
        bestS1: 28.012,
        bestS2: 31.654,
        bestS3: 24.201,
        currentLapTime: 84.941,
        bestLapTime: 83.867,
        gapToLeader: '+3.8s',
        trend: 'gaining',
        maxSpeedLap: 330,
        avgSpeedLap: 201,
        s1Target: 28.5,
        s2Target: 60.5,
        lapTarget: 85.0,
        fuelLoad: 82.6,
        fuelPerLap: 2.14,
        tyreAge: 8,
        tyreCompound: 'Hard',
        waterTemp: 91.4,
        oilTemp: 109.8,
        engineMode: 'Conservation',
        pitWindowOpen: false,
      ),
    };
  }

  TelemetrySnapshot getSnapshot(String driverId) =>
      (_drivers[driverId] ?? _drivers['VER']!).toSnapshot();

  TrackConditions getTrackConditions() => _trackConditions;

  void _tick(Timer _) {
    for (final s in _drivers.values) {
      s.update(_rng);
    }
    _trackConditions = TrackConditions(
      trackTemp:
          (_trackConditions.trackTemp + _rng.nextDouble() * 0.2 - 0.1).clamp(35.0, 65.0),
      airTemp:
          (_trackConditions.airTemp + _rng.nextDouble() * 0.1 - 0.05).clamp(18.0, 40.0),
      humidity:
          (_trackConditions.humidity + _rng.nextDouble() * 0.2 - 0.1).clamp(20.0, 90.0),
      conditions: _trackConditions.conditions,
      windSpeed:
          (_trackConditions.windSpeed + _rng.nextDouble() * 0.4 - 0.2).clamp(0.0, 40.0),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
