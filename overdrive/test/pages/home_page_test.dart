/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## home_page_test.dart - Widget tests for HomePage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/home/home_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders the liquid glass calibration gallery', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const HomePage());

      expect(find.text('Liquid Glass'), findsOneWidget);
      expect(find.text('Calibration des surfaces'), findsOneWidget);
      expect(find.text('Très léger — blanc'), findsOneWidget);
      expect(find.text('Maximum — gris blanc'), findsOneWidget);
    });
  });
}
