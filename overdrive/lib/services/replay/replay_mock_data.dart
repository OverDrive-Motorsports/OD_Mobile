/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_mock_data.dart - Mock replay catalog used by the replay library page.
 ##
 */

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../championship/championship_circuit.dart';
import '../championship/championship_mock_data.dart';
import 'replay_item.dart';

const String _kSampleVideoUrl =
    'https://www.youtube.com/embed/82XnMb4euLI?si=phkMUHZgRj1NUx2E';

final List<ReplayItem> replayCatalogMock = <ReplayItem>[
  ReplayItem(
    id: 'f1_bahrein_2024',
    championshipId: 'formula_1',
    championshipName: 'Formula 1',
    raceName: 'Grand Prix de Bahrein 2024',
    circuit: ChampionshipCircuit(
      name: 'Bahrain International Circuit',
      location: 'Sakhir, Bahrein',
      lengthKm: 5.412,
      totalLaps: 57,
    ),
    weather: ChampionshipWeather(
      condition: 'Degage',
      trackTempC: 33,
      airTempC: 25,
      rainChancePercent: 0,
    ),
    sessionDate: DateTime(2024, 3, 2),
    durationLabel: '1h 31min',
    sizeLabel: '1.2 Go',
    accentColor: Color(0xFFE80000),
    videoUrl: _kSampleVideoUrl,
    standings: championshipFormula1Mock.standings,
    isDownloaded: true,
  ),
];
