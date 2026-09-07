/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## damage_test.dart - Widget tests for Damage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/damage.dart';

import '../../helpers/test_app.dart';

void main() {
  group('Damage', () {
    testWidgets('renders the large layout with section labels and default driver', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Damage());

      expect(find.text('DÉGÂTS'), findsOneWidget);
      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('AÉRODYNAMIQUE'), findsOneWidget);
      expect(find.text('MÉCANIQUE'), findsOneWidget);
      expect(find.text('AILE AV'), findsOneWidget);
      expect(find.text('AILE AR'), findsOneWidget);
      expect(find.text('PLANCHER'), findsOneWidget);
      expect(find.text('BOÎTE'), findsOneWidget);
      expect(find.text('SUSPENS.'), findsOneWidget);
      expect(find.text('MOTEUR'), findsOneWidget);
    });

    testWidgets('renders the small layout with a compact dot grid', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const Damage(initialDriverId: 'VER'),
        width: 150,
        height: 150,
      );

      expect(find.text('DÉGÂTS'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('AV'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
      expect(find.text('SOL'), findsOneWidget);
      expect(find.text('SUS'), findsOneWidget);
      expect(find.text('BT'), findsOneWidget);
      expect(find.text('ENG'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const Damage());

      await tester.tap(find.byType(Damage));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Damage'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
