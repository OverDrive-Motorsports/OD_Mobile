/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## throttle_brake_test.dart - Widget tests for ThrottleBrake.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/throttle_brake.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ThrottleBrake', () {
    testWidgets('renders header, driver tag and full pedal labels at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const ThrottleBrake());

      expect(find.text('PEDALS'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('THROTTLE'), findsOneWidget);
      expect(find.text('BRAKE'), findsOneWidget);
    });

    testWidgets('renders compact pedal labels without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const ThrottleBrake(),
        width: 150,
        height: 150,
      );

      expect(find.text('PEDALS'), findsOneWidget);
      expect(find.text('THR'), findsOneWidget);
      expect(find.text('BRK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const ThrottleBrake(initialDriverId: 'VER'),
      );

      expect(find.text('VER'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const ThrottleBrake());

      await tester.tap(find.byType(ThrottleBrake));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Throttle / Brake'), findsOneWidget);
    });
  });
}
