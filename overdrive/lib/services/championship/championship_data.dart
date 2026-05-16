/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_data.dart - Main adaptive data model for championship pages.
##
*/

import 'package:flutter/material.dart';

import 'championship_circuit.dart';
import 'championship_enums.dart';
import 'championship_live_entry.dart';
import 'championship_session.dart';
import 'championship_standing.dart';

@immutable
class ChampionshipData {
  const ChampionshipData({
    required this.id,
    required this.name,
    required this.accentColor,
    required this.state,
    required this.standings,
    required this.replays,
    this.circuit,
    this.weather,
    this.schedule,
    this.nextEvent,
    this.liveGroups,
    this.headline,
  });

  final String id;
  final String name;
  final Color accentColor;
  final ChampionshipState state;
  final List<ChampionshipStandingTable> standings;
  final List<ChampionshipLiveGroup>? liveGroups;
  final ChampionshipCircuit? circuit;
  final ChampionshipWeather? weather;
  final List<ChampionshipSession>? schedule;
  final ChampionshipNextEvent? nextEvent;
  final ChampionshipReplays replays;

  // Optional marketing headline used by the UI without hardcoding by championship.
  final String? headline;
}
