/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## engine_temps_test.dart - Widget tests for EngineTemps.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/engine_temps.dart';

import '../../helpers/test_app.dart';

void main() {
  group('EngineTemps', () {
    testWidgets('renders the large layout with section labels and sensor rows', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const EngineTemps());

      expect(find.text('ENGINE'), findsOneWidget);
      // Default driver is NOR per the widget's initialDriverId.
      expect(find.text('NOR'), findsOneWidget);
      expect(find.text('REFROIDISSEMENT'), findsOneWidget);
      expect(find.text('ERS'), findsOneWidget);
      expect(find.text('TURBO'), findsOneWidget);
      expect(find.text('H₂O'), findsOneWidget);
      expect(find.text('OIL'), findsOneWidget);
      expect(find.text('HYD'), findsOneWidget);
      expect(find.text('MGU-K'), findsOneWidget);
      expect(find.text('ES'), findsOneWidget);
      expect(find.text('BOOST'), findsOneWidget);
    });

    testWidgets('renders the small layout with only water/oil temp rows', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const EngineTemps(initialDriverId: 'VER'),
        width: 150,
        height: 150,
      );

      expect(find.text('ENGINE'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('H₂O'), findsOneWidget);
      expect(find.text('OIL'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const EngineTemps());

      await tester.tap(find.byType(EngineTemps));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Engine'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
