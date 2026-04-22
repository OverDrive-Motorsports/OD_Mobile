/*
##
## OverDrive 2026
## All Technical rights reserved
##
## daily_calendar.dart - Minimal reusable daily calendar widget.
##
*/

import 'package:flutter/material.dart';

import 'calendar_event.dart';
import '../core/theme/app_theme.dart';

class DailyCalendar extends StatefulWidget {
  const DailyCalendar({
    this.selectedDate,
    this.initialDate,
    this.eventsByDate = const <DateTime, List<CalendarEventMarker>>{},
    this.onDateSelected,
    this.onDayChanged,
    this.isLoading = false,
    this.firstAvailableDate,
    this.lastAvailableDate,
    this.today,
    this.dayLabelBuilder,
    this.weekdayLabelBuilder,
    super.key,
  });

  final DateTime? selectedDate;
  final DateTime? initialDate;
  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onDayChanged;
  final bool isLoading;
  final DateTime? firstAvailableDate;
  final DateTime? lastAvailableDate;
  final DateTime? today;
  final String Function(DateTime date)? dayLabelBuilder;
  final String Function(DateTime date)? weekdayLabelBuilder;

  @override
  State<DailyCalendar> createState() => _DailyCalendarState();
}

class _DailyCalendarState extends State<DailyCalendar> {
  late final PageController _pageController;
  late DateTime _firstDate;
  late DateTime _lastDate;
  late DateTime _visibleDate;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _configureBounds();
    _visibleDate = _clampDate(
      _dateOnly(widget.initialDate ?? widget.selectedDate ?? _today),
    );
    _pageController = PageController(initialPage: _pageForDate(_visibleDate));
  }

  @override
  void didUpdateWidget(covariant DailyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousFirstDate = _firstDate;
    final previousLastDate = _lastDate;
    final previousToday = _today;

    _configureBounds();

    final nextControlledDate = widget.selectedDate != null
        ? _clampDate(_dateOnly(widget.selectedDate!))
        : _visibleDate;

    final boundsChanged =
        previousFirstDate != _firstDate || previousLastDate != _lastDate;
    final todayChanged = previousToday != _today;
    final selectedDateChanged =
        widget.selectedDate != oldWidget.selectedDate &&
        nextControlledDate != _visibleDate;

    if (!boundsChanged && !todayChanged && !selectedDateChanged) {
      return;
    }

    _visibleDate = _clampDate(nextControlledDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.jumpToPage(_pageForDate(_visibleDate));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = _pageForDate(_visibleDate) > 0;
    final canGoNext = _pageForDate(_visibleDate) < _pageCount - 1;
    final normalizedEvents = _normalizeEvents(widget.eventsByDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DailyHeader(
              title: _buildDayLabel(_visibleDate),
              canGoPrevious: canGoPrevious,
              canGoNext: canGoNext,
              onPrevious: canGoPrevious ? _goToPreviousDay : null,
              onNext: canGoNext ? _goToNextDay : null,
            ),
            const SizedBox(height: 16),
            if (widget.isLoading)
              const _DailyLoadingCard()
            else
              SizedBox(
                height: 148,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    return _DayCard(
                      date: _dateAt(index),
                      today: _today,
                      events:
                          normalizedEvents[_dateAt(index)] ??
                          const <CalendarEventMarker>[],
                      weekdayLabelBuilder: widget.weekdayLabelBuilder,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  int get _pageCount => _daysBetween(_firstDate, _lastDate) + 1;

  void _configureBounds() {
    _today = _dateOnly(widget.today ?? DateTime.now());
    final rawFirstDate = _dateOnly(
      widget.firstAvailableDate ?? DateTime(_today.year, 1, 1),
    );
    final rawLastDate = _dateOnly(
      widget.lastAvailableDate ?? DateTime(_today.year, 12, 31),
    );

    if (_daysBetween(rawFirstDate, rawLastDate) < 0) {
      _firstDate = rawFirstDate;
      _lastDate = rawFirstDate;
      return;
    }

    _firstDate = rawFirstDate;
    _lastDate = rawLastDate;
  }

  DateTime _dateAt(int index) => _firstDate.add(Duration(days: index));

  int _pageForDate(DateTime date) => _daysBetween(_firstDate, date);

  void _handlePageChanged(int index) {
    final date = _dateAt(index);
    if (date == _visibleDate) {
      return;
    }

    setState(() => _visibleDate = date);
    widget.onDayChanged?.call(date);
  }

  void _goToPreviousDay() {
    _pageController.animateToPage(
      _pageForDate(_visibleDate) - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextDay() {
    _pageController.animateToPage(
      _pageForDate(_visibleDate) + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  DateTime _clampDate(DateTime date) {
    if (_daysBetween(date, _firstDate) > 0) {
      return _firstDate;
    }
    if (_daysBetween(_lastDate, date) > 0) {
      return _lastDate;
    }
    return date;
  }

  String _buildDayLabel(DateTime date) {
    if (widget.dayLabelBuilder != null) {
      return widget.dayLabelBuilder!(date);
    }

    const monthNames = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _DailyHeader extends StatelessWidget {
  const _DailyHeader({
    required this.title,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyBold().copyWith(fontSize: 18),
          ),
        ),
        _DailyHeaderButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
          enabled: canGoPrevious,
        ),
        const SizedBox(width: 8),
        _DailyHeaderButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}

class _DailyHeaderButton extends StatelessWidget {
  const _DailyHeaderButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.06),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.today,
    required this.events,
    required this.weekdayLabelBuilder,
  });

  final DateTime date;
  final DateTime today;
  final List<CalendarEventMarker> events;
  final String Function(DateTime date)? weekdayLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDate(today, date);
    final weekdayLabel = weekdayLabelBuilder?.call(date) ?? _buildWeekday(date);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isToday
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekdayLabel,
            style: AppTextStyles.label(
              color: isToday ? AppColors.accent : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${date.day}',
            style: AppTextStyles.display(
              color: isToday ? AppColors.accent : AppColors.textPrimary,
            ).copyWith(fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(_buildMonthName(date), style: AppTextStyles.caption()),
          const SizedBox(height: 8),
          _DailyEventsSummary(events: events, isToday: isToday),
        ],
      ),
    );
  }
}

class _DailyEventsSummary extends StatelessWidget {
  const _DailyEventsSummary({required this.events, required this.isToday});

  final List<CalendarEventMarker> events;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        'No events',
        style: AppTextStyles.caption(
          color: isToday
              ? AppColors.black.withValues(alpha: 0.70)
              : AppColors.textMuted,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DailyEventDots(events: events),
        const SizedBox(width: 8),
        Text(
          '${events.length} event${events.length > 1 ? 's' : ''}',
          style: AppTextStyles.caption(
            color: isToday
                ? AppColors.black.withValues(alpha: 0.75)
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DailyEventDots extends StatelessWidget {
  const _DailyEventDots({required this.events});

  final List<CalendarEventMarker> events;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: events
          .take(3)
          .map(
            (CalendarEventMarker event) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: event.color,
                shape: BoxShape.circle,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DailyLoadingCard extends StatelessWidget {
  const _DailyLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }
}

int _daysBetween(DateTime start, DateTime end) => end.difference(start).inDays;

Map<DateTime, List<CalendarEventMarker>> _normalizeEvents(
  Map<DateTime, List<CalendarEventMarker>> input,
) {
  final normalized = <DateTime, List<CalendarEventMarker>>{};

  for (final MapEntry<DateTime, List<CalendarEventMarker>> entry
      in input.entries) {
    normalized[_dateOnly(entry.key)] = List<CalendarEventMarker>.unmodifiable(
      entry.value,
    );
  }

  return normalized;
}

DateTime _dateOnly(DateTime date) => DateUtils.dateOnly(date);

bool _isSameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String _buildWeekday(DateTime date) {
  const weekdayNames = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return weekdayNames[date.weekday - 1];
}

String _buildMonthName(DateTime date) {
  const monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return monthNames[date.month - 1];
}
