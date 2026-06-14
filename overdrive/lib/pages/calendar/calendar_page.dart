/*
##
## OverDrive 2026
## All Technical rights reserved
##
## calendar_page.dart - Calendar screen with championship filters and event cards.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/calendar/calendar_service.dart';
import '../../widgets/calendar/event_calendar.dart';
import '../../widgets/calendar/monthly_calendar.dart';
import '../../widgets/glass_pill.dart';
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
        _PastEventsInlineToggle(
          pastEventsCount: viewData.pastEvents.length,
          isExpanded: _showPastEvents,
          hasSelectedPastEvent: viewData.selectedDateHasPastEvent,
          onTap: _togglePastEvents,
        ),
        if (_showPastEvents) ...[
          const SizedBox(height: 12),
          EventCalendar(
            events: viewData.pastEvents,
            today: _today,
            selectedDate: _selectedDate,
            emptyTitle: 'Aucune course archivee',
            emptySubtitle:
                'Les courses passees apparaitront ici quand il y en aura.',
          ),
          const SizedBox(height: 20),
        ] else
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
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Championships',
                      subtitle: 'Filtre les 10 courses par serie.',
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _ChampionshipFilterChip(
                            label: 'All',
                            accentColor: AppColors.white,
                            isSelected:
                                _selectedChampionshipId ==
                                _allChampionshipsFilterId,
                            onTap: () => _handleChampionshipSelected(
                              _allChampionshipsFilterId,
                            ),
                          ),
                          for (final CalendarChampionship championship
                              in _championships) ...[
                            const SizedBox(width: 10),
                            _ChampionshipFilterChip(
                              label: championship.name,
                              accentColor: championship.accentColor,
                              isSelected:
                                  championship.id == _selectedChampionshipId,
                              onTap: () =>
                                  _handleChampionshipSelected(championship.id),
                            ),
                          ],
                        ],
                      ),
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
          ],
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

/// Inline control that expands or collapses archived events.
class _PastEventsInlineToggle extends StatelessWidget {
  const _PastEventsInlineToggle({
    required this.pastEventsCount,
    required this.isExpanded,
    required this.hasSelectedPastEvent,
    required this.onTap,
  });

  final int pastEventsCount;
  final bool isExpanded;
  final bool hasSelectedPastEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Text(
              'Archives',
              style: AppTextStyles.bodyBold(
                color: hasSelectedPastEvent
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ).copyWith(fontSize: 13),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasSelectedPastEvent
                    ? 'Une course passee correspond a la date choisie.'
                    : '$pastEventsCount course${pastEventsCount > 1 ? 's' : ''} passee${pastEventsCount > 1 ? 's' : ''}.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 10),
            GlassPill(
              highlighted: isExpanded,
              backgroundColor: isExpanded
                  ? AppColors.white.withValues(alpha: 0.14)
                  : AppColors.white.withValues(alpha: 0.06),
              borderColor: AppColors.white.withValues(alpha: 0.10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Masquer' : 'Voir',
                    style: AppTextStyles.bodyBold().copyWith(fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal filter chip for championship selection.
class _ChampionshipFilterChip extends StatelessWidget {
  const _ChampionshipFilterChip({
    required this.label,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: GlassPill(
          highlighted: isSelected,
          backgroundColor: isSelected
              ? accentColor.withValues(alpha: 0.18)
              : AppColors.white.withValues(alpha: 0.08),
          borderColor: isSelected
              ? accentColor.withValues(alpha: 0.36)
              : AppColors.white.withValues(alpha: 0.10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyBold(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ).copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
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
