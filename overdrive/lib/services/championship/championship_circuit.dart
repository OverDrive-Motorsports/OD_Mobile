/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_circuit.dart - Circuit and event side models.
##
*/

import 'package:flutter/foundation.dart';

@immutable
class ChampionshipCircuit {
  const ChampionshipCircuit({
    required this.name,
    required this.location,
    required this.lengthKm,
    required this.totalLaps,
  });

  final String name;
  final String location;
  final double lengthKm;
  final int totalLaps;
}

@immutable
class ChampionshipWeather {
  const ChampionshipWeather({
    required this.condition,
    required this.trackTempC,
    required this.airTempC,
    required this.rainChancePercent,
  });

  final String condition;
  final int trackTempC;
  final int airTempC;
  final int rainChancePercent;
}

@immutable
class ChampionshipNextEvent {
  const ChampionshipNextEvent({
    required this.name,
    required this.location,
    required this.startsAt,
  });

  final String name;
  final String location;
  final DateTime startsAt;
}

@immutable
class ChampionshipReplays {
  const ChampionshipReplays({required this.label});

  final String label;
}
