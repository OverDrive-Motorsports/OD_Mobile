/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## placeholder_page_test.dart - Widget tests for PlaceholderPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/shared/placeholder_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('PlaceholderPage', () {
    testWidgets('renders the given title', (WidgetTester tester) async {
      await pumpTestApp(tester, const PlaceholderPage(title: 'Bientôt disponible'));

      expect(find.text('Bientôt disponible'), findsOneWidget);
    });

    testWidgets('renders a different title without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const PlaceholderPage(title: 'Another Screen'));

      expect(find.text('Another Screen'), findsOneWidget);
    });
  });
}
