/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_live_entry_test.dart - Unit tests for live timing models.
 ##
 */

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_live_entry.dart';

void main() {
  group('ChampionshipLiveEntry', () {
    test('stores all constructor fields', () {
      const entry = ChampionshipLiveEntry(
        position: 1,
        name: 'Max Verstappen',
        teamName: 'Red Bull Racing',
        gap: 'Leader',
        lap: 42,
        tyreCompound: 'Soft',
        teamColor: Color(0xFF1E41FF),
      );

      expect(entry.position, 1);
      expect(entry.name, 'Max Verstappen');
      expect(entry.teamName, 'Red Bull Racing');
      expect(entry.gap, 'Leader');
      expect(entry.lap, 42);
      expect(entry.tyreCompound, 'Soft');
      expect(entry.teamColor, const Color(0xFF1E41FF));
    });

    test('optional fields default to null when omitted', () {
      const entry = ChampionshipLiveEntry(
        position: 5,
        name: 'Driver',
        teamName: 'Team',
        gap: '+1.234',
        lap: 10,
      );

      expect(entry.tyreCompound, isNull);
      expect(entry.teamColor, isNull);
    });
  });

  group('ChampionshipLiveGroup', () {
    test('stores label and entries', () {
      const entries = [
        ChampionshipLiveEntry(
          position: 1,
          name: 'Max Verstappen',
          teamName: 'Red Bull Racing',
          gap: 'Leader',
          lap: 42,
        ),
      ];
      const group = ChampionshipLiveGroup(label: 'Top 10', entries: entries);

      expect(group.label, 'Top 10');
      expect(group.entries, hasLength(1));
      expect(group.entries.first.name, 'Max Verstappen');
    });
  });
}
