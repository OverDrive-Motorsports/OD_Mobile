/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_page_test.dart - Widget tests for TelemetryPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/telemetry/telemetry_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('TelemetryPage', () {
    testWidgets('renders the telemetry grid title', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const TelemetryPage());

      expect(find.text('Telemetry'), findsOneWidget);
    });
  });
}
