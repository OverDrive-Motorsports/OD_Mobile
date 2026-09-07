/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_circuit_test.dart - Unit tests for circuit/event side models.
 ##
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_circuit.dart';

void main() {
  group('ChampionshipCircuit', () {
    test('stores all constructor fields', () {
      const circuit = ChampionshipCircuit(
        name: 'Circuit de Monaco',
        location: 'Monte Carlo',
        lengthKm: 3.337,
        totalLaps: 78,
      );

      expect(circuit.name, 'Circuit de Monaco');
      expect(circuit.location, 'Monte Carlo');
      expect(circuit.lengthKm, 3.337);
      expect(circuit.totalLaps, 78);
    });
  });

  group('ChampionshipWeather', () {
    test('stores all constructor fields', () {
      const weather = ChampionshipWeather(
        condition: 'Sunny',
        trackTempC: 42,
        airTempC: 28,
        rainChancePercent: 5,
      );

      expect(weather.condition, 'Sunny');
      expect(weather.trackTempC, 42);
      expect(weather.airTempC, 28);
      expect(weather.rainChancePercent, 5);
    });
  });

  group('ChampionshipNextEvent', () {
    test('stores all constructor fields', () {
      final startsAt = DateTime(2026, 5, 24, 13, 0);
      final event = ChampionshipNextEvent(
        name: 'Monaco Grand Prix',
        location: 'Monaco',
        startsAt: startsAt,
      );

      expect(event.name, 'Monaco Grand Prix');
      expect(event.location, 'Monaco');
      expect(event.startsAt, startsAt);
    });
  });

  group('ChampionshipReplays', () {
    test('stores the label field', () {
      const replays = ChampionshipReplays(label: '12 replays available');

      expect(replays.label, '12 replays available');
    });
  });
}
