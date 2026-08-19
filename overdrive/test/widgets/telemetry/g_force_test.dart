/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## g_force_test.dart - Widget tests for GForce.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/g_force.dart';

import '../../helpers/test_app.dart';

void main() {
  group('GForce', () {
    testWidgets('renders the large layout with header, canvas and numeric G readout', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const GForce());

      expect(find.text('G-FORCE'), findsOneWidget);
      // Default driver is VER per the widget's initialDriverId.
      expect(find.text('VER'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('LAT'), findsOneWidget);
      expect(find.text('LON'), findsOneWidget);
    });

    testWidgets('renders the small layout without the numeric readout', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const GForce(initialDriverId: 'LEC'),
        width: 150,
        height: 150,
      );

      expect(find.text('G-FORCE'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('LAT'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps rendering after simulator ticks update the trail', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const GForce());

      // Advance past a couple of 200ms simulator ticks.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('G-FORCE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const GForce());

      await tester.tap(find.byType(GForce));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('G-Force'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
