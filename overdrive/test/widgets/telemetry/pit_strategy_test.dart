/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## pit_strategy_test.dart - Widget tests for PitStrategy.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/pit_strategy.dart';

import '../../helpers/test_app.dart';

void main() {
  group('PitStrategy', () {
    testWidgets('renders header, driver tag and usage labels at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const PitStrategy());

      expect(find.text('PIT STRATEGY'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('laps'), findsOneWidget);
      expect(find.text('USURE'), findsOneWidget);
      expect(find.text('PIT'), findsOneWidget);
    });

    testWidgets('renders the compact "PIT" header without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const PitStrategy(),
        width: 150,
        height: 150,
      );

      expect(find.text('PIT'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const PitStrategy(initialDriverId: 'VER'),
      );

      expect(find.text('VER'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const PitStrategy());

      await tester.tap(find.byType(PitStrategy));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pit Strategy'), findsOneWidget);
    });
  });
}
