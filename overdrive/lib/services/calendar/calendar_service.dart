/*
##
## OverDrive 2026
## All Technical rights reserved
##
## calendar_service.dart - Calendar service, domain models, and mapping helpers.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/calendar/event_calendar.dart';
import 'calendar_mock_backend.dart';

class CalendarChampionship {
  const CalendarChampionship({
    required this.id,
    required this.name,
    required this.accentColor,
  });

  final String id;
  final String name;
  final Color accentColor;
}

class CalendarRaceEntry {
  const CalendarRaceEntry({required this.championshipId, required this.event});

  final String championshipId;
  final CalendarScheduleEvent event;
}

class CalendarService {
  CalendarService({CalendarMockBackend? backend})
    : _backend = backend ?? CalendarMockBackend.instance;

  static final CalendarService instance = CalendarService();

  final CalendarMockBackend _backend;

  Future<List<CalendarChampionship>> getChampionships({
    DateTime? referenceDate,
  }) async {
    final records = await _backend.fetchChampionships();
    return records.map(_mapChampionshipRecord).toList(growable: false);
  }

  Future<List<CalendarRaceEntry>> getSchedule({DateTime? referenceDate}) async {
    final seasonYear = calendarReferenceToday(referenceDate).year;
    final entries =
        (await _backend.fetchSchedule(
          seasonYear: seasonYear,
        )).map(_mapRaceRecord).toList(growable: false)..sort(
          (CalendarRaceEntry left, CalendarRaceEntry right) =>
              left.event.startDate.compareTo(right.event.startDate),
        );
    return List<CalendarRaceEntry>.unmodifiable(entries);
  }

  CalendarChampionship _mapChampionshipRecord(
    CalendarMockChampionshipRecord record,
  ) {
    return CalendarChampionship(
      id: record.id,
      name: record.name,
      accentColor: _parseColor(record.accentHex),
    );
  }

  CalendarRaceEntry _mapRaceRecord(CalendarMockRaceRecord record) {
    final startDate = DateTime.tryParse(record.startDateIso);
    final endDate = DateTime.tryParse(record.endDateIso);

    if (startDate == null || endDate == null) {
      throw const CalendarServiceException('Invalid calendar dates received');
    }

    return CalendarRaceEntry(
      championshipId: record.championshipId,
      event: CalendarScheduleEvent(
        id: record.id,
        name: record.name,
        championshipName: record.championshipName,
        startDate: startDate,
        endDate: endDate,
        location: record.location,
        accentColor: _parseColor(record.accentHex),
      ),
    );
  }

  Color _parseColor(String value) {
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length != 6) {
      return AppColors.gold;
    }

    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return AppColors.gold;
    }

    return Color(0xFF000000 | parsed);
  }
}

DateTime calendarReferenceToday([DateTime? referenceDate]) =>
    DateUtils.dateOnly(referenceDate ?? DateTime.now());

DateTime resolveCalendarSelection({
  required List<CalendarRaceEntry> entries,
  required DateTime today,
  DateTime? preferredDate,
}) {
  if (entries.isEmpty) {
    return DateUtils.dateOnly(preferredDate ?? today);
  }

  final normalizedPreferred = DateUtils.dateOnly(preferredDate ?? today);
  final matchingPreferred = entries.where(
    (CalendarRaceEntry entry) => entry.event.containsDate(normalizedPreferred),
  );
  if (matchingPreferred.isNotEmpty) {
    return normalizedPreferred;
  }

  final referenceDate = DateUtils.dateOnly(today);
  for (final CalendarRaceEntry entry in entries) {
    if (!DateUtils.dateOnly(entry.event.endDate).isBefore(referenceDate)) {
      return DateUtils.dateOnly(entry.event.startDate);
    }
  }

  return DateUtils.dateOnly(entries.last.event.startDate);
}

DateTime firstCalendarMonth(List<CalendarRaceEntry> entries) {
  if (entries.isEmpty) {
    final today = calendarReferenceToday();
    return DateTime(today.year, today.month);
  }

  final firstEvent = entries
      .map((CalendarRaceEntry entry) => entry.event)
      .reduce(
        (CalendarScheduleEvent left, CalendarScheduleEvent right) =>
            left.startDate.isBefore(right.startDate) ? left : right,
      );
  return DateTime(firstEvent.startDate.year, firstEvent.startDate.month);
}

DateTime lastCalendarMonth(List<CalendarRaceEntry> entries) {
  if (entries.isEmpty) {
    final today = calendarReferenceToday();
    return DateTime(today.year, today.month);
  }

  final lastEvent = entries
      .map((CalendarRaceEntry entry) => entry.event)
      .reduce(
        (CalendarScheduleEvent left, CalendarScheduleEvent right) =>
            left.endDate.isAfter(right.endDate) ? left : right,
      );
  return DateTime(lastEvent.endDate.year, lastEvent.endDate.month);
}

Map<DateTime, List<CalendarEventMarker>> buildCalendarMarkers(
  List<CalendarRaceEntry> entries,
) {
  final markersByDate = <DateTime, List<CalendarEventMarker>>{};

  for (final CalendarRaceEntry entry in entries) {
    DateTime cursor = DateUtils.dateOnly(entry.event.startDate);
    final endDate = DateUtils.dateOnly(entry.event.endDate);

    while (!cursor.isAfter(endDate)) {
      markersByDate
          .putIfAbsent(cursor, () => <CalendarEventMarker>[])
          .add(
            CalendarEventMarker(
              color: entry.event.accentColor,
              label: entry.event.championshipName,
            ),
          );
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  return markersByDate;
}

class CalendarServiceException implements Exception {
  const CalendarServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
