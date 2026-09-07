/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## gear_rpm_test.dart - Widget tests for GearRpm.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/gear_rpm.dart';

import '../../helpers/test_app.dart';

void main() {
  group('GearRpm', () {
    testWidgets('renders the large layout with header, driver tag and RPM label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const GearRpm());

      expect(find.text('GEAR'), findsOneWidget);
      // Default driver is VER per the widget's initialDriverId.
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('RPM'), findsOneWidget);
    });

    testWidgets('renders the small layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const GearRpm(initialDriverId: 'LEC'),
        width: 150,
        height: 150,
      );

      expect(find.text('GEAR'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('RPM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const GearRpm());

      await tester.tap(find.byType(GearRpm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Gear & RPM'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
