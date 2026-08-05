/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_item.dart - Data model for a downloadable race replay.
 ##
 */

import 'package:flutter/material.dart';

import '../championship/championship_circuit.dart';
import '../championship/championship_standing.dart';

@immutable
class ReplayItem {
  const ReplayItem({
    required this.id,
    required this.championshipId,
    required this.championshipName,
    required this.raceName,
    required this.circuit,
    required this.weather,
    required this.sessionDate,
    required this.durationLabel,
    required this.sizeLabel,
    required this.accentColor,
    required this.videoUrl,
    this.standings = const <ChampionshipStandingTable>[],
    this.isDownloaded = false,
  });

  final String id;
  final String championshipId;
  final String championshipName;
  final String raceName;
  final ChampionshipCircuit circuit;
  final ChampionshipWeather weather;
  final DateTime sessionDate;
  final String durationLabel;
  final String sizeLabel;
  final Color accentColor;
  final String videoUrl;

  /// Championship standings as they stood before this race.
  final List<ChampionshipStandingTable> standings;
  final bool isDownloaded;
}
