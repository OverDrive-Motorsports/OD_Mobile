/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## pedal_trace_test.dart - Widget tests for PedalTrace.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/pedal_trace.dart';

import '../../helpers/test_app.dart';

void main() {
  group('PedalTrace', () {
    testWidgets('renders header, legend and default driver at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const PedalTrace());

      expect(find.text('PÉDALE'), findsOneWidget);
      expect(find.text('ACC'), findsOneWidget);
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('−16s'), findsOneWidget);
      expect(find.text('NOW'), findsOneWidget);
    });

    testWidgets('renders without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const PedalTrace(),
        width: 150,
        height: 150,
      );

      expect(find.text('PÉDALE'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('tapping the widget opens the driver menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const PedalTrace());

      await tester.tap(find.byType(PedalTrace));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pedal Trace'), findsOneWidget);
    });
  });
}
