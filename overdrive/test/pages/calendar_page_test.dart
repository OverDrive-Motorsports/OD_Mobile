/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## calendar_page_test.dart - Widget tests for CalendarPage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/calendar/calendar_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('CalendarPage', () {
    testWidgets('loads championship filters and schedule content', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const CalendarPage());

      expect(find.text('Chargement du calendrier'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Calendrier'), findsOneWidget);
      expect(find.text('Tout'), findsOneWidget);
      expect(find.text('Formula 1'), findsWidgets);
      expect(find.text('Courses'), findsOneWidget);
    });
  });
}
