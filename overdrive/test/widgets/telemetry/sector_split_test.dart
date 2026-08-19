/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## sector_split_test.dart - Widget tests for SectorSplit.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/sector_split.dart';

import '../../helpers/test_app.dart';

void main() {
  group('SectorSplit', () {
    testWidgets('renders header, sector labels and best row at large size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const SectorSplit());

      expect(find.text('SECTORS'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);
      expect(find.text('S2'), findsOneWidget);
      expect(find.text('S3'), findsOneWidget);
      expect(find.text('BEST'), findsOneWidget);
    });

    testWidgets('renders sector labels without exceptions at small size', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const SectorSplit(),
        width: 150,
        height: 150,
      );

      expect(find.text('SECTORS'), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honors a custom initial driver id', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(
        tester,
        const SectorSplit(initialDriverId: 'LEC'),
      );

      expect(find.text('LEC'), findsOneWidget);
    });

    testWidgets('tapping the widget opens the menu with its label', (
      WidgetTester tester,
    ) async {
      await pumpTelemetryTestApp(tester, const SectorSplit());

      await tester.tap(find.byType(SectorSplit));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sector Split'), findsOneWidget);
    });
  });
}
