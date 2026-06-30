/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## calendar_widgets_test.dart - Widget tests for the monthly calendar and event list calendar widgets.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/theme/app_theme.dart';
import 'package:overdrive/widgets/calendar/event_calendar.dart';
import 'package:overdrive/widgets/calendar/monthly_calendar.dart';

import '../helpers/test_app.dart';

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

  group('EventCalendar', () {
    testWidgets('sorts events and renders status labels', (
      WidgetTester tester,
    ) async {
      final events = <CalendarScheduleEvent>[
        CalendarScheduleEvent(
          id: 'upcoming',
          name: 'Future Grand Prix',
          championshipName: 'Formula 1',
          startDate: DateTime(2026, 6, 5),
          endDate: DateTime(2026, 6, 7),
          location: 'Montreal',
        ),
        CalendarScheduleEvent(
          id: 'ongoing',
          name: 'Current Grand Prix',
          championshipName: 'WEC',
          startDate: DateTime(2026, 5, 18),
          endDate: DateTime(2026, 5, 20),
          location: 'Spa',
        ),
        CalendarScheduleEvent(
          id: 'past',
          name: 'Past Grand Prix',
          championshipName: 'MotoGP',
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 4, 2),
        ),
      ];

      await pumpTestApp(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: EventCalendar(events: events, today: DateTime(2026, 5, 19)),
          ),
        ),
      );

      expect(find.text('Past Grand Prix'), findsOneWidget);
      expect(find.text('Current Grand Prix'), findsOneWidget);
      expect(find.text('Future Grand Prix'), findsOneWidget);
      expect(find.text('Passe'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('A venir'), findsOneWidget);
    });

    testWidgets('renders the configured empty state', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: EventCalendar(
            events: <CalendarScheduleEvent>[],
            emptyTitle: 'No races',
            emptySubtitle: 'Try another filter.',
          ),
        ),
      );

      expect(find.text('No races'), findsOneWidget);
      expect(find.text('Try another filter.'), findsOneWidget);
    });
  });
}
