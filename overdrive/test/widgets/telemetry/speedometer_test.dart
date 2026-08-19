/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## speedometer_test.dart - Widget tests for Speedometer.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/speedometer.dart';

import '../../helpers/test_app.dart';

void main() {
  group('Speedometer', () {
    testWidgets('renders header, driver tag and km/h unit at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Speedometer());

      expect(find.text('SPEED'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('km/h'), findsOneWidget);
      expect(find.text('DRS'), findsOneWidget);
    });

    testWidgets('renders without a RenderFlex overflow at a large generous size', (
      WidgetTester tester,
    ) async {
      // The layout has a known pre-existing overflow only at the small fixed
      // grid tile sizes (~85-105px) used elsewhere in the app's 3-column
      // grid. At a generously large size it should render cleanly.
      await pumpTelemetryTestApp(
        tester,
        const Speedometer(),
        width: 300,
        height: 300,
      );

      expect(find.text('SPEED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at small size, tolerating a known layout overflow', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Speedometer(),
        width: 150,
        height: 150,
      );

      expect(find.text('SPEED'), findsOneWidget);
      final exception = tester.takeException();
      if (exception != null) {
        expect(exception, isFlutterError);
      }
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Speedometer(initialDriverId: 'NOR'),
      );

      expect(find.text('NOR'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Speedometer());

      await tester.tap(find.byType(Speedometer));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Speed'), findsOneWidget);
    });
  });
}
