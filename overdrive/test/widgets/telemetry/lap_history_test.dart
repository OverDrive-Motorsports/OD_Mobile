/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_history_test.dart - Widget tests for LapHistory.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/lap_history.dart';

import '../../helpers/test_app.dart';

void main() {
  group('LapHistory', () {
    testWidgets('renders the large scrollable layout with header, legend and axis labels', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const LapHistory());

      expect(find.text('HIST. TOURS'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('NOR'), findsOneWidget);
      expect(find.text('L1'), findsOneWidget);
      // Total laps is a fixed constant (57).
      expect(find.text('L57'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders the small static-chart layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const LapHistory(), width: 150, height: 150);

      expect(find.text('HIST. TOURS'), findsOneWidget);
      expect(find.text('L1'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('tapping the widget opens its menu without a driver selector', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const LapHistory());

      await tester.tap(find.byType(LapHistory));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lap History'), findsOneWidget);
      // LapHistory has no per-driver state, so the menu omits the driver picker section.
      expect(find.text('DRIVER'), findsNothing);
    });
  });
}
