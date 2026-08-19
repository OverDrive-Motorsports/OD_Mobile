/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_standings_test.dart - Widget tests for ChampionshipStandings.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/championships/championship_standings.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipStandings', () {
    testWidgets('switches between multiple standings sections', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: ChampionshipStandings(
            title: 'Standings',
            sections: <ChampionshipStandingsSection>[
              ChampionshipStandingsSection(
                label: 'Drivers',
                entries: <ChampionshipStandingEntry>[
                  ChampionshipStandingEntry(
                    position: 1,
                    title: 'Driver A',
                    trailingValue: '100',
                  ),
                ],
              ),
              ChampionshipStandingsSection(
                label: 'Teams',
                entries: <ChampionshipStandingEntry>[
                  ChampionshipStandingEntry(
                    position: 1,
                    title: 'Team B',
                    trailingValue: '200',
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Driver A'), findsOneWidget);
      expect(find.text('Team B'), findsNothing);

      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();

      expect(find.text('Team B'), findsOneWidget);
    });
  });
}
