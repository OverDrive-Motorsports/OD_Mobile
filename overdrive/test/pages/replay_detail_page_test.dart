/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_detail_page_test.dart - Widget tests for ReplayDetailPage.
 ##
 ## Scope: static rendering only. The TV/Telemetrie action buttons call
 ## `context.push(...)` via go_router, which requires a GoRouter ancestor
 ## and is out of scope for these unit tests.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/replay/replay_detail_page.dart';
import 'package:overdrive/services/replay/replay_mock_data.dart';

import '../helpers/test_app.dart';

void main() {
  group('ReplayDetailPage', () {
    testWidgets('renders race info, actions and standings for the mock replay', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        ReplayDetailPage(replay: replayCatalogMock.first),
      );

      expect(find.text('Grand Prix de Bahrein 2024'), findsOneWidget);
      expect(
        find.text('Bahrain International Circuit · Sakhir, Bahrein'),
        findsOneWidget,
      );

      expect(find.text('ACCES'), findsOneWidget);
      expect(find.text('TV'), findsOneWidget);
      expect(find.text('Telemetrie'), findsOneWidget);

      expect(find.text('Classement'), findsOneWidget);
      expect(find.text('Pilotes'), findsOneWidget);
    });
  });
}
