/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_live_entry.dart - Live timing models for championship pages.
##
*/

import 'package:flutter/foundation.dart';

@immutable
class ChampionshipLiveGroup {
  const ChampionshipLiveGroup({required this.label, required this.entries});

  final String label;
  final List<ChampionshipLiveEntry> entries;
}

@immutable
class ChampionshipLiveEntry {
  const ChampionshipLiveEntry({
    required this.position,
    required this.name,
    required this.teamName,
    required this.gap,
    required this.lap,
    this.tyreCompound,
  });

  final int position;
  final String name;
  final String teamName;
  final String gap;
  final int lap;
  final String? tyreCompound;
}
