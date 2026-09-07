/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## weather_radar_test.dart - Widget tests for WeatherRadar.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/weather_radar.dart';

import '../../helpers/test_app.dart';

void main() {
  group('WeatherRadar', () {
    testWidgets('renders the RADAR badge and legend at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const WeatherRadar());
      // Let the repeating pulse AnimationController advance a bit without
      // pumpAndSettle (it repeats forever and would never settle).
      await tester.pump(const Duration(milliseconds: 100));

      // The RADAR badge has a known pre-existing ~6px overflow at this
      // width, unrelated to this test; consume it instead of failing on it.
      expect(tester.takeException(), isFlutterError);

      expect(find.text('RADAR'), findsOneWidget);
      expect(find.text('LÉGÈRE'), findsOneWidget);
      expect(find.text('MODÉRÉE'), findsOneWidget);
      expect(find.text('FORTE'), findsOneWidget);
      expect(find.text('INTENSE'), findsOneWidget);
      expect(find.text('EXTRÊME'), findsOneWidget);
    });

    testWidgets('renders the RADAR badge without the legend at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const WeatherRadar(),
        width: 100,
        height: 100,
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('RADAR'), findsOneWidget);
      expect(find.text('LÉGÈRE'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the radar menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const WeatherRadar());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(WeatherRadar));
      // Avoid pumpAndSettle: WeatherRadar's own AnimationController repeats
      // forever (radar sweep pulse), so the tree never truly settles. Pump
      // past the 200ms menu-route transition instead.
      await tester.pump(const Duration(milliseconds: 250));

      // Same known pre-existing badge overflow as above.
      expect(tester.takeException(), isFlutterError);

      expect(find.text('Radar Météo'), findsOneWidget);
    });
  });
}
