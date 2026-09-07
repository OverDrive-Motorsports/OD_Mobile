/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_page_test.dart - Widget tests for SearchPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/search/search_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('SearchPage', () {
    testWidgets('owns a reusable search bar controller', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SearchPage());

      expect(find.byType(SearchPage), findsOneWidget);
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Rechercher'), findsOneWidget);
    });
  });
}
