/*
##
## OverDrive 2026
## All Technical rights reserved
##
## weekly_calendar.dart - Minimal reusable weekly calendar widget.
##
*/

import 'package:flutter/material.dart';

import 'calendar_event.dart';
import '../core/theme/app_theme.dart';

class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({
    this.selectedDate,
    this.initialDate,
    this.eventsByDate = const <DateTime, List<CalendarEventMarker>>{},
    this.onDateSelected,
    this.onWeekChanged,
    this.isLoading = false,
    this.firstAvailableDate,
    this.lastAvailableDate,
    this.today,
    this.weekdayLabels = _defaultWeekdayLabels,
    this.weekLabelBuilder,
    super.key,
  });

  final DateTime? selectedDate;
  final DateTime? initialDate;
  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onWeekChanged;
  final bool isLoading;
  final DateTime? firstAvailableDate;
  final DateTime? lastAvailableDate;
  final DateTime? today;
  final List<String> weekdayLabels;
  final String Function(DateTime weekStart, DateTime weekEnd)? weekLabelBuilder;

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late final PageController _pageController;
  late DateTime _firstWeekStart;
  late DateTime _lastWeekStart;
  late DateTime _visibleWeekStart;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _configureBounds();
    _visibleWeekStart = _clampWeek(
      _startOfWeek(widget.initialDate ?? widget.selectedDate ?? _today),
    );
    _pageController = PageController(
      initialPage: _pageForWeekStart(_visibleWeekStart),
    );
  }

  @override
  void didUpdateWidget(covariant WeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousFirstWeekStart = _firstWeekStart;
    final previousLastWeekStart = _lastWeekStart;
    final previousToday = _today;

    _configureBounds();

    final nextControlledWeekStart = widget.selectedDate != null
        ? _clampWeek(_startOfWeek(widget.selectedDate))
        : _visibleWeekStart;

    final boundsChanged =
        previousFirstWeekStart != _firstWeekStart ||
        previousLastWeekStart != _lastWeekStart;
    final todayChanged = previousToday != _today;
    final selectedWeekChanged =
        widget.selectedDate != oldWidget.selectedDate &&
        nextControlledWeekStart != _visibleWeekStart;

    if (!boundsChanged && !todayChanged && !selectedWeekChanged) {
      return;
    }

    _visibleWeekStart = _clampWeek(nextControlledWeekStart);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.jumpToPage(_pageForWeekStart(_visibleWeekStart));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = _pageForWeekStart(_visibleWeekStart) > 0;
    final canGoNext = _pageForWeekStart(_visibleWeekStart) < _pageCount - 1;
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
            _WeeklyHeader(
              title: _buildWeekLabel(
                _visibleWeekStart,
                _visibleWeekStart.add(const Duration(days: 6)),
              ),
              canGoPrevious: canGoPrevious,
              canGoNext: canGoNext,
              onPrevious: canGoPrevious ? _goToPreviousWeek : null,
              onNext: canGoNext ? _goToNextWeek : null,
            ),
            const SizedBox(height: 16),
            if (widget.isLoading)
              const _WeeklyLoadingRow()
            else
              SizedBox(
                height: 100,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    return _WeekRow(
                      weekStart: _weekStartAt(index),
                      today: _today,
                      selectedDate: widget.selectedDate,
                      eventsByDate: normalizedEvents,
                      weekdayLabels: widget.weekdayLabels,
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

  int get _pageCount => _weeksBetween(_firstWeekStart, _lastWeekStart) + 1;

  void _configureBounds() {
    _today = _dateOnly(widget.today ?? DateTime.now());
    final rawFirstWeekStart = _startOfWeek(
      widget.firstAvailableDate ?? DateTime(_today.year, 1, 1),
    );
    final rawLastWeekStart = _startOfWeek(
      widget.lastAvailableDate ?? DateTime(_today.year, 12, 31),
    );

    if (_weeksBetween(rawFirstWeekStart, rawLastWeekStart) < 0) {
      _firstWeekStart = rawFirstWeekStart;
      _lastWeekStart = rawFirstWeekStart;
      return;
    }

    _firstWeekStart = rawFirstWeekStart;
    _lastWeekStart = rawLastWeekStart;
  }

  DateTime _weekStartAt(int index) =>
      _firstWeekStart.add(Duration(days: index * 7));

  int _pageForWeekStart(DateTime weekStart) =>
      _weeksBetween(_firstWeekStart, weekStart);

  void _handlePageChanged(int index) {
    final weekStart = _weekStartAt(index);
    if (weekStart == _visibleWeekStart) {
      return;
    }

    setState(() => _visibleWeekStart = weekStart);
    widget.onWeekChanged?.call(weekStart);
  }

  void _goToPreviousWeek() {
    _pageController.animateToPage(
      _pageForWeekStart(_visibleWeekStart) - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextWeek() {
    _pageController.animateToPage(
      _pageForWeekStart(_visibleWeekStart) + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleDateTap(DateTime date) {
    widget.onDateSelected?.call(_dateOnly(date));
  }

  DateTime _clampWeek(DateTime weekStart) {
    if (_weeksBetween(weekStart, _firstWeekStart) > 0) {
      return _firstWeekStart;
    }
    if (_weeksBetween(_lastWeekStart, weekStart) > 0) {
      return _lastWeekStart;
    }
    return weekStart;
  }

  String _buildWeekLabel(DateTime weekStart, DateTime weekEnd) {
    if (widget.weekLabelBuilder != null) {
      return widget.weekLabelBuilder!(weekStart, weekEnd);
    }

    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final startMonth = monthNames[weekStart.month - 1];
    final endMonth = monthNames[weekEnd.month - 1];

    if (weekStart.month == weekEnd.month) {
      return '$startMonth ${weekStart.day} - ${weekEnd.day}';
    }

    return '$startMonth ${weekStart.day} - $endMonth ${weekEnd.day}';
  }
}

class _WeeklyHeader extends StatelessWidget {
  const _WeeklyHeader({
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
        _WeeklyHeaderButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
          enabled: canGoPrevious,
        ),
        const SizedBox(width: 8),
        _WeeklyHeaderButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}

class _WeeklyHeaderButton extends StatelessWidget {
  const _WeeklyHeaderButton({
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

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.weekStart,
    required this.today,
    required this.selectedDate,
    required this.eventsByDate,
    required this.weekdayLabels,
    required this.onDateTap,
  });

  final DateTime weekStart;
  final DateTime today;
  final DateTime? selectedDate;
  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final List<String> weekdayLabels;
  final ValueChanged<DateTime> onDateTap;

  @override
  Widget build(BuildContext context) {
    final safeLabels = weekdayLabels.length == 7
        ? weekdayLabels
        : _defaultWeekdayLabels;

    return Row(
      children: List<Widget>.generate(7, (int index) {
        final date = weekStart.add(Duration(days: index));

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 8),
            child: _WeekDayCell(
              label: safeLabels[index],
              date: date,
              isToday: _isSameDate(today, date),
              isSelected:
                  selectedDate != null && _isSameDate(selectedDate!, date),
              events:
                  eventsByDate[_dateOnly(date)] ??
                  const <CalendarEventMarker>[],
              onTap: () => onDateTap(date),
            ),
          ),
        );
      }),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.label,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEventMarker> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isToday
        ? AppColors.accent
        : isSelected
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.04);
    final borderColor = isToday
        ? AppColors.accent
        : Colors.white.withValues(alpha: isSelected ? 0.18 : 0.08);
    final primaryTextColor = isToday ? AppColors.black : AppColors.textPrimary;
    final secondaryTextColor = isToday
        ? AppColors.black.withValues(alpha: 0.70)
        : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label(color: secondaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: AppTextStyles.bodyBold().copyWith(
                    fontSize: 16,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                _WeeklyEventDots(
                  events: events,
                  color: isToday ? AppColors.black : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyEventDots extends StatelessWidget {
  const _WeeklyEventDots({required this.events, required this.color});

  final List<CalendarEventMarker> events;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox(height: 4);
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
                color: event.color == AppColors.accent ? color : event.color,
                shape: BoxShape.circle,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _WeeklyLoadingRow extends StatelessWidget {
  const _WeeklyLoadingRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: List<Widget>.generate(7, (int index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 6 ? 0 : 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

int _weeksBetween(DateTime start, DateTime end) =>
    end.difference(start).inDays ~/ 7;

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

DateTime _startOfWeek(DateTime? date) {
  final safeDate = _dateOnly(date ?? DateTime.now());
  return safeDate.subtract(Duration(days: safeDate.weekday - DateTime.monday));
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
