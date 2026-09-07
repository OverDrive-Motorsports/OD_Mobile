/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_page_test.dart - Widget tests for ChampionshipPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/navigation/app_routes.dart';
import 'package:overdrive/pages/championship/championship_page.dart';
import 'package:overdrive/services/championship/championship_mock_data.dart';

import '../helpers/test_app.dart';

void main() {
  group('ChampionshipPage', () {
    testWidgets('renders live blocks from Formula 1 mock data', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        ChampionshipPage(data: championshipFormula1Mock),
        onGenerateRoute: buildAppRoute,
      );

      expect(find.text('DIRECT'), findsOneWidget);
      expect(find.text('TV Live'), findsOneWidget);
      expect(find.text('Bibliotheque de replays'), findsOneWidget);
    });
  });
}
