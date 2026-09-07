/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_page_test.dart - Widget tests for ReplayPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/replay/replay_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('ReplayPage', () {
    testWidgets('only lists the Bahrein 2024 replay', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const ReplayPage());

      expect(find.text('Rechercher un replay'), findsOneWidget);
      expect(find.text('Grand Prix de Bahrein 2024'), findsOneWidget);
    });
  });
}
