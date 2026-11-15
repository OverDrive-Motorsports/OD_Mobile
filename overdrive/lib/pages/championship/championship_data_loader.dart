
import '../../core/di/championship_di.dart';
import '../../domain/championship/championship.dart';
import '../../domain/championship/event.dart';
import '../../domain/championship/session.dart';
import '../../services/championship/championship_backend_adapter.dart';
import '../../services/championship/championship_data.dart';
import '../../domain/championship/standing.dart';
import '../../domain/championship/driver.dart';
import '../../domain/championship/team.dart';

class ChampionshipDataLoader {
  ChampionshipDataLoader({
    ChampionshipDependencyProvider? dependencies,
    ChampionshipBackendAdapter adapter =
        const ChampionshipBackendAdapter(),
  }) : _dependencies =
           dependencies ?? ChampionshipDependencyProvider(),
       _adapter = adapter;

  final ChampionshipDependencyProvider _dependencies;
  final ChampionshipBackendAdapter _adapter;

  /// Loads the selected championship and converts the API data
  /// into the model consumed by ChampionshipPage.
  Future<ChampionshipData> load(String championshipCode) async {
    final championships =
        await _dependencies.getChampionshipsUseCase();

    final championship = _findChampionship(
      championships,
      championshipCode,
    );

    final events = await _dependencies
        .getEventsByChampionshipUseCase(championship.championshipCode);

    final event = _selectEvent(events);

    if (event == null) {
      return _adapter.toChampionshipData(
        championship: championship,
      );
    }

    final sessions = await _dependencies
        .getEventSessionsUseCase(event.eventId);

    final session = _selectSession(sessions);

    if (session == null) {
      return _adapter.toChampionshipData(
        championship: championship,
        event: event,
      );
    }


final List<Standing> standings = await _tryLoad<Standing>(
    () => _dependencies
        .getSessionStandingsUseCase(session.sessionId),
    const <Standing>[],
);

final List<Driver> drivers = await _tryLoad<Driver>(
    () => _dependencies
        .getSessionDriversUseCase(session.sessionId),
    const <Driver>[],
);

final List<Team> teams = await _tryLoad<Team>(
    () => _dependencies
        .getSessionTeamsUseCase(session.sessionId),
    const <Team>[],
);

return _adapter.toChampionshipData(
    championship: championship,
    event: event,
    sessions: sessions,
    standings: standings,
    drivers: drivers,
    teams: teams,
);


  }

 Championship _findChampionship(
  List<Championship> championships,
  String code,
) {
  final normalizedCode = code.toLowerCase();

  for (final championship in championships) {
    if (championship.championshipCode.toLowerCase() ==
        normalizedCode) {
      return championship;
    }
  }

  // Compatibility between the legacy UI identifier and the API code.
  final aliases = <String, String>{
    'formula_1': 'f1',
  };

  final apiCode = aliases[normalizedCode];

  if (apiCode != null) {
    for (final championship in championships) {
      if (championship.championshipCode.toLowerCase() == apiCode) {
        return championship;
      }
    }
  }

  throw StateError(
    'Championship "$code" was not found in the Gateway response.',
  );
}

  Event? _selectEvent(List<Event> events) {
    if (events.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final upcoming = events
        .where((event) => !event.endDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (upcoming.isNotEmpty) {
      return upcoming.first;
    }

    final past = [...events]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return past.first;
  }

  Session? _selectSession(List<Session> sessions) {
    if (sessions.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final upcoming = sessions
        .where(
          (session) =>
              session.startTime != null &&
              !session.startTime!.isBefore(now),
        )
        .toList()
      ..sort(
        (a, b) => a.startTime!.compareTo(b.startTime!),
      );

    if (upcoming.isNotEmpty) {
      return upcoming.first;
    }

    return sessions.first;
  }

  Future<List<T>> _tryLoad<T>(
    Future<List<T>> Function() request,
    List<T> fallback,
  ) async {
    try {
      return await request();
    } catch (_) {
      // Optional data, such as standings, may not be available yet.
      return fallback;
    }
  }
}
