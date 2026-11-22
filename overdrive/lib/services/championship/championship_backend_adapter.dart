import 'package:flutter/material.dart';

import '../../domain/championship/championship.dart' as domain_championship;
import '../../domain/championship/driver.dart' as domain_driver;
import '../../domain/championship/event.dart' as domain_event;
import '../../domain/championship/session.dart' as domain_session;
import '../../domain/championship/standing.dart' as domain_standing;
import '../../domain/championship/team.dart' as domain_team;

import 'championship_circuit.dart';
import 'championship_data.dart';
import 'championship_enums.dart';
import 'championship_session.dart';
import 'championship_standing.dart';
import 'championship_live_entry.dart';

class ChampionshipBackendAdapter {
  const ChampionshipBackendAdapter();

  ChampionshipData toChampionshipData({
    required domain_championship.Championship championship,
    domain_event.Event? event,
    List<domain_session.Session> sessions = const [],
    List<domain_standing.Standing> standings = const [],
    List<domain_driver.Driver> drivers = const [],
    List<domain_team.Team> teams = const [],
  }) {
    return ChampionshipData(
      id: championship.championshipCode,
      name: championship.name,
      accentColor: _parseColor(championship.category),
      state: _mapState(event: event, sessions: sessions),
      liveGroups: _mapLiveGroups(
        standings: standings,
        drivers: drivers,
        teams: teams,
      ),
      standings: _mapStandings(
        standings: standings,
        drivers: drivers,
        teams: teams,
      ),
      schedule: _mapSessions(sessions),
      circuit: null,
      weather: null,
      nextEvent: event == null
          ? null
          : ChampionshipNextEvent(
              name: event.name,
              location: event.location ?? event.countryName ?? '',
              startsAt: event.startDate,
            ),
      replays: const ChampionshipReplays(label: 'Replays'),
      headline: event?.officialName ?? event?.name,
    );
  }

  List<ChampionshipSession> _mapSessions(
    List<domain_session.Session> sessions,
  ) {
    return sessions.map((session) {
      return ChampionshipSession(
        name: session.name ?? session.type,
        scheduledAt: session.startTime ?? session.endTime ?? DateTime.now(),
        status: _mapSessionStatus(session.status),
      );
    }).toList();
  }

  List<ChampionshipStandingTable> _mapStandings({
    required List<domain_standing.Standing> standings,
    required List<domain_driver.Driver> drivers,
    required List<domain_team.Team> teams,
  }) {
    final driverByNumber = {
      for (final driver in drivers) driver.driverNumber: driver,
    };

    final teamById = {for (final team in teams) team.teamId: team};

    final entries = standings.where((standing) => standing.position > 0).map((
      standing,
    ) {
      final driver = standing.driverNumber == null
          ? null
          : driverByNumber[standing.driverNumber];

      final team = standing.teamId == null ? null : teamById[standing.teamId];

      return ChampionshipStandingEntry(
        position: standing.position,
        name:
            driver?.fullName ??
            team?.name ??
            (standing.driverNumber == null
                ? 'Unknown'
                : 'Driver ${standing.driverNumber}'),
        points: (standing.points ?? 0).round(),
        teamName: team?.name,
      );
    }).toList();

    return [
      ChampionshipStandingTable(
        type: StandingType.drivers,
        label: 'Drivers',
        entries: entries,
      ),
    ];
  }

  ChampionshipState _mapState({
    required domain_event.Event? event,
    required List<domain_session.Session> sessions,
  }) {
    if (sessions.any(
      (session) =>
          session.status.toLowerCase() == 'live' ||
          session.status.toLowerCase() == 'in_progress',
    )) {
      return ChampionshipState.liveSession;
    }

    if (event != null) {
      return ChampionshipState.eventWeekend;
    }

    return ChampionshipState.offSeason;
  }

  SessionStatus _mapSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finished':
        return SessionStatus.completed;
      case 'live':
      case 'in_progress':
        return SessionStatus.live;
      default:
        return SessionStatus.upcoming;
    }
  }

  Color _parseColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'single-seater':
        return const Color(0xFFE10600);
      case 'endurance':
        return const Color(0xFF00A3E0);
      case 'motorcycle':
        return const Color(0xFF00A650);
      default:
        return const Color(0xFFE10600);
    }
  }

  List<ChampionshipLiveGroup> _mapLiveGroups({
    required List<domain_standing.Standing> standings,
    required List<domain_driver.Driver> drivers,
    required List<domain_team.Team> teams,
  }) {
    if (standings.isEmpty) {
      return const [];
    }

    final driverByNumber = {
      for (final driver in drivers) driver.driverNumber: driver,
    };

    final teamById = {for (final team in teams) team.teamId: team};

    final sortedStandings =
        standings.where((standing) => standing.position > 0).toList()
          ..sort((a, b) => a.position.compareTo(b.position));

    final entries = sortedStandings.map((standing) {
      final driver = standing.driverNumber == null
          ? null
          : driverByNumber[standing.driverNumber];

      final team = standing.teamId == null ? null : teamById[standing.teamId];

      return ChampionshipLiveEntry(
        position: standing.position,
        name: driver?.fullName ?? '—',
        teamName: team?.name ?? '—',
        gap: standing.gapToLeader ?? '—',
        lap: 0,
        teamColor: _parseTeamColor(team?.color),
      );
    }).toList();

    if (entries.length < 3) {
      return const [];
    }

    return [ChampionshipLiveGroup(label: '', entries: entries)];
  }

  Color? _parseTeamColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = value.replaceFirst('#', '').trim();
    final hex = int.tryParse(normalized, radix: 16);

    if (hex == null) {
      return null;
    }

    return Color(normalized.length == 6 ? 0xFF000000 | hex : hex);
  }
}
