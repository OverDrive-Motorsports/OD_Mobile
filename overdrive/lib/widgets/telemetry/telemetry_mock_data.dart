/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [telemetry_mock_data.dart] - Simulated F1 telemetry data models and a 5 Hz live simulator for development and testing.
 ##
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

// ── Value-object models — immutable data carriers consumed by telemetry widgets ──

/// One completed lap of data for the lap-history chart.
class LapData {
  const LapData({required this.lap, required this.time, required this.gap});
  final int lap;
  final double time; // lap time in seconds
  final double gap; // gap to leader at end of that lap (0 = leader)
}

/// One completed lap for the position-history chart.
class PositionData {
  const PositionData({required this.lap, required this.position});
  final int lap;
  final int position; // 1 = lead, 2 = second, 3 = third
}

/// One hour of weather forecast data.
class HourlyForecast {
  const HourlyForecast({
    required this.hour,
    required this.condition,
    required this.tempC,
    required this.precipChance,
    required this.windKph,
  });

  final String hour; // e.g. '14:00'
  final String
  condition; // 'sunny' | 'partly_cloudy' | 'cloudy' | 'rain' | 'storm'
  final double tempC;
  final double precipChance; // 0.0–1.0
  final double windKph;
}

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

// ── TelemetrySnapshot — full driver state emitted every simulator tick ────

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
    required this.tyrePressure,
    required this.tyreWear,
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
    required this.fuelTargetPerLap,
    required this.tyreAge,
    required this.tyreCompound,
    required this.waterTemp,
    required this.oilTemp,
    required this.hydraulicTemp,
    required this.mgukTemp,
    required this.esTemp,
    required this.turboBoost,
    required this.engineMode,
    required this.pitWindowOpen,
    required this.lapNumber,
    required this.penaltySeconds,
    required this.trackLimitWarnings,
    required this.blueFlagWarning,
    required this.frontWingDamage,
    required this.rearWingDamage,
    required this.floorDamage,
    required this.gearboxDamage,
    required this.suspensionDamage,
    required this.engineDamage,
  });

  static const int totalLaps = 57;

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
  final Map<String, double> tyreTemp; // fl, fr, rl, rr — °C
  final Map<String, double> tyrePressure; // fl, fr, rl, rr — PSI
  final Map<String, double> tyreWear; // fl, fr, rl, rr — 0…1
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
  final double fuelTargetPerLap;
  final int tyreAge;
  final String tyreCompound;
  final double waterTemp; // °C  82–108
  final double oilTemp; // °C  98–132
  final double hydraulicTemp; // °C 38–62
  final double mgukTemp; // MGU-K °C  55–115
  final double esTemp; // Energy Store °C  20–55
  final double turboBoost; // 0…1 (fraction of max boost)
  final String engineMode; // 'Party' | 'Standard' | 'Conservation'
  final bool pitWindowOpen;
  final int lapNumber;
  // Penalties
  final int penaltySeconds; // 0 / 5 / 10
  final int trackLimitWarnings; // 0–3 (3 = automatic penalty next)
  final bool blueFlagWarning;
  // Damage 0…1
  final double frontWingDamage;
  final double rearWingDamage;
  final double floorDamage;
  final double gearboxDamage;
  final double suspensionDamage;
  final double engineDamage;

  double get fuelDeltaPerLap => fuelPerLap - fuelTargetPerLap;
  int get lapsRemaining => fuelPerLap > 0 ? (fuelLoad / fuelPerLap).floor() : 0;
  bool get hasPenalty => penaltySeconds > 0;
  bool get hasAnyDamage =>
      frontWingDamage > 0.05 ||
      rearWingDamage > 0.05 ||
      floorDamage > 0.05 ||
      gearboxDamage > 0.05 ||
      suspensionDamage > 0.05 ||
      engineDamage > 0.05;
}

// ── Static driver catalogue — single source of truth for driver identifiers ──

// Provides a fixed list of mock drivers; using a private constructor prevents instantiation.
class TelemetryMockData {
  TelemetryMockData._();

  static const List<Map<String, dynamic>> drivers = [
    {
      'id': 'VER',
      'name': 'Verstappen',
      'team': 'Red Bull Racing',
      'position': 1,
    },
    {'id': 'LEC', 'name': 'Leclerc', 'team': 'Ferrari', 'position': 2},
    {'id': 'NOR', 'name': 'Norris', 'team': 'McLaren', 'position': 3},
  ];

  static Map<String, dynamic> driverById(String id) =>
      drivers.firstWhere((d) => d['id'] == id, orElse: () => drivers.first);
}

// ── _DriverState — mutable per-driver state updated every simulator tick ──

// Encapsulates all mutable fields for one driver; kept private so the public API
// only surfaces immutable TelemetrySnapshot objects.
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
    required this.flPressure,
    required this.frPressure,
    required this.rlPressure,
    required this.rrPressure,
    required this.flWear,
    required this.frWear,
    required this.rlWear,
    required this.rrWear,
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
    required this.fuelTargetPerLap,
    required this.tyreAge,
    required this.tyreCompound,
    required this.waterTemp,
    required this.oilTemp,
    required this.hydraulicTemp,
    required this.mgukTemp,
    required this.esTemp,
    required this.turboBoost,
    required this.engineMode,
    required this.pitWindowOpen,
    required this.lapNumber,
    required this.penaltySeconds,
    required this.trackLimitWarnings,
    required this.blueFlagWarning,
    required this.frontWingDamage,
    required this.rearWingDamage,
    required this.floorDamage,
    required this.gearboxDamage,
    required this.suspensionDamage,
    required this.engineDamage,
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
  // Tyre temps
  double flTemp, frTemp, rlTemp, rrTemp;
  // Tyre pressures (PSI)
  double flPressure, frPressure, rlPressure, rrPressure;
  // Tyre wear (0-1)
  double flWear, frWear, rlWear, rrWear;
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
  final double fuelTargetPerLap;
  int tyreAge;
  String tyreCompound;
  double waterTemp;
  double oilTemp;
  double hydraulicTemp;
  double mgukTemp;
  double esTemp;
  double turboBoost;
  String engineMode;
  bool pitWindowOpen;
  int lapNumber;
  int penaltySeconds;
  int trackLimitWarnings;
  bool blueFlagWarning;
  double frontWingDamage;
  double rearWingDamage;
  double floorDamage;
  double gearboxDamage;
  double suspensionDamage;
  double engineDamage;

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
      if (ersLevel < 0.08) ersMode = 'Harvest';
    } else if (ersMode == 'Harvest') {
      ersLevel = (ersLevel + 0.003 + rng.nextDouble() * 0.001).clamp(0.0, 1.0);
      if (ersLevel > 0.92) ersMode = 'Deploy';
    }

    gLat = (gLat + rng.nextDouble() * 0.5 - 0.25).clamp(-4.0, 4.0);
    gLon = (gLon + rng.nextDouble() * 0.4 - 0.2).clamp(-5.0, 3.0);

    // Tyre temps
    flTemp = (flTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    frTemp = (frTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    rlTemp = (rlTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);
    rrTemp = (rrTemp + rng.nextDouble() * 0.7 - 0.35).clamp(40.0, 130.0);

    // Tyre pressures — slow drift ±0.05 PSI
    flPressure = (flPressure + rng.nextDouble() * 0.1 - 0.05).clamp(19.0, 28.0);
    frPressure = (frPressure + rng.nextDouble() * 0.1 - 0.05).clamp(19.0, 28.0);
    rlPressure = (rlPressure + rng.nextDouble() * 0.1 - 0.05).clamp(19.0, 28.0);
    rrPressure = (rrPressure + rng.nextDouble() * 0.1 - 0.05).clamp(19.0, 28.0);

    // Tyre wear — very slow increase each tick
    flWear = (flWear + 0.00008 + rng.nextDouble() * 0.00004).clamp(0.0, 1.0);
    frWear = (frWear + 0.00009 + rng.nextDouble() * 0.00004).clamp(0.0, 1.0);
    rlWear = (rlWear + 0.00007 + rng.nextDouble() * 0.00003).clamp(0.0, 1.0);
    rrWear = (rrWear + 0.00007 + rng.nextDouble() * 0.00003).clamp(0.0, 1.0);

    // Engine temps
    waterTemp = (waterTemp + rng.nextDouble() * 0.4 - 0.2).clamp(82.0, 108.0);
    oilTemp = (oilTemp + rng.nextDouble() * 0.5 - 0.25).clamp(98.0, 132.0);
    hydraulicTemp = (hydraulicTemp + rng.nextDouble() * 0.3 - 0.15).clamp(
      38.0,
      62.0,
    );
    mgukTemp = (mgukTemp + rng.nextDouble() * 0.6 - 0.3).clamp(55.0, 115.0);
    esTemp = (esTemp + rng.nextDouble() * 0.3 - 0.15).clamp(20.0, 55.0);
    turboBoost = (turboBoost + rng.nextDouble() * 0.02 - 0.01).clamp(0.0, 1.0);

    if (rng.nextDouble() < 0.002) {
      engineMode = switch (engineMode) {
        'Party' => 'Standard',
        'Standard' => 'Conservation',
        _ => 'Party',
      };
    }

    currentLapTime += 0.2;
    if (speed > maxSpeedLap) maxSpeedLap = speed;
    avgSpeedLap = avgSpeedLap * 0.996 + speed * 0.004;

    if (s1Time == null && currentLapTime >= s1Target) {
      s1Time = currentLapTime;
      if (s1Time! < bestS1) bestS1 = s1Time!;
    }
    if (s1Time != null && s2Time == null && currentLapTime >= s2Target) {
      s2Time = currentLapTime - s1Time!;
      if (s2Time! < bestS2) bestS2 = s2Time!;
    }
    if (s2Time != null && s3Time == null && currentLapTime >= lapTarget) {
      s3Time = currentLapTime - s1Time! - s2Time!;
      if (s3Time! < bestS3) bestS3 = s3Time!;
    }

    if (currentLapTime >= lapTarget + 1.5) {
      if (currentLapTime < bestLapTime) bestLapTime = currentLapTime;
      currentLapTime = 0;
      s1Time = null;
      s2Time = null;
      s3Time = null;
      maxSpeedLap = speed;
      tyreAge++;
      lapNumber = (lapNumber + 1).clamp(1, TelemetrySnapshot.totalLaps);
      fuelLoad = (fuelLoad - fuelPerLap + rng.nextDouble() * 0.1 - 0.05).clamp(
        0.0,
        110.0,
      );
      fuelPerLap = (fuelPerLap + rng.nextDouble() * 0.04 - 0.02).clamp(
        fuelTargetPerLap - 0.15,
        fuelTargetPerLap + 0.20,
      );
      pitWindowOpen = tyreAge >= 15 && tyreAge <= 35;
      final tr = rng.nextDouble();
      trend = tr < 0.33
          ? 'gaining'
          : tr < 0.66
          ? 'losing'
          : 'stable';

      // Rare damage spikes on lap end
      if (rng.nextDouble() < 0.05) {
        frontWingDamage = (frontWingDamage + rng.nextDouble() * 0.04).clamp(
          0.0,
          1.0,
        );
      }
      floorDamage = (floorDamage + 0.001).clamp(0.0, 1.0);
      gearboxDamage = (gearboxDamage + 0.0005).clamp(0.0, 1.0);
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
    tyrePressure: {
      'fl': flPressure,
      'fr': frPressure,
      'rl': rlPressure,
      'rr': rrPressure,
    },
    tyreWear: {'fl': flWear, 'fr': frWear, 'rl': rlWear, 'rr': rrWear},
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
    fuelTargetPerLap: fuelTargetPerLap,
    tyreAge: tyreAge,
    tyreCompound: tyreCompound,
    waterTemp: waterTemp,
    oilTemp: oilTemp,
    hydraulicTemp: hydraulicTemp,
    mgukTemp: mgukTemp,
    esTemp: esTemp,
    turboBoost: turboBoost,
    engineMode: engineMode,
    pitWindowOpen: pitWindowOpen,
    lapNumber: lapNumber,
    penaltySeconds: penaltySeconds,
    trackLimitWarnings: trackLimitWarnings,
    blueFlagWarning: blueFlagWarning,
    frontWingDamage: frontWingDamage,
    rearWingDamage: rearWingDamage,
    floorDamage: floorDamage,
    gearboxDamage: gearboxDamage,
    suspensionDamage: suspensionDamage,
    engineDamage: engineDamage,
  );
}

// ── TelemetrySimulator — live data engine driving all telemetry widgets ───

// ChangeNotifier owned by a provider at TelemetryPage root.
// 200 ms tick matches the ~5 Hz broadcast rate used in real F1 telemetry feeds.
class TelemetrySimulator extends ChangeNotifier {
  TelemetrySimulator() {
    _initDrivers();
    _initHistory();
    _initPositionHistory();
    _timer = Timer.periodic(const Duration(milliseconds: 200), _tick);
  }

  late final Map<String, _DriverState> _drivers;
  late final Map<String, List<LapData>> _lapHistory;
  late final Map<String, List<PositionData>> _positionHistory;
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
        flPressure: 23.5,
        frPressure: 23.2,
        rlPressure: 22.8,
        rrPressure: 22.5,
        flWear: 0.12,
        frWear: 0.14,
        rlWear: 0.10,
        rrWear: 0.11,
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
        fuelTargetPerLap: 2.15,
        tyreAge: 12,
        tyreCompound: 'Medium',
        waterTemp: 94.2,
        oilTemp: 112.5,
        hydraulicTemp: 48.2,
        mgukTemp: 78.5,
        esTemp: 38.2,
        turboBoost: 0.82,
        engineMode: 'Party',
        pitWindowOpen: false,
        lapNumber: 23,
        penaltySeconds: 0,
        trackLimitWarnings: 1,
        blueFlagWarning: false,
        frontWingDamage: 0.08,
        rearWingDamage: 0.02,
        floorDamage: 0.05,
        gearboxDamage: 0.03,
        suspensionDamage: 0.04,
        engineDamage: 0.01,
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
        flPressure: 24.1,
        frPressure: 23.8,
        rlPressure: 23.2,
        rrPressure: 22.9,
        flWear: 0.28,
        frWear: 0.31,
        rlWear: 0.22,
        rrWear: 0.25,
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
        fuelTargetPerLap: 2.18,
        tyreAge: 18,
        tyreCompound: 'Soft',
        waterTemp: 97.8,
        oilTemp: 118.1,
        hydraulicTemp: 51.3,
        mgukTemp: 85.2,
        esTemp: 42.1,
        turboBoost: 0.71,
        engineMode: 'Standard',
        pitWindowOpen: true,
        lapNumber: 21,
        penaltySeconds: 5,
        trackLimitWarnings: 2,
        blueFlagWarning: false,
        frontWingDamage: 0.35,
        rearWingDamage: 0.05,
        floorDamage: 0.18,
        gearboxDamage: 0.08,
        suspensionDamage: 0.12,
        engineDamage: 0.02,
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
        flPressure: 22.8,
        frPressure: 22.5,
        rlPressure: 22.1,
        rrPressure: 21.8,
        flWear: 0.06,
        frWear: 0.07,
        rlWear: 0.05,
        rrWear: 0.06,
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
        fuelTargetPerLap: 2.15,
        tyreAge: 8,
        tyreCompound: 'Hard',
        waterTemp: 91.4,
        oilTemp: 109.8,
        hydraulicTemp: 45.8,
        mgukTemp: 72.3,
        esTemp: 35.8,
        turboBoost: 0.88,
        engineMode: 'Conservation',
        pitWindowOpen: false,
        lapNumber: 25,
        penaltySeconds: 0,
        trackLimitWarnings: 0,
        blueFlagWarning: true,
        frontWingDamage: 0.02,
        rearWingDamage: 0.01,
        floorDamage: 0.03,
        gearboxDamage: 0.01,
        suspensionDamage: 0.02,
        engineDamage: 0.00,
      ),
    };
  }

  void _initHistory() {
    final rng = math.Random(7); // fixed seed for reproducible history
    double lecGap = 1.35;
    double norGap = 3.05;

    _lapHistory = {
      'VER': List.generate(22, (i) {
        final t = 84.05 + rng.nextDouble() * 0.55 - 0.25;
        return LapData(lap: i + 1, time: t, gap: 0);
      }),
      'LEC': List.generate(20, (i) {
        final t = 85.10 + rng.nextDouble() * 0.75 - 0.35;
        lecGap = (lecGap + rng.nextDouble() * 0.22 - 0.06).clamp(0.5, 6.0);
        return LapData(lap: i + 1, time: t, gap: lecGap);
      }),
      'NOR': List.generate(24, (i) {
        final t = 84.15 + rng.nextDouble() * 0.65 - 0.30;
        norGap = (norGap + rng.nextDouble() * 0.28 - 0.14).clamp(1.0, 9.0);
        return LapData(lap: i + 1, time: t, gap: norGap);
      }),
    };
  }

  void _initPositionHistory() {
    final ver = <PositionData>[];
    final lec = <PositionData>[];
    final nor = <PositionData>[];

    for (var lap = 1; lap <= TelemetrySnapshot.totalLaps; lap++) {
      int verPos, lecPos, norPos;
      // L1-11: VER P1 LEC P2 NOR P3; L12-15: VER pits → LEC leads; L16-17: VER undercuts to P1; L18-25: NOR P2; L26-57: LEC P2.
      if (lap <= 11) {
        verPos = 1;
        lecPos = 2;
        norPos = 3;
      } else if (lap <= 15) {
        verPos = 2;
        lecPos = 1;
        norPos = 3;
      } else if (lap <= 17) {
        verPos = 1;
        lecPos = 2;
        norPos = 3;
      } else if (lap <= 25) {
        verPos = 1;
        lecPos = 3;
        norPos = 2;
      } else {
        verPos = 1;
        lecPos = 2;
        norPos = 3;
      }
      ver.add(PositionData(lap: lap, position: verPos));
      lec.add(PositionData(lap: lap, position: lecPos));
      nor.add(PositionData(lap: lap, position: norPos));
    }

    _positionHistory = {'VER': ver, 'LEC': lec, 'NOR': nor};
  }

  List<LapData> getLapHistory(String driverId) =>
      List.unmodifiable(_lapHistory[driverId] ?? const []);

  List<PositionData> getPositionHistory(String driverId) =>
      List.unmodifiable(_positionHistory[driverId] ?? const []);

  static const List<HourlyForecast> _kForecast = [
    HourlyForecast(
      hour: '14:00',
      condition: 'sunny',
      tempC: 32,
      precipChance: 0.05,
      windKph: 12,
    ),
    HourlyForecast(
      hour: '15:00',
      condition: 'partly_cloudy',
      tempC: 31,
      precipChance: 0.15,
      windKph: 14,
    ),
    HourlyForecast(
      hour: '16:00',
      condition: 'partly_cloudy',
      tempC: 30,
      precipChance: 0.28,
      windKph: 18,
    ),
    HourlyForecast(
      hour: '17:00',
      condition: 'cloudy',
      tempC: 29,
      precipChance: 0.45,
      windKph: 23,
    ),
    HourlyForecast(
      hour: '18:00',
      condition: 'rain',
      tempC: 27,
      precipChance: 0.68,
      windKph: 29,
    ),
    HourlyForecast(
      hour: '19:00',
      condition: 'rain',
      tempC: 26,
      precipChance: 0.82,
      windKph: 34,
    ),
    HourlyForecast(
      hour: '20:00',
      condition: 'storm',
      tempC: 25,
      precipChance: 0.93,
      windKph: 42,
    ),
    HourlyForecast(
      hour: '21:00',
      condition: 'cloudy',
      tempC: 27,
      precipChance: 0.38,
      windKph: 26,
    ),
  ];

  List<HourlyForecast> getWeatherForecast() => List.unmodifiable(_kForecast);

  TelemetrySnapshot getSnapshot(String driverId) =>
      (_drivers[driverId] ?? _drivers['VER']!).toSnapshot();

  TrackConditions getTrackConditions() => _trackConditions;

  void _tick(Timer _) {
    for (final s in _drivers.values) {
      s.update(_rng);
    }
    _trackConditions = TrackConditions(
      trackTemp: (_trackConditions.trackTemp + _rng.nextDouble() * 0.2 - 0.1)
          .clamp(35.0, 65.0),
      airTemp: (_trackConditions.airTemp + _rng.nextDouble() * 0.1 - 0.05)
          .clamp(18.0, 40.0),
      humidity: (_trackConditions.humidity + _rng.nextDouble() * 0.2 - 0.1)
          .clamp(20.0, 90.0),
      conditions: _trackConditions.conditions,
      windSpeed: (_trackConditions.windSpeed + _rng.nextDouble() * 0.4 - 0.2)
          .clamp(0.0, 40.0),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
