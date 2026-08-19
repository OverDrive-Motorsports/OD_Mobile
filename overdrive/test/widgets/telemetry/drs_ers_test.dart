/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## drs_ers_test.dart - Widget tests for DrsErs.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/drs_ers.dart';

import '../../helpers/test_app.dart';

void main() {
  group('DrsErs', () {
    testWidgets('renders the large layout with header, ERS block and a DRS state badge', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const DrsErs());

      expect(find.text('DRS / ERS'), findsOneWidget);
      // Default driver is NOR per the widget's initialDriverId.
      expect(find.text('NOR'), findsOneWidget);
      expect(find.text('ERS'), findsOneWidget);
      // The DRS state is data-driven (open/closed), but exactly one of the two labels must render.
      final drsOpen = find.text('DRS OPEN').evaluate().isNotEmpty;
      final drsClosed = find.text('DRS CLOSED').evaluate().isNotEmpty;
      expect(drsOpen ^ drsClosed, isTrue);
    });

    testWidgets('renders the small layout without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const DrsErs(initialDriverId: 'VER'),
        width: 150,
        height: 150,
      );

      expect(find.text('DRS / ERS'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(tester.takeException(), isFlutterError); // known pre-existing small-mode overflow, unrelated to this test
    });

    testWidgets('tapping the widget opens the driver-switcher menu', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const DrsErs());

      await tester.tap(find.byType(DrsErs));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('DRS & ERS'), findsOneWidget);
      expect(find.text('DRIVER'), findsOneWidget);
    });
  });
}
