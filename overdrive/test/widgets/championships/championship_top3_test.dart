/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_top3_test.dart - Widget tests for ChampionshipTop3.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/theme/app_theme.dart';
import 'package:overdrive/services/championship/championship_live_entry.dart';
import 'package:overdrive/widgets/championships/championship_top3.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipTop3', () {
    testWidgets('renders the first three live entries with rank labels', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipTop3(
            label: 'Hypercar',
            accentColor: AppColors.gold,
            entries: const <ChampionshipLiveEntry>[
              ChampionshipLiveEntry(
                position: 1,
                name: 'Driver One',
                teamName: 'Team A',
                gap: 'Leader',
                lap: 12,
              ),
              ChampionshipLiveEntry(
                position: 2,
                name: 'Driver Two',
                teamName: 'Team B',
                gap: '+1.2',
                lap: 12,
              ),
              ChampionshipLiveEntry(
                position: 3,
                name: 'Driver Three',
                teamName: 'Team C',
                gap: '+2.4',
                lap: 12,
              ),
            ],
          ),
        ),
      );

      expect(find.text('HYPERCAR'), findsOneWidget);
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('Driver One'), findsOneWidget);
      expect(find.text('Driver Three'), findsOneWidget);
    });
  });
}
