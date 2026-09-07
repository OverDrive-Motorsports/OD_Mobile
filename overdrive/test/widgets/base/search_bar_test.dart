/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_bar_test.dart - Widget tests for AppSearchBar.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/search_bar.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppSearchBar', () {
    testWidgets('forwards search input and clears external state', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      final searches = <String>[];
      var clearCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AppSearchBar(
              props: AppSearchBarProps(
                controller: controller,
                placeholder: 'Search drivers',
                onSearch: searches.add,
                onClear: () => clearCount++,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'leclerc');
      await tester.pumpAndSettle();

      expect(searches.last, 'leclerc');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      final clearAction = find.ancestor(
        of: find.byIcon(Icons.close_rounded),
        matching: find.byType(GestureDetector),
      );

      await tester.tap(clearAction);
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);
      expect(searches.last, '');
      expect(clearCount, 1);
    });

    testWidgets('does not show clear action while disabled', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: AppSearchBar(
            props: AppSearchBarProps(
              controller: TextEditingController(text: 'query'),
              enabled: false,
              onSearch: (_) {},
              onClear: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });
}
