/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## monthly_calendar.dart - Scrollable monthly calendar grid with event marker dots and day selection.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'event_calendar.dart';

// ── Glass themes ──────────────────────────────────────────────────────────

const _kBorderColor = Color(0x26FFFFFF);

final _kContainerTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.14,
  blurSigma: 24.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.04,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kNavBtnTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.10,
  blurSigma: 20.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.06,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kNavBtnDisabledTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.04,
  blurSigma: 14.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.02,
  edgeLightColor: const Color(0x10FFFFFF),
  edgeShadowColor: const Color(0x10FFFFFF),
);

// ── MonthlyCalendar ───────────────────────────────────────────────────────

/// A reusable monthly calendar widget for date selection.
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

  // Tracks swipe direction for the animated month label (+1 = forward, -1 = back).
  int _navDirection = 1;

  @override
  void initState() {
    super.initState();
    _configureBounds();
    _visibleMonth = _clampMonth(_monthOnly(widget.initialMonth ?? _today));
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

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kContainerTheme,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CalendarHeader(
                  monthLabel: _buildMonthLabel(_visibleMonth),
                  visibleMonth: _visibleMonth,
                  navDirection: _navDirection,
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
                    aspectRatio: 7 / 6.0,
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
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

    setState(() {
      _navDirection = index > _pageForMonth(_visibleMonth) ? 1 : -1;
      _visibleMonth = month;
    });
    widget.onMonthChanged?.call(month);
  }

  void _goToPreviousMonth() {
    _pageController.animateToPage(
      _pageForMonth(_visibleMonth) - 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextMonth() {
    _pageController.animateToPage(
      _pageForMonth(_visibleMonth) + 1,
      duration: const Duration(milliseconds: 280),
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
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return '${monthNames[month.month - 1]} ${month.year}';
  }
}

// ── _CalendarHeader ───────────────────────────────────────────────────────

// Month label with animated slide-in/out transitions and prev/next navigation buttons.
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.monthLabel,
    required this.visibleMonth,
    required this.navDirection,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String monthLabel;
  final DateTime visibleMonth;
  final int navDirection;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey(visibleMonth);
              final beginOffset = isIncoming
                  ? Offset(navDirection > 0 ? 0.25 : -0.25, 0)
                  : Offset(navDirection > 0 ? -0.25 : 0.25, 0);
              return SlideTransition(
                position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
                    .animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              monthLabel,
              key: ValueKey(visibleMonth),
              style: AppTextStyles.bodyBold().copyWith(fontSize: 18),
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
          enabled: canGoPrevious,
        ),
        const SizedBox(width: 8),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}

// ── _NavButton ────────────────────────────────────────────────────────────

// Liquid-glass icon button for previous/next month navigation with press-scale feedback.
class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _press.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _press.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.enabled ? () => _press.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: CupertinoLiquidGlass(
          theme: widget.enabled ? _kNavBtnTheme : _kNavBtnDisabledTheme,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _WeekdayRow ───────────────────────────────────────────────────────────

// Fixed row of seven weekday abbreviation labels aligned with the day columns below.
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

// ── _MonthGrid ────────────────────────────────────────────────────────────

// 7-column grid of day cells for a single month, padded to a full 6-week view.
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

// ── _DayCell ──────────────────────────────────────────────────────────────

// Individual tappable day cell with today/selected/out-of-month state styling and event dots.
class _DayCell extends StatefulWidget {
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
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.isSelected) {
      return AppColors.white.withValues(alpha: 0.14);
    }
    if (widget.isToday) {
      return AppColors.gold.withValues(alpha: 0.10);
    }
    if (widget.isCurrentMonth) {
      return AppColors.white.withValues(alpha: 0.04);
    }
    return AppColors.white.withValues(alpha: 0.02);
  }

  Color get _borderColor {
    if (widget.isSelected) {
      return AppColors.white.withValues(alpha: 0.40);
    }
    if (widget.isToday) {
      return AppColors.gold.withValues(alpha: 0.80);
    }
    return AppColors.white.withValues(alpha: 0.08);
  }

  Color get _textColor {
    if (widget.isToday) {
      return AppColors.gold;
    }
    if (widget.isCurrentMonth) {
      return AppColors.textPrimary;
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.date.day}',
                  style: AppTextStyles.bodyBold().copyWith(
                    fontSize: 13,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 3),
                _MonthlyEventDots(events: widget.events),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── _MonthlyEventDots ─────────────────────────────────────────────────────

// Up to three coloured dots indicating events on a calendar day cell.
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

// ── _CalendarLoadingGrid ──────────────────────────────────────────────────

// Skeleton grid of 42 placeholder cells shown while event data is loading.
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
          childAspectRatio: 1.05,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: 42,
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

// Strips time components from event map keys so they align with date-only day cells.
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

// Returns 42 dates covering the visible 6-week grid starting from the Monday before the first day.
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
  'LUN',
  'MAR',
  'MER',
  'JEU',
  'VEN',
  'SAM',
  'DIM',
];
