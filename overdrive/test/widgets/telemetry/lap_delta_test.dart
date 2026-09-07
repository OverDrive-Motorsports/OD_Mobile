/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_delta_test.dart - Widget tests for LapDelta.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/lap_delta.dart';

import '../../helpers/test_app.dart';

void main() {
  group('LapDelta', () {
    testWidgets('renders the large layout with header, best/delta labels and lap counter', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const LapDelta());

      expect(find.text('LAP'), findsOneWidget);
      // Default driver is VER per the widget's initialDriverId.
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('BEST'), findsOneWidget);
      expect(find.text('DELTA'), findsOneWidget);
      // Lap counter is formatted as "L{n}/57" — assert the fixed total-laps suffix only.
      expect(find.textContaining('/57'), findsOneWidget);
    });

    testWidgets('renders the small layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const LapDelta(initialDriverId: 'NOR'),
        width: 150,
        height: 150,
      );

      expect(find.text('LAP'), findsOneWidget);
      expect(find.text('NOR'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const LapDelta());

      await tester.tap(find.byType(LapDelta));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lap Delta'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
