/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_enums_test.dart - Unit tests for the shared championship enums.
 ##
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_enums.dart';

void main() {
  test('ChampionshipState exposes the expected values', () {
    expect(ChampionshipState.values, [
      ChampionshipState.offSeason,
      ChampionshipState.eventWeekend,
      ChampionshipState.liveSession,
    ]);
  });

  test('SessionStatus exposes the expected values', () {
    expect(SessionStatus.values, [
      SessionStatus.completed,
      SessionStatus.live,
      SessionStatus.upcoming,
    ]);
  });

  test('StandingType exposes the expected values', () {
    expect(StandingType.values, [
      StandingType.drivers,
      StandingType.teams,
      StandingType.manufacturers,
    ]);
  });
}
