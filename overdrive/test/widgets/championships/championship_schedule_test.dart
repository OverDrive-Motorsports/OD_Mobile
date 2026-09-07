/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_schedule_test.dart - Widget tests for ChampionshipSchedule.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_session.dart';
import 'package:overdrive/widgets/championships/championship_schedule.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipSchedule', () {
    testWidgets('renders session statuses and opens the session modal', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 5, 19, 12);

      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipSchedule(
            now: now,
            sessions: <ChampionshipSession>[
              ChampionshipSession(
                name: 'Practice',
                scheduledAt: now.subtract(const Duration(hours: 2)),
                status: SessionStatus.completed,
              ),
              ChampionshipSession(
                name: 'Qualifying',
                scheduledAt: now.add(const Duration(hours: 1)),
                status: SessionStatus.upcoming,
              ),
              ChampionshipSession(
                name: 'Race',
                scheduledAt: now.add(const Duration(days: 1)),
                status: SessionStatus.upcoming,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Programme'), findsOneWidget);
      expect(find.text('Termine'), findsOneWidget);
      expect(find.text('PROCHAIN'), findsOneWidget);

      await tester.tap(find.text('Qualifying'));
      await tester.pumpAndSettle();

      expect(find.text('Qualifying'), findsWidgets);
    });
  });
}
