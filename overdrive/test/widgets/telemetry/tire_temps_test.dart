/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tire_temps_test.dart - Widget tests for TireTemps.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/tire_temps.dart';

import '../../helpers/test_app.dart';

void main() {
  group('TireTemps', () {
    testWidgets('renders header, driver tag and compound letter at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const TireTemps());

      expect(find.text('TYRES'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      // Compound letter is one of S/M/H/I/W depending on the current tick.
      expect(
        find.textContaining(RegExp(r'^[SMHIW]$')),
        findsWidgets,
      );
    });

    testWidgets('renders the four tyre-corner cells without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const TireTemps(),
        width: 150,
        height: 150,
      );

      expect(find.text('TYRES'), findsOneWidget);
      expect(find.text('FL'), findsOneWidget);
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('RL'), findsOneWidget);
      expect(find.text('RR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const TireTemps(initialDriverId: 'NOR'),
      );

      expect(find.text('NOR'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const TireTemps());

      await tester.tap(find.byType(TireTemps));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tyre Temps'), findsOneWidget);
    });
  });
}
