/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_item_test.dart - Unit tests for the ReplayItem data model.
 ##
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_circuit.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_standing.dart';
import 'package:overdrive/services/replay/replay_item.dart';

void main() {
  const circuit = ChampionshipCircuit(
    name: 'Bahrain International Circuit',
    location: 'Sakhir',
    lengthKm: 5.412,
    totalLaps: 57,
  );
  const weather = ChampionshipWeather(
    condition: 'Clear',
    trackTempC: 35,
    airTempC: 25,
    rainChancePercent: 0,
  );

  group('ReplayItem', () {
    test('stores all constructor fields', () {
      final sessionDate = DateTime(2024, 3, 2);
      final replay = ReplayItem(
        id: 'replay-1',
        championshipId: 'f1',
        championshipName: 'Formula 1',
        raceName: 'Grand Prix de Bahrein 2024',
        circuit: circuit,
        weather: weather,
        sessionDate: sessionDate,
        durationLabel: '1h 32m',
        sizeLabel: '2.1 GB',
        accentColor: const Color(0xFFE10600),
        videoUrl: 'https://example.com/replay.mp4',
      );

      expect(replay.id, 'replay-1');
      expect(replay.championshipId, 'f1');
      expect(replay.championshipName, 'Formula 1');
      expect(replay.raceName, 'Grand Prix de Bahrein 2024');
      expect(replay.circuit, same(circuit));
      expect(replay.weather, same(weather));
      expect(replay.sessionDate, sessionDate);
      expect(replay.durationLabel, '1h 32m');
      expect(replay.sizeLabel, '2.1 GB');
      expect(replay.accentColor, const Color(0xFFE10600));
      expect(replay.videoUrl, 'https://example.com/replay.mp4');
    });

    test('standings and isDownloaded default to empty/false', () {
      final replay = ReplayItem(
        id: 'replay-2',
        championshipId: 'f1',
        championshipName: 'Formula 1',
        raceName: 'Grand Prix de Monaco 2024',
        circuit: circuit,
        weather: weather,
        sessionDate: DateTime(2024, 5, 26),
        durationLabel: '1h 45m',
        sizeLabel: '2.4 GB',
        accentColor: const Color(0xFF0090FF),
        videoUrl: 'https://example.com/monaco.mp4',
      );

      expect(replay.standings, isEmpty);
      expect(replay.isDownloaded, isFalse);
    });

    test('accepts explicit standings and isDownloaded', () {
      const standings = [
        ChampionshipStandingTable(
          type: StandingType.drivers,
          label: 'Drivers',
          entries: [],
        ),
      ];
      final replay = ReplayItem(
        id: 'replay-3',
        championshipId: 'f1',
        championshipName: 'Formula 1',
        raceName: 'Grand Prix de Bahrein 2024',
        circuit: circuit,
        weather: weather,
        sessionDate: DateTime(2024, 3, 2),
        durationLabel: '1h 32m',
        sizeLabel: '2.1 GB',
        accentColor: const Color(0xFFE10600),
        videoUrl: 'https://example.com/replay.mp4',
        standings: standings,
        isDownloaded: true,
      );

      expect(replay.standings, standings);
      expect(replay.isDownloaded, isTrue);
    });
  });
}
