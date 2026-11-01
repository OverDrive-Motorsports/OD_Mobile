import 'championship.dart';
import 'championship_repository.dart';
import 'driver.dart';
import 'event.dart';
import 'session.dart';
import 'standing.dart';
import 'team.dart';

class GetChampionships {
  const GetChampionships(this.repository);

  final ChampionshipRepository repository;

  Future<List<Championship>> call() => repository.getChampionships();
}

class GetEvent {
  const GetEvent(this.repository);

  final ChampionshipRepository repository;

  Future<Event> call(String eventId) => repository.getEvent(eventId);
}

class GetEventsByChampionship {
  const GetEventsByChampionship(this.repository);

  final ChampionshipRepository repository;

  Future<List<Event>> call(String championshipCode, {int? season}) =>
      repository.getEventsByChampionship(championshipCode, season: season);
}

class GetEventSessions {
  const GetEventSessions(this.repository);

  final ChampionshipRepository repository;

  Future<List<Session>> call(String eventId, {String? type}) =>
      repository.getEventSessions(eventId, type: type);
}

class GetSession {
  const GetSession(this.repository);

  final ChampionshipRepository repository;

  Future<Session> call(String sessionId) => repository.getSession(sessionId);
}

class GetSessionStandings {
  const GetSessionStandings(this.repository);

  final ChampionshipRepository repository;

  Future<List<Standing>> call(String sessionId, {int? driverNumber}) =>
      repository.getSessionStandings(sessionId, driverNumber: driverNumber);
}

class GetSessionDrivers {
  const GetSessionDrivers(this.repository);

  final ChampionshipRepository repository;

  Future<List<Driver>> call(String sessionId, {String? teamId}) =>
      repository.getSessionDrivers(sessionId, teamId: teamId);
}

class GetSessionTeams {
  const GetSessionTeams(this.repository);

  final ChampionshipRepository repository;

  Future<List<Team>> call(String sessionId) =>
      repository.getSessionTeams(sessionId);
}

class GetDriverProfile {
  const GetDriverProfile(this.repository);

  final ChampionshipRepository repository;

  Future<Driver> call(int driverNumber, {String? championshipCode}) =>
      repository.getDriverProfile(driverNumber, championshipCode: championshipCode);
}

class GetSessionDataset {
  const GetSessionDataset(this.repository);

  final ChampionshipRepository repository;

  Future<Map<String, dynamic>> call(String sessionId, String dataset) =>
      repository.getSessionDataset(sessionId, dataset);
}
