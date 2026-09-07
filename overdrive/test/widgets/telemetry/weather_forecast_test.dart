/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## weather_forecast_test.dart - Widget tests for WeatherForecast.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/weather_forecast.dart';

import '../../helpers/test_app.dart';

void main() {
  group('WeatherForecast', () {
    testWidgets('renders the header at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const WeatherForecast());

      expect(find.text('PRÉVISIONS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the header without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const WeatherForecast(),
        width: 150,
        height: 150,
      );

      expect(find.text('PRÉVISIONS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the forecast menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const WeatherForecast());

      await tester.tap(find.byType(WeatherForecast));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Météo Prévisions'), findsOneWidget);
    });
  });
}
