import '../../data/championship/championship_gateway_repository.dart';
import '../../domain/championship/championship_repository.dart';
import '../../domain/championship/championship_use_cases.dart';

class ChampionshipDependencyProvider {
  ChampionshipDependencyProvider({ChampionshipRepository? repository})
    : repository = repository ?? ChampionshipGatewayRepository();

  final ChampionshipRepository repository;

  GetChampionships get getChampionshipsUseCase => GetChampionships(repository);

  GetEvent get getEventUseCase => GetEvent(repository);

  GetEventsByChampionship get getEventsByChampionshipUseCase =>
      GetEventsByChampionship(repository);

  GetEventSessions get getEventSessionsUseCase => GetEventSessions(repository);

  GetSession get getSessionUseCase => GetSession(repository);

  GetSessionStandings get getSessionStandingsUseCase =>
      GetSessionStandings(repository);

  GetSessionDrivers get getSessionDriversUseCase =>
      GetSessionDrivers(repository);

  GetSessionTeams get getSessionTeamsUseCase => GetSessionTeams(repository);

  GetDriverProfile get getDriverProfileUseCase => GetDriverProfile(repository);

  GetSessionDataset get getSessionDatasetUseCase =>
      GetSessionDataset(repository);
}
