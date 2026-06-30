/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## calendar_page.dart - Calendar screen combining championship filters, monthly calendar, and race event cards.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/calendar/calendar_service.dart';
import '../../widgets/calendar/event_calendar.dart';
import '../../widgets/calendar/monthly_calendar.dart';

// ── Glass themes ──────────────────────────────────────────────────────────

const _kGlassBorderColor = Color(0x26FFFFFF);

final _kArchiveTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.12,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.07,
  vibrancyIntensity: 0.03,
  edgeLightColor: _kGlassBorderColor,
  edgeShadowColor: _kGlassBorderColor,
);

const String _allChampionshipsFilterId = 'all';
const List<String> _calendarWeekdayLabels = <String>[
  'Lu',
  'Ma',
  'Me',
  'Je',
  'Ve',
  'Sa',
  'Di',
];
const List<String> _calendarMonthNames = <String>[
  'Janvier',
  'Fevrier',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Aout',
  'Septembre',
  'Octobre',
  'Novembre',
  'Decembre',
];
const List<String> _calendarMonthNamesLowercase = <String>[
  'janvier',
  'fevrier',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'aout',
  'septembre',
  'octobre',
  'novembre',
  'decembre',
];

/// Calendar screen composed from the reusable monthly and event widgets.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

/// Loads calendar data and coordinates filtering, selection, and archives.
class _CalendarPageState extends State<CalendarPage> {
  final CalendarService _calendarService = CalendarService.instance;

  late final DateTime _today;
  List<CalendarChampionship> _championships = const <CalendarChampionship>[];
  List<CalendarRaceEntry> _allEntries = const <CalendarRaceEntry>[];
  late DateTime _selectedDate;
  String _selectedChampionshipId = _allChampionshipsFilterId;
  bool _showPastEvents = false;
  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _today = calendarReferenceToday();
    _selectedDate = _today;
    _loadCalendarData();
  }

  /// Loads championships and schedule entries from the calendar service.
  Future<void> _loadCalendarData() async {
    try {
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        _calendarService.getChampionships(referenceDate: _today),
        _calendarService.getSchedule(referenceDate: _today),
      ]);

      if (!mounted) {
        return;
      }

      final championships = responses[0] as List<CalendarChampionship>;
      final entries = responses[1] as List<CalendarRaceEntry>;

      setState(() {
        _championships = championships;
        _allEntries = entries;
        _selectedDate = resolveCalendarSelection(
          entries: entries,
          today: _today,
          preferredDate: _selectedDate,
        );
        _isLoading = false;
        _loadingError = null;
      });
    } on CalendarServiceException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadingError = exception.message;
      });
    }
  }

  /// Returns entries matching the selected championship filter.
  List<CalendarRaceEntry> _entriesForChampionship(String championshipId) {
    if (championshipId == _allChampionshipsFilterId) {
      return _allEntries;
    }

    return _allEntries
        .where(
          (CalendarRaceEntry entry) => entry.championshipId == championshipId,
        )
        .toList(growable: false);
  }

  /// Applies a championship filter and keeps the selected date meaningful.
  void _handleChampionshipSelected(String championshipId) {
    if (championshipId == _selectedChampionshipId) {
      return;
    }

    final nextEntries = _entriesForChampionship(championshipId);

    setState(() {
      _selectedChampionshipId = championshipId;
      _selectedDate = resolveCalendarSelection(
        entries: nextEntries,
        today: _today,
        preferredDate: _selectedDate,
      );
    });
  }

  /// Applies date selection from the reusable monthly calendar widget.
  void _handleDateSelected(DateTime date) {
    setState(() => _selectedDate = DateUtils.dateOnly(date));
  }

  /// Toggles archived event visibility in the schedule section.
  void _togglePastEvents() {
    setState(() => _showPastEvents = !_showPastEvents);
  }

  /// Builds loading, error, archive, and upcoming schedule content.
  List<Widget> _buildScheduleContent(_CalendarViewData viewData) {
    if (_loadingError != null) {
      return <Widget>[
        _CalendarInfoCard(
          title: 'Impossible de charger le calendrier',
          subtitle: _loadingError!,
        ),
      ];
    }

    if (_isLoading) {
      return const <Widget>[
        _CalendarInfoCard(
          title: 'Chargement du calendrier',
          subtitle: 'Recuperation des championnats et des courses...',
        ),
      ];
    }

    return <Widget>[
      if (viewData.pastEvents.isNotEmpty) ...[
        _ArchivesSection(
          pastEventsCount: viewData.pastEvents.length,
          isExpanded: _showPastEvents,
          hasSelectedPastEvent: viewData.selectedDateHasPastEvent,
          onToggle: _togglePastEvents,
          child: EventCalendar(
            events: viewData.pastEvents,
            today: _today,
            selectedDate: _selectedDate,
            emptyTitle: 'Aucune course archivee',
            emptySubtitle:
                'Les courses passees apparaitront ici quand il y en aura.',
          ),
        ),
        const SizedBox(height: 20),
      ],
      _SectionHeader(
        title: 'Courses',
        subtitle:
            '${viewData.upcomingEvents.length} a venir ou en cours, ${_formatLongDate(_selectedDate)} en focus.',
      ),
      const SizedBox(height: 12),
      EventCalendar(
        events: viewData.upcomingEvents,
        today: _today,
        selectedDate: _selectedDate,
        emptyTitle: 'Aucune course pour ce filtre',
        emptySubtitle: 'Les prochaines courses apparaitront ici.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final viewData = _CalendarViewData.fromEntries(
      entries: _entriesForChampionship(_selectedChampionshipId),
      selectedDate: _selectedDate,
      today: _today,
    );

    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                      'Calendrier',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 18),
                    _FilterChipRow(
                      allId: _allChampionshipsFilterId,
                      championships: _championships,
                      selectedId: _selectedChampionshipId,
                      onSelected: _handleChampionshipSelected,
                    ),
                    const SizedBox(height: 20),
                    MonthlyCalendar(
                      selectedDate: _selectedDate,
                      initialMonth: _selectedDate,
                      today: _today,
                      isLoading: _isLoading,
                      firstAvailableMonth: viewData.firstAvailableMonth,
                      lastAvailableMonth: viewData.lastAvailableMonth,
                      weekdayLabels: _calendarWeekdayLabels,
                      monthLabelBuilder: _buildMonthLabel,
                      eventsByDate: viewData.eventsByDate,
                      onDateSelected: _handleDateSelected,
                    ),
                    const SizedBox(height: 20),
                    ..._buildScheduleContent(viewData),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Derived calendar data consumed by the route-level layout.
class _CalendarViewData {
  const _CalendarViewData._({
    required this.eventsByDate,
    required this.firstAvailableMonth,
    required this.lastAvailableMonth,
    required this.upcomingEvents,
    required this.pastEvents,
    required this.selectedDateHasPastEvent,
  });

  final Map<DateTime, List<CalendarEventMarker>> eventsByDate;
  final DateTime firstAvailableMonth;
  final DateTime lastAvailableMonth;
  final List<CalendarScheduleEvent> upcomingEvents;
  final List<CalendarScheduleEvent> pastEvents;
  final bool selectedDateHasPastEvent;

  /// Splits raw race entries into marker, bounds, upcoming, and archive views.
  factory _CalendarViewData.fromEntries({
    required List<CalendarRaceEntry> entries,
    required DateTime selectedDate,
    required DateTime today,
  }) {
    final immutableEntries = List<CalendarRaceEntry>.unmodifiable(entries);
    final upcomingEvents = <CalendarScheduleEvent>[];
    final pastEvents = <CalendarScheduleEvent>[];

    for (final CalendarRaceEntry entry in immutableEntries) {
      final event = entry.event;
      if (event.statusAt(today) == CalendarScheduleStatus.past) {
        pastEvents.add(event);
      } else {
        upcomingEvents.add(event);
      }
    }

    return _CalendarViewData._(
      eventsByDate: buildCalendarMarkers(immutableEntries),
      firstAvailableMonth: firstCalendarMonth(immutableEntries),
      lastAvailableMonth: lastCalendarMonth(immutableEntries),
      upcomingEvents: List<CalendarScheduleEvent>.unmodifiable(upcomingEvents),
      pastEvents: List<CalendarScheduleEvent>.unmodifiable(pastEvents),
      selectedDateHasPastEvent: pastEvents.any(
        (CalendarScheduleEvent event) => event.containsDate(selectedDate),
      ),
    );
  }
}

/// Small status card used for loading and error states.
class _CalendarInfoCard extends StatelessWidget {
  const _CalendarInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold()),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Title and subtitle block used above calendar sections.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyBold().copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Collapsible glass card housing the archived event list.
class _ArchivesSection extends StatefulWidget {
  const _ArchivesSection({
    required this.pastEventsCount,
    required this.isExpanded,
    required this.hasSelectedPastEvent,
    required this.onToggle,
    required this.child,
  });

  final int pastEventsCount;
  final bool isExpanded;
  final bool hasSelectedPastEvent;
  final VoidCallback onToggle;
  final Widget child;

  @override
  State<_ArchivesSection> createState() => _ArchivesSectionState();
}

class _ArchivesSectionState extends State<_ArchivesSection>
    with TickerProviderStateMixin {
  late final AnimationController _chevron;
  late final AnimationController _press;
  late final Animation<double> _chevronTurn;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _chevron = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _chevronTurn = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _chevron, curve: Curves.easeOutCubic),
    );

    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _ArchivesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _chevron.forward();
      } else {
        _chevron.reverse();
      }
    }
  }

  @override
  void dispose() {
    _chevron.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightSelected = widget.hasSelectedPastEvent;
    final count = widget.pastEventsCount;

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            widget.onToggle();
          },
          onTapCancel: () => _press.reverse(),
          child: CupertinoLiquidGlass(
            theme: _kArchiveTheme,
            borderRadius: BorderRadius.circular(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header row ──────────────────────────────────────
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 17,
                          color: highlightSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'Archives',
                          style: AppTextStyles.bodyBold(
                            color: highlightSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ).copyWith(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyles.bodyBold(
                              color: AppColors.textSecondary,
                            ).copyWith(fontSize: 11),
                          ),
                        ),
                        if (highlightSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              'Date choisie',
                              style: AppTextStyles.bodyBold(
                                color: AppColors.gold,
                              ).copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                        const Spacer(),
                        RotationTransition(
                          turns: _chevronTurn,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // ── Expandable content ───────────────────────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: widget.isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: widget.child,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter chip row ───────────────────────────────────────────────────────

/// Horizontally scrollable chip row. Selected chip uses liquid glass;
/// unselected chips are subtle transparent pills.
class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.allId,
    required this.championships,
    required this.selectedId,
    required this.onSelected,
  });

  final String allId;
  final List<CalendarChampionship> championships;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterChip(
            label: 'Tout',
            color: AppColors.white,
            isSelected: selectedId == allId,
            onTap: () => onSelected(allId),
          ),
          for (final c in championships) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: c.name,
              color: c.accentColor,
              isSelected: selectedId == c.id,
              onTap: () => onSelected(c.id),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual filter chip: glass when selected, plain pill when not.
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  LiquidGlassThemeData get _chipTheme =>
      LiquidGlassThemeData.dark().copyWith(
        tintOpacity: 0.16,
        blurSigma: 20.0,
        noiseOpacity: 0.0,
        specularOpacity: 0.10,
        vibrancyIntensity: 0.04,
        edgeLightColor: widget.color.withValues(alpha: 0.35),
        edgeShadowColor: widget.color.withValues(alpha: 0.20),
      );

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
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
        child: widget.isSelected
            ? CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoLiquidGlass(
                  theme: _chipTheme,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: _ChipContent(
                      label: widget.label,
                      color: widget.color,
                      isSelected: true,
                    ),
                  ),
                ),
              )
            : AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: _ChipContent(
                  label: widget.label,
                  color: widget.color,
                  isSelected: false,
                ),
              ),
      ),
    );
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    required this.label,
    required this.color,
    required this.isSelected,
  });

  final String label;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodyBold(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ).copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

/// Builds the localized month label displayed by the calendar header.
String _buildMonthLabel(DateTime month) {
  return '${_calendarMonthNames[month.month - 1]} ${month.year}';
}

/// Formats a date for the schedule summary line.
String _formatLongDate(DateTime date) {
  return '${date.day} ${_calendarMonthNamesLowercase[date.month - 1]}';
}
