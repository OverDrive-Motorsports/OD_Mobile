/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_widgets_test.dart - Widget tests for championship UI widgets.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/theme/app_theme.dart';
import 'package:overdrive/services/championship/championship_circuit.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_live_entry.dart';
import 'package:overdrive/services/championship/championship_session.dart';
import 'package:overdrive/widgets/championships/championship_icon.dart';
import 'package:overdrive/widgets/championships/championship_replay_btn.dart';
import 'package:overdrive/widgets/championships/championship_schedule.dart';
import 'package:overdrive/widgets/championships/championship_standings_widget.dart';
import 'package:overdrive/widgets/championships/championship_top3.dart';

import '../helpers/test_app.dart';

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

  group('ChampionshipStandingsWidget', () {
    testWidgets('switches between multiple standings sections', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: ChampionshipStandingsWidget(
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

  group('Championship CTA widgets', () {
    testWidgets('ChampionshipReplayBtn delegates taps to the caller', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipReplayBtn(
            replays: const ChampionshipReplays(label: 'Monaco 2026'),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Bibliotheque de replays'));
      await tester.pump();

      expect(tapped, isTrue);
      expect(find.text('Monaco 2026'), findsOneWidget);
    });

    testWidgets(
      'ChampionshipIcon renders asset fallback data and handles taps',
      (WidgetTester tester) async {
        var tapped = false;

        await pumpTestApp(
          tester,
          Scaffold(
            body: ChampionshipIcon(
              name: 'Formula 1',
              subtitle: 'Live',
              logoAsset: 'F1',
              isFavorite: true,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(ChampionshipIcon));
        await tester.pump();

        expect(tapped, isTrue);
        expect(find.textContaining('Formula 1'), findsOneWidget);
        expect(find.text('F1'), findsOneWidget);
        expect(find.text('Live'), findsOneWidget);
      },
    );
  });
}
