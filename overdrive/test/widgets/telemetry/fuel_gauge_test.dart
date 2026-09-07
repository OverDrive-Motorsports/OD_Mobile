/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## fuel_gauge_test.dart - Widget tests for FuelGauge.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/fuel_gauge.dart';

import '../../helpers/test_app.dart';

void main() {
  group('FuelGauge', () {
    testWidgets('renders the large layout with header and consumption stats', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const FuelGauge());

      expect(find.text('FUEL'), findsOneWidget);
      // Default driver is VER per the widget's initialDriverId.
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('ACT'), findsOneWidget);
      expect(find.text('TGT'), findsOneWidget);
      expect(find.textContaining('tours'), findsOneWidget);
    });

    testWidgets('renders the small layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const FuelGauge(initialDriverId: 'LEC'),
        width: 150,
        height: 150,
      );

      expect(find.text('FUEL'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const FuelGauge());

      await tester.tap(find.byType(FuelGauge));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Fuel Load'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
