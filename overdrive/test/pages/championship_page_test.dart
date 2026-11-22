/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_page_test.dart - Widget tests for ChampionshipPage.
 ##
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/championship/championship_data_loader.dart';
import 'package:overdrive/pages/championship/championship_page.dart';
import 'package:overdrive/services/championship/championship_data.dart';
import 'package:overdrive/services/championship/championship_enums.dart';
import 'package:overdrive/services/championship/championship_mock_data.dart';

import '../helpers/test_app.dart';

typedef ChampionshipLoadHandler =
    Future<ChampionshipData> Function(String championshipCode);

class FakeChampionshipDataLoader extends ChampionshipDataLoader {
  FakeChampionshipDataLoader(this.handler);

  final ChampionshipLoadHandler handler;
  final List<String> requestedCodes = [];

  @override
  Future<ChampionshipData> load(String championshipCode) {
    requestedCodes.add(championshipCode);
    return handler(championshipCode);
  }
}

void main() {
  group('ChampionshipPage', () {
    testWidgets('shows a loading indicator while Gateway data is loading', (
      WidgetTester tester,
    ) async {
      final completer = Completer<ChampionshipData>();

      final loader = FakeChampionshipDataLoader((_) => completer.future);

      await pumpTestApp(
        tester,
        ChampionshipPage(data: championshipFormula1Mock, dataLoader: loader),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(find.text('Impossible de charger le championnat.'), findsNothing);

      completer.complete(championshipFormula1Mock);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(find.text('Impossible de charger le championnat.'), findsNothing);

      expect(loader.requestedCodes, [championshipFormula1Mock.id]);
    });

    testWidgets('renders the championship data returned by the loader', (
      WidgetTester tester,
    ) async {
      final data = championshipFormula1Mock;

      final loader = FakeChampionshipDataLoader((_) async => data);

      await pumpTestApp(
        tester,
        ChampionshipPage(data: championshipFormula1Mock, dataLoader: loader),
      );

      await tester.pumpAndSettle();

      final String expectedHeadline;

      if (data.headline != null && data.headline!.trim().isNotEmpty) {
        expectedHeadline = data.headline!;
      } else {
        expectedHeadline = switch (data.state) {
          ChampionshipState.liveSession => 'Course',
          ChampionshipState.eventWeekend => data.circuit?.name ?? data.name,
          ChampionshipState.offSeason => data.name,
        };
      }

      expect(find.text(expectedHeadline), findsOneWidget);
      expect(find.text(data.replays.label), findsOneWidget);

      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(find.text('Impossible de charger le championnat.'), findsNothing);

      expect(loader.requestedCodes, [championshipFormula1Mock.id]);
    });

    testWidgets('shows an error and allows retry when Gateway loading fails', (
      WidgetTester tester,
    ) async {
      final loader = FakeChampionshipDataLoader((_) async {
        throw Exception('Gateway unavailable');
      });

      await pumpTestApp(
        tester,
        ChampionshipPage(data: championshipFormula1Mock, dataLoader: loader),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Impossible de charger le championnat.'),
        findsOneWidget,
      );

      expect(find.textContaining('Gateway unavailable'), findsOneWidget);

      expect(find.text('Réessayer'), findsOneWidget);

      expect(loader.requestedCodes, [championshipFormula1Mock.id]);

      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(loader.requestedCodes, [
        championshipFormula1Mock.id,
        championshipFormula1Mock.id,
      ]);

      expect(
        find.text('Impossible de charger le championnat.'),
        findsOneWidget,
      );
    });

    testWidgets('displays non-Formula 1 mock data without calling Gateway', (
      WidgetTester tester,
    ) async {
      final nonF1Data = championshipMocks.firstWhere(
        (item) => item.id != 'formula_1' && item.id != 'f1',
      );

      final loader = FakeChampionshipDataLoader((_) async {
        throw StateError(
          'Gateway should not be called for mock-backed championships.',
        );
      });

      await pumpTestApp(
        tester,
        ChampionshipPage(data: nonF1Data, dataLoader: loader),
      );

      await tester.pumpAndSettle();

      expect(find.text(nonF1Data.name), findsOneWidget);
      expect(find.text(nonF1Data.replays.label), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Impossible de charger le championnat.'), findsNothing);
      expect(loader.requestedCodes, isEmpty);
    });
  });
}
