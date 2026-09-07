/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## monthly_calendar_test.dart - Widget tests for MonthlyCalendar.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/theme/app_theme.dart';
import 'package:overdrive/widgets/calendar/event_calendar.dart';
import 'package:overdrive/widgets/calendar/monthly_calendar.dart';

import '../../helpers/test_app.dart';

void main() {
  group('MonthlyCalendar', () {
    testWidgets('renders provided labels and reports selected dates', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: MonthlyCalendar(
                selectedDate: DateTime(2026, 5, 19),
                initialMonth: DateTime(2026, 5),
                today: DateTime(2026, 5, 19),
                weekdayLabels: const <String>[
                  'M',
                  'T',
                  'W',
                  'T',
                  'F',
                  'S',
                  'S',
                ],
                monthLabelBuilder: (month) =>
                    'Month ${month.month}/${month.year}',
                eventsByDate: <DateTime, List<CalendarEventMarker>>{
                  DateTime(2026, 5, 22): const <CalendarEventMarker>[
                    CalendarEventMarker(color: AppColors.gold, label: 'F1'),
                  ],
                },
                onDateSelected: (date) => selectedDate = date,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Month 5/2026'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);

      await tester.tap(find.text('22'));
      await tester.pump();

      expect(selectedDate, DateTime(2026, 5, 22));
    });

    testWidgets('shows a loading grid while data is loading', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: MonthlyCalendar(
                initialMonth: DateTime(2026, 5),
                today: DateTime(2026, 5, 19),
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('19'), findsNothing);
    });
  });
}
