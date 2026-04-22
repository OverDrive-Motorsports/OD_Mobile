/*
##
## OverDrive 2026
## All Technical rights reserved
##
## home_page.dart - Home screen with the application menu overlay.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/calendar_event.dart';
import '../../widgets/daily_calendar.dart';
import '../../widgets/menu_overlay.dart';
import '../../widgets/monthly_calendar.dart';
import '../../widgets/weekly_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final firstAvailableMonth = DateTime(currentYear, 1);
    final lastAvailableMonth = DateTime(currentYear, 12);
    final firstAvailableDate = DateTime(currentYear, 1, 1);
    final lastAvailableDate = DateTime(currentYear, 12, 31);
    final dailyFirstAvailableDate = _maxDate(
      _startOfWeek(_selectedDate),
      firstAvailableDate,
    );
    final dailyLastAvailableDate = _minDate(
      dailyFirstAvailableDate.add(const Duration(days: 6)),
      lastAvailableDate,
    );
    final eventsByDate = _buildDemoEvents(currentYear);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 64, 12, 24),
                child: Column(
                  children: [
                    MonthlyCalendar(
                      selectedDate: _selectedDate,
                      initialMonth: _visibleMonth,
                      firstAvailableMonth: firstAvailableMonth,
                      lastAvailableMonth: lastAvailableMonth,
                      eventsByDate: eventsByDate,
                      onDateSelected: (DateTime date) {
                        setState(() => _selectedDate = date);
                      },
                      onMonthChanged: (DateTime month) {
                        setState(() => _visibleMonth = month);
                      },
                    ),
                    const SizedBox(height: 20),
                    WeeklyCalendar(
                      selectedDate: _selectedDate,
                      initialDate: _selectedDate,
                      firstAvailableDate: firstAvailableDate,
                      lastAvailableDate: lastAvailableDate,
                      eventsByDate: eventsByDate,
                      onDateSelected: (DateTime date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 20),
                    DailyCalendar(
                      selectedDate: _selectedDate,
                      initialDate: _selectedDate,
                      firstAvailableDate: dailyFirstAvailableDate,
                      lastAvailableDate: dailyLastAvailableDate,
                      eventsByDate: eventsByDate,
                      onDateSelected: (DateTime date) {
                        setState(() => _selectedDate = date);
                      },
                      onDayChanged: (DateTime date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const MenuOverlay(),
          ],
        ),
      ),
    );
  }
}

DateTime _startOfWeek(DateTime date) {
  final safeDate = DateUtils.dateOnly(date);
  return safeDate.subtract(Duration(days: safeDate.weekday - DateTime.monday));
}

DateTime _maxDate(DateTime left, DateTime right) =>
    left.isAfter(right) ? left : right;

DateTime _minDate(DateTime left, DateTime right) =>
    left.isBefore(right) ? left : right;

Map<DateTime, List<CalendarEventMarker>> _buildDemoEvents(int year) {
  return <DateTime, List<CalendarEventMarker>>{
    DateTime(year, 1, 12): const <CalendarEventMarker>[
      CalendarEventMarker(label: 'Kickoff'),
    ],
    DateTime(year, 2, 8): const <CalendarEventMarker>[
      CalendarEventMarker(label: 'Session'),
      CalendarEventMarker(color: AppColors.success, label: 'Brief'),
    ],
    DateTime(year, 4, 22): const <CalendarEventMarker>[
      CalendarEventMarker(label: 'Today'),
      CalendarEventMarker(color: Colors.white, label: 'Meeting'),
    ],
    DateTime(year, 7, 3): const <CalendarEventMarker>[
      CalendarEventMarker(color: Color(0xFFE05A47), label: 'Race'),
    ],
    DateTime(year, 9, 19): const <CalendarEventMarker>[
      CalendarEventMarker(label: 'Travel'),
      CalendarEventMarker(color: AppColors.success, label: 'Check-in'),
      CalendarEventMarker(color: Colors.white, label: 'Warmup'),
    ],
    DateTime(year, 11, 6): const <CalendarEventMarker>[
      CalendarEventMarker(label: 'Planning'),
    ],
  };
}
