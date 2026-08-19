/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## settings_page_test.dart - Widget tests for SettingsPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/settings/settings_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('renders sections and shows save feedback', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SettingsPage());

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('EXPERIENCE'), findsOneWidget);
      expect(find.text('ACTIONS'), findsOneWidget);

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();

      expect(find.text('Reglages enregistres localement.'), findsOneWidget);
    });
  });
}
