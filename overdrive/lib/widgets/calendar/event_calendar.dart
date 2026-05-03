/*
##
## OverDrive 2026
## All Technical rights reserved
##
## event_calendar.dart - Event list widget styled for past, ongoing, and upcoming races.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A small marker used by the monthly calendar to show event dots.
class CalendarEventMarker {
  const CalendarEventMarker({this.color = AppColors.gold, this.label});

  final Color color;
  final String? label;
}

enum CalendarScheduleStatus { past, ongoing, upcoming }

/// A data model for one scheduled event in the calendar.
class CalendarScheduleEvent {
  CalendarScheduleEvent({
    required this.id,
    required this.name,
    required this.championshipName,
    required this.startDate,
    required this.endDate,
    this.location,
    this.accentColor = AppColors.gold,
  }) : assert(!endDate.isBefore(startDate));

  final String id;
  final String name;
  final String championshipName;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final Color accentColor;

  CalendarScheduleStatus statusAt(DateTime referenceDate) {
    final currentDate = DateUtils.dateOnly(referenceDate);
    final start = DateUtils.dateOnly(startDate);
    final end = DateUtils.dateOnly(endDate);

    if (end.isBefore(currentDate)) {
      return CalendarScheduleStatus.past;
    }
    if (!start.isAfter(currentDate) && !end.isBefore(currentDate)) {
      return CalendarScheduleStatus.ongoing;
    }

    return CalendarScheduleStatus.upcoming;
  }

  bool containsDate(DateTime date) {
    final currentDate = DateUtils.dateOnly(date);
    final start = DateUtils.dateOnly(startDate);
    final end = DateUtils.dateOnly(endDate);
    return !currentDate.isBefore(start) && !currentDate.isAfter(end);
  }
}

/// A list of event cards used by the calendar screens.
class EventCalendar extends StatelessWidget {
  const EventCalendar({
    required this.events,
    this.today,
    this.selectedDate,
    this.onEventTap,
    this.emptyTitle = 'Aucun evenement sur cette periode',
    this.emptySubtitle = 'Les prochains rendez-vous apparaitront ici.',
    super.key,
  });

  final List<CalendarScheduleEvent> events;
  final DateTime? today;
  final DateTime? selectedDate;
  final ValueChanged<CalendarScheduleEvent>? onEventTap;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
    final currentSelection = selectedDate == null
        ? null
        : DateUtils.dateOnly(selectedDate!);
    final sortedEvents = List<CalendarScheduleEvent>.of(events)
      ..sort((CalendarScheduleEvent left, CalendarScheduleEvent right) {
        return left.startDate.compareTo(right.startDate);
      });

    if (sortedEvents.isEmpty) {
      return _EventCalendarEmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return Column(
      children: [
        for (int index = 0; index < sortedEvents.length; index++) ...[
          _EventCalendarCard(
            event: sortedEvents[index],
            status: sortedEvents[index].statusAt(referenceDate),
            isSelected:
                currentSelection != null &&
                sortedEvents[index].containsDate(currentSelection),
            onTap: onEventTap == null
                ? null
                : () => onEventTap!(sortedEvents[index]),
          ),
          if (index < sortedEvents.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// A single event card displayed inside the event list.
class _EventCalendarCard extends StatelessWidget {
  const _EventCalendarCard({
    required this.event,
    required this.status,
    required this.isSelected,
    this.onTap,
  });

  final CalendarScheduleEvent event;
  final CalendarScheduleStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _EventCardStyle.resolve(
      status: status,
      accentColor: event.accentColor,
      isSelected: isSelected,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            gradient: style.backgroundGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: style.borderColor,
              width: style.borderWidth,
            ),
            boxShadow: style.shadow == null ? null : <BoxShadow>[style.shadow!],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.championshipName,
                          style: AppTextStyles.label(
                            color: event.accentColor.withValues(alpha: 0.92),
                          ).copyWith(fontSize: 10, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(color: style.titleColor)
                              .copyWith(
                                fontSize: 19,
                                height: 1.1,
                                letterSpacing: -0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDateRange(event.startDate, event.endDate),
                          textAlign: TextAlign.end,
                          style: AppTextStyles.bodyBold(
                            color: style.dateColor,
                          ).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        _StatusPill(
                          label: _statusLabel(status),
                          backgroundColor: style.badgeBackgroundColor,
                          foregroundColor: style.badgeForegroundColor,
                          borderColor: style.badgeBorderColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (event.location != null && event.location!.isNotEmpty)
                    _MetaItem(
                      icon: Icons.location_on_outlined,
                      label: event.location!,
                      color: style.metaColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small metadata row item used inside event cards.
class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(
            color: color,
          ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// A pill that shows the status of an event.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyBold(
          color: foregroundColor,
        ).copyWith(fontSize: 12),
      ),
    );
  }
}

/// An empty state shown when there are no events to display.
class _EventCalendarEmptyState extends StatelessWidget {
  const _EventCalendarEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.black],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold()),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A style object used internally by the event card.
class _EventCardStyle {
  const _EventCardStyle({
    required this.backgroundGradient,
    required this.borderColor,
    required this.borderWidth,
    required this.titleColor,
    required this.dateColor,
    required this.metaColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
    required this.badgeBorderColor,
    this.shadow,
  });

  final Gradient backgroundGradient;
  final Color borderColor;
  final double borderWidth;
  final Color titleColor;
  final Color dateColor;
  final Color metaColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;
  final Color badgeBorderColor;
  final BoxShadow? shadow;

  static _EventCardStyle resolve({
    required CalendarScheduleStatus status,
    required Color accentColor,
    required bool isSelected,
  }) {
    switch (status) {
      case CalendarScheduleStatus.past:
        return _EventCardStyle(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.black],
          ),
          borderColor: isSelected
              ? accentColor.withValues(alpha: 0.55)
              : AppColors.border,
          borderWidth: isSelected ? 1.4 : 1,
          titleColor: AppColors.textSecondary,
          dateColor: AppColors.textSecondary,
          metaColor: AppColors.textMuted,
          badgeBackgroundColor: AppColors.white.withValues(alpha: 0.05),
          badgeForegroundColor: AppColors.textSecondary,
          badgeBorderColor: AppColors.white.withValues(alpha: 0.08),
          shadow: isSelected
              ? BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              : null,
        );
      case CalendarScheduleStatus.ongoing:
        return _EventCardStyle(
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceElevated.withValues(alpha: 0.40),
              AppColors.red.withValues(alpha: 0.30),
            ],
          ),
          borderColor: AppColors.red.withValues(alpha: 0.95),
          borderWidth: isSelected ? 1.8 : 1.4,
          titleColor: AppColors.textPrimary,
          dateColor: AppColors.white,
          metaColor: AppColors.textSecondary,
          badgeBackgroundColor: AppColors.red.withValues(alpha: 0.22),
          badgeForegroundColor: AppColors.textPrimary,
          badgeBorderColor: AppColors.red.withValues(alpha: 0.38),
          shadow: BoxShadow(
            color: AppColors.red.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        );
      case CalendarScheduleStatus.upcoming:
        return _EventCardStyle(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.black],
          ),
          borderColor: isSelected
              ? accentColor.withValues(alpha: 0.55)
              : AppColors.border,
          borderWidth: isSelected ? 1.4 : 1,
          titleColor: AppColors.textPrimary,
          dateColor: AppColors.textSecondary,
          metaColor: AppColors.textSecondary,
          badgeBackgroundColor: accentColor.withValues(alpha: 0.14),
          badgeForegroundColor: AppColors.textPrimary,
          badgeBorderColor: accentColor.withValues(alpha: 0.22),
          shadow: isSelected
              ? BoxShadow(
                  color: accentColor.withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              : null,
        );
    }
  }
}

String _formatDateRange(DateTime startDate, DateTime endDate) {
  final start = DateUtils.dateOnly(startDate);
  final end = DateUtils.dateOnly(endDate);

  if (DateUtils.isSameDay(start, end)) {
    return _formatSingleDate(start);
  }

  if (start.year == end.year && start.month == end.month) {
    return '${start.day} - ${end.day} ${_monthLabel(end.month)}';
  }

  return '${_formatSingleDate(start)} - ${_formatSingleDate(end)}';
}

String _formatSingleDate(DateTime date) {
  return '${date.day} ${_monthLabel(date.month)}';
}

String _monthLabel(int month) {
  const monthLabels = <String>[
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

  return monthLabels[month - 1];
}

String _statusLabel(CalendarScheduleStatus status) {
  switch (status) {
    case CalendarScheduleStatus.past:
      return 'Passe';
    case CalendarScheduleStatus.ongoing:
      return 'En cours';
    case CalendarScheduleStatus.upcoming:
      return 'A venir';
  }
}
