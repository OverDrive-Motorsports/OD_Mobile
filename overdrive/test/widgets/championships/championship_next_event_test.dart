/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_next_event_test.dart - Widget tests for ChampionshipNextEventCard.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_circuit.dart';
import 'package:overdrive/widgets/championships/championship_next_event.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipNextEventCard', () {
    testWidgets('renders event name, location, and countdown', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 1, 1, 0, 0);
      final nextEvent = ChampionshipNextEvent(
        name: 'Monaco Grand Prix',
        location: 'Monte Carlo, Monaco',
        startsAt: now.add(
          const Duration(days: 2, hours: 3, minutes: 15),
        ),
      );

      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipNextEventCard(nextEvent: nextEvent, now: now),
        ),
      );

      expect(find.text('PROCHAIN EVENT'), findsOneWidget);
      expect(find.text('Monaco Grand Prix'), findsOneWidget);
      expect(find.text('Monte Carlo, Monaco'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('JOURS'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('HEURES'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('MIN'), findsOneWidget);
    });

    testWidgets('clamps a past event to a zero countdown', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 1, 1, 0, 0);
      final nextEvent = ChampionshipNextEvent(
        name: 'Past Event',
        location: 'Nowhere',
        startsAt: now.subtract(const Duration(days: 1)),
      );

      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipNextEventCard(nextEvent: nextEvent, now: now),
        ),
      );

      expect(find.text('0'), findsNWidgets(3));
    });
  });
}
