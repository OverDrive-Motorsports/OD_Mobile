/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_standing_test.dart - Unit tests for championship standings models.
 ##
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_standing.dart';

void main() {
  group('ChampionshipStandingEntry', () {
    test('stores all constructor fields', () {
      const entry = ChampionshipStandingEntry(
        position: 1,
        name: 'Max Verstappen',
        points: 400,
        teamName: 'Red Bull Racing',
      );

      expect(entry.position, 1);
      expect(entry.name, 'Max Verstappen');
      expect(entry.points, 400);
      expect(entry.teamName, 'Red Bull Racing');
    });

    test('teamName defaults to null when omitted', () {
      const entry = ChampionshipStandingEntry(
        position: 2,
        name: 'Lando Norris',
        points: 350,
      );

      expect(entry.teamName, isNull);
    });
  });

  group('ChampionshipStandingTable', () {
    test('stores type, label and entries', () {
      const entries = [
        ChampionshipStandingEntry(position: 1, name: 'Max Verstappen', points: 400),
        ChampionshipStandingEntry(position: 2, name: 'Lando Norris', points: 350),
      ];
      const table = ChampionshipStandingTable(
        type: StandingType.drivers,
        label: 'Drivers',
        entries: entries,
      );

      expect(table.type, StandingType.drivers);
      expect(table.label, 'Drivers');
      expect(table.entries, hasLength(2));
      expect(table.entries.first.name, 'Max Verstappen');
    });

    test('accepts an empty entries list', () {
      const table = ChampionshipStandingTable(
        type: StandingType.teams,
        label: 'Teams',
        entries: [],
      );

      expect(table.entries, isEmpty);
    });
  });
}
