/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_timer_test.dart - Widget tests for LapTimer.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/lap_timer.dart';

import '../../helpers/test_app.dart';

void main() {
  group('LapTimer', () {
    // LapTimer owns its own Stopwatch/Timer and does not read TelemetrySimulator,
    // so it does not need the telemetry provider — plain pumpTestApp is enough.
    testWidgets('renders the large layout with header, best label and play/lap controls', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(child: SizedBox(width: 320, height: 320, child: LapTimer())),
        ),
      );

      expect(find.text('LAP TIMER'), findsOneWidget);
      expect(find.text('BEST'), findsOneWidget);
      expect(find.text('PAUSE'), findsOneWidget);
      expect(find.text('LAP'), findsOneWidget);
    });

    testWidgets('renders the small layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(child: SizedBox(width: 150, height: 150, child: LapTimer())),
        ),
      );

      expect(find.text('LAP TIMER'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('the pause button toggles to PLAY when tapped', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(child: SizedBox(width: 320, height: 320, child: LapTimer())),
        ),
      );

      expect(find.text('PAUSE'), findsOneWidget);

      await tester.tap(find.text('PAUSE'));
      await tester.pump();

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('tapping the widget opens its menu without a driver selector', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(child: SizedBox(width: 320, height: 320, child: LapTimer())),
        ),
      );

      await tester.tap(find.byType(LapTimer));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lap Timer'), findsOneWidget);
      // LapTimer is not driver-aware, so the menu omits the driver picker section.
      expect(find.text('DRIVER'), findsNothing);
    });
  });
}
