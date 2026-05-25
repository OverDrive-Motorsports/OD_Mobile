/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_and_tv_widgets_test.dart - Widget tests for search and TV controls.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/tv/tv_mock_data.dart';
import 'package:overdrive/services/tv/tv_stream.dart';
import 'package:overdrive/widgets/base/od_modal.dart';
import 'package:overdrive/widgets/search_bar.dart' as od;
import 'package:overdrive/widgets/tv/tv_stream_selector_sheet.dart';

import '../helpers/test_app.dart';

void main() {
  group('SearchBar', () {
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
            child: od.SearchBar(
              props: od.SearchBarProps(
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
          body: od.SearchBar(
            props: od.SearchBarProps(
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

  group('TvStreamSelectorSheet', () {
    testWidgets('renders options and returns the selected stream', (
      WidgetTester tester,
    ) async {
      TvStream? selectedStream;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    OdModal.show<void>(
                      context,
                      child: TvStreamSelectorSheet(
                        options: tvStreamsMonacoMock,
                        selectedId: tvStreamsMonacoMock.first.id,
                        onSelected: (stream) => selectedStream = stream,
                      ),
                    );
                  },
                  child: const Text('Open streams'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open streams'));
      await tester.pumpAndSettle();

      expect(find.text('Choisir un flux'), findsOneWidget);
      expect(find.text('International'), findsOneWidget);

      await tester.tap(find.text('Verstappen'));
      await tester.pumpAndSettle();

      expect(selectedStream?.id, 'verstappen');
      expect(find.text('Choisir un flux'), findsNothing);
    });
  });
}
