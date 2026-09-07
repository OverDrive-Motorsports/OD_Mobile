/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## weather_test.dart - Widget tests for Weather.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/weather.dart';

import '../../helpers/test_app.dart';

void main() {
  group('Weather', () {
    testWidgets('renders header and secondary metric labels at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Weather());

      expect(find.text('WEATHER'), findsOneWidget);
      expect(find.text('PISTE'), findsOneWidget);
      expect(find.text('AIR'), findsOneWidget);
      expect(find.text('VENT'), findsOneWidget);
      expect(find.text('HUM.'), findsOneWidget);
    });

    testWidgets('renders track/air columns without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Weather(),
        width: 150,
        height: 150,
      );

      expect(find.text('WEATHER'), findsOneWidget);
      expect(find.text('TRK'), findsOneWidget);
      expect(find.text('AIR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the weather menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Weather());

      await tester.tap(find.byType(Weather));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Weather'), findsWidgets);
    });
  });
}
