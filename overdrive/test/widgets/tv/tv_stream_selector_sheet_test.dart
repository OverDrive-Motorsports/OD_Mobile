/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_stream_selector_sheet_test.dart - Widget tests for TvStreamSelectorSheet.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/tv/tv_mock_data.dart';
import 'package:overdrive/services/tv/tv_stream.dart';
import 'package:overdrive/widgets/base/app_modal.dart';
import 'package:overdrive/widgets/tv/tv_stream_selector_sheet.dart';

import '../../helpers/test_app.dart';

void main() {
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
                    AppModal.show<void>(
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
