/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_session_test.dart - Unit tests for weekend schedule models.
 ##
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_session.dart';

void main() {
  group('ChampionshipSession', () {
    test('stores all constructor fields', () {
      final scheduledAt = DateTime(2026, 5, 22, 14, 30);
      final session = ChampionshipSession(
        name: 'Free Practice 1',
        scheduledAt: scheduledAt,
        status: SessionStatus.upcoming,
      );

      expect(session.name, 'Free Practice 1');
      expect(session.scheduledAt, scheduledAt);
      expect(session.status, SessionStatus.upcoming);
    });

    test('supports each SessionStatus value', () {
      for (final status in SessionStatus.values) {
        final session = ChampionshipSession(
          name: 'Session',
          scheduledAt: DateTime(2026),
          status: status,
        );

        expect(session.status, status);
      }
    });
  });
}
