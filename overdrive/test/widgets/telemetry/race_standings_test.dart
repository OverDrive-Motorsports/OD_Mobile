/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## race_standings_test.dart - Widget tests for RaceStandings.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/race_standings.dart';

import '../../helpers/test_app.dart';

void main() {
  group('RaceStandings', () {
    // RaceStandings still reads context.watch<TelemetrySimulator>() (for
    // getSnapshot per driver) even though it takes no constructor params, so
    // it needs the telemetry provider harness rather than plain pumpTestApp.

    testWidgets('renders header and all three simulated drivers at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const RaceStandings());

      expect(find.text('STANDINGS'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('NOR'), findsOneWidget);
    });

    testWidgets('renders without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const RaceStandings(),
        width: 150,
        height: 150,
      );

      expect(find.text('STANDINGS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the standings menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const RaceStandings());

      await tester.tap(find.byType(RaceStandings));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Standings'), findsOneWidget);
    });
  });
}
