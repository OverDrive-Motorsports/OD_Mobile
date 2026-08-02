/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_standing.dart - Championship standings models.
##
*/

import 'package:flutter/foundation.dart';

import 'championship_enums.dart';

@immutable
class ChampionshipStandingTable {
  const ChampionshipStandingTable({
    required this.type,
    required this.label,
    required this.entries,
  });

  final StandingType type;
  final String label;
  final List<ChampionshipStandingEntry> entries;
}

@immutable
class ChampionshipStandingEntry {
  const ChampionshipStandingEntry({
    required this.position,
    required this.name,
    required this.points,
    this.teamName,
  });

  final int position;
  final String name;
  final int points;
  final String? teamName;
}
