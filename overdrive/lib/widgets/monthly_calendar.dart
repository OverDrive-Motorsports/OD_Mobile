/*
##
## OverDrive 2026
## All Technical rights reserved
##
## monthly_calendar.dart - Minimal reusable monthly calendar widget.
##
*/

import 'package:flutter/material.dart';

import 'calendar_event.dart';
import '../core/theme/app_theme.dart';

class MonthlyCalendar extends StatefulWidget {
  const MonthlyCalendar({
    this.selectedDate,
    this.initialMonth,
    this.eventsByDate = const <DateTime, List<CalendarEventMarker>>{},
    this.onDateSelected,
    this.onMonthChanged,
    this.isLoading = false,
    this.firstAvailableMonth,
    this.lastAvailableMonth,
    this.today,
    this.weekdayLabels = _defaultWeekdayLabels,
    this.monthLabelBuilder,
    super.key,
  });

  final DateTime? selectedDate;
  final DateTime? initialMonth;
  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final bool isLoading;
  final DateTime? firstAvailableMonth;
  final DateTime? lastAvailableMonth;
  final DateTime? today;
  final List<String> weekdayLabels;
  final String Function(DateTime month)? monthLabelBuilder;

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late final PageController _pageController;
  late DateTime _firstMonth;
  late DateTime _lastMonth;
  late DateTime _visibleMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _configureBounds();
    _visibleMonth = _clampMonth(
      _monthOnly(widget.initialMonth ?? widget.selectedDate ?? _today),
    );
    _pageController = PageController(initialPage: _pageForMonth(_visibleMonth));
  }

  @override
  void didUpdateWidget(covariant MonthlyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousFirstMonth = _firstMonth;
    final previousLastMonth = _lastMonth;
    final previousToday = _today;

    _configureBounds();

    final nextControlledMonth = widget.selectedDate != null
        ? _clampMonth(_monthOnly(widget.selectedDate))
        : _visibleMonth;

    final boundsChanged =
        previousFirstMonth != _firstMonth || previousLastMonth != _lastMonth;
    final todayChanged = previousToday != _today;
    final selectedMonthChanged =
        widget.selectedDate != oldWidget.selectedDate &&
        nextControlledMonth != _visibleMonth;

    if (!boundsChanged && !todayChanged && !selectedMonthChanged) {
      return;
    }

    _visibleMonth = _clampMonth(nextControlledMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.jumpToPage(_pageForMonth(_visibleMonth));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = _pageForMonth(_visibleMonth) > 0;
    final canGoNext = _pageForMonth(_visibleMonth) < _pageCount - 1;
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
            _CalendarHeader(
              title: _buildMonthLabel(_visibleMonth),
              canGoPrevious: canGoPrevious,
              canGoNext: canGoNext,
              onPrevious: canGoPrevious ? _goToPreviousMonth : null,
              onNext: canGoNext ? _goToNextMonth : null,
            ),
            const SizedBox(height: 16),
            _WeekdayRow(labels: widget.weekdayLabels),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const _CalendarLoadingGrid()
            else
              AspectRatio(
                aspectRatio: 7 / 6.4,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _pageCount,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    return _MonthGrid(
                      month: _monthAt(index),
                      today: _today,
                      selectedDate: widget.selectedDate,
                      eventsByDate: normalizedEvents,
                      onDateTap: _handleDateTap,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  int get _pageCount => _monthsBetween(_firstMonth, _lastMonth) + 1;

  void _configureBounds() {
    _today = _dateOnly(widget.today ?? DateTime.now());
    final rawFirst = _monthOnly(
      widget.firstAvailableMonth ?? DateTime(_today.year, 1),
    );
    final rawLast = _monthOnly(
      widget.lastAvailableMonth ?? DateTime(_today.year, 12),
    );

    if (_monthsBetween(rawFirst, rawLast) < 0) {
      _firstMonth = rawFirst;
      _lastMonth = rawFirst;
      return;
    }

    _firstMonth = rawFirst;
    _lastMonth = rawLast;
  }

  DateTime _monthAt(int index) =>
      DateTime(_firstMonth.year, _firstMonth.month + index);

  int _pageForMonth(DateTime month) => _monthsBetween(_firstMonth, month);

  void _handlePageChanged(int index) {
    final month = _monthAt(index);
    if (month == _visibleMonth) {
      return;
    }

    setState(() => _visibleMonth = month);
    widget.onMonthChanged?.call(month);
  }

  void _goToPreviousMonth() {
    _pageController.animateToPage(
      _pageForMonth(_visibleMonth) - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextMonth() {
    _pageController.animateToPage(
      _pageForMonth(_visibleMonth) + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleDateTap(DateTime date) {
    widget.onDateSelected?.call(_dateOnly(date));
  }

  DateTime _clampMonth(DateTime month) {
    if (_monthsBetween(month, _firstMonth) > 0) {
      return _firstMonth;
    }
    if (_monthsBetween(_lastMonth, month) > 0) {
      return _lastMonth;
    }
    return month;
  }

  String _buildMonthLabel(DateTime month) {
    if (widget.monthLabelBuilder != null) {
      return widget.monthLabelBuilder!(month);
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

    return '${monthNames[month.month - 1]} ${month.year}';
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
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
        _HeaderButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: onPrevious,
          enabled: canGoPrevious,
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
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

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final safeLabels = labels.length == 7 ? labels : _defaultWeekdayLabels;

    return Row(
      children: safeLabels
          .map(
            (String label) => Expanded(
              child: Center(child: Text(label, style: AppTextStyles.label())),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selectedDate,
    required this.eventsByDate,
    required this.onDateTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selectedDate;
  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final ValueChanged<DateTime> onDateTap;

  @override
  Widget build(BuildContext context) {
    final days = _buildMonthDays(month);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.92,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: days.length,
      itemBuilder: (BuildContext context, int index) {
        final date = _dateOnly(days[index]);

        return _DayCell(
          date: date,
          isCurrentMonth: date.month == month.month,
          isToday: _isSameDate(today, date),
          isSelected: selectedDate != null && _isSameDate(selectedDate!, date),
          events: eventsByDate[date] ?? const <CalendarEventMarker>[],
          onTap: () => onDateTap(date),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEventMarker> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isToday
        ? AppColors.accent
        : Colors.white.withValues(alpha: 0.08);
    final backgroundColor = isSelected
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: isCurrentMonth ? 0.04 : 0.02);
    final textColor = isToday
        ? AppColors.accent
        : isCurrentMonth
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.day}',
                  style: AppTextStyles.bodyBold().copyWith(
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                _MonthlyEventDots(events: events),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyEventDots extends StatelessWidget {
  const _MonthlyEventDots({required this.events});

  final List<CalendarEventMarker> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox(height: 6);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: events
          .take(3)
          .map(
            (CalendarEventMarker event) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
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

class _CalendarLoadingGrid extends StatelessWidget {
  const _CalendarLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 6,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.92,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 42,
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
          );
        },
      ),
    );
  }
}

List<DateTime> _buildMonthDays(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final leadingDays = firstDay.weekday - DateTime.monday;
  final startDate = firstDay.subtract(Duration(days: leadingDays));

  return List<DateTime>.generate(
    42,
    (int index) => startDate.add(Duration(days: index)),
  );
}

int _monthsBetween(DateTime start, DateTime end) =>
    (end.year - start.year) * 12 + end.month - start.month;

DateTime _monthOnly(DateTime? date) {
  final safeDate = date ?? DateTime.now();
  return DateTime(safeDate.year, safeDate.month);
}

DateTime _dateOnly(DateTime date) => DateUtils.dateOnly(date);

bool _isSameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

const List<String> _defaultWeekdayLabels = <String>[
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];
