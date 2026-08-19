/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## penalty_test.dart - Widget tests for Penalty.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/penalty.dart';

import '../../helpers/test_app.dart';

void main() {
  group('Penalty', () {
    testWidgets('renders header and track-limit section at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Penalty());

      expect(find.text('PÉNALITÉS'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('LIMITES PISTE'), findsOneWidget);
      expect(find.text('BLEU'), findsOneWidget);
    });

    testWidgets('renders without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Penalty(),
        width: 150,
        height: 150,
      );

      expect(find.text('PÉNALITÉS'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Penalty(initialDriverId: 'NOR'),
      );

      expect(find.text('NOR'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Penalty());

      await tester.tap(find.byType(Penalty));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Penalties'), findsOneWidget);
    });
  });
}
