import '../../domain/championship/championship.dart';
import '../../domain/championship/driver.dart';
import '../../domain/championship/event.dart';
import '../../domain/championship/session.dart';
import '../../domain/championship/standing.dart';
import '../../domain/championship/team.dart';
import 'championship_dto.dart';

class ChampionshipMapper {
  static Championship fromChampionshipDto(ChampionshipDto dto) {
    return Championship(
      id: dto.id,
      championshipCode: dto.championshipCode,
      name: dto.name,
      provider: dto.provider,
      category: dto.category,
      isActive: dto.isActive,
    );
  }

  static Event fromEventDto(EventDto dto) {
    return Event(
      eventId: dto.eventId,
      championshipId: dto.championshipId,
      championshipCode: dto.championshipCode,
      seasonYear: dto.seasonYear,
      roundNumber: dto.roundNumber,
      name: dto.name,
      officialName: dto.officialName,
      circuit: dto.circuit,
      location: dto.location,
      countryName: dto.countryName,
      countryCode: dto.countryCode,
      externalKey: dto.externalKey,
      startDate: dto.startDate,
      endDate: dto.endDate,
      status: dto.status,
    );
  }

  static Session fromSessionDto(SessionDto dto) {
    return Session(
      sessionId: dto.sessionId,
      eventId: dto.eventId,
      type: dto.type,
      status: dto.status,
      name: dto.name,
      circuit: dto.circuit,
      externalKey: dto.externalKey,
      broadcastUrl: dto.broadcastUrl,
      startTime: dto.startTime,
      endTime: dto.endTime,
    );
  }

  static Driver fromDriverDto(DriverDto dto) {
    return Driver(
      driverNumber: dto.driverNumber,
      fullName: dto.fullName,
      nationality: dto.nationality,
      currentTeamId: dto.currentTeamId,
      championshipCode: dto.championshipCode,
    );
  }

  static Team fromTeamDto(TeamDto dto) {
    return Team(
      teamId: dto.teamId,
      name: dto.name,
      code: dto.code,
      color: dto.color,
    );
  }

  static Standing fromStandingDto(StandingDto dto) {
    return Standing(
      position: dto.position,
      driverNumber: dto.driverNumber,
      teamId: dto.teamId,
      gapToLeader: dto.gapToLeader,
      points: dto.points,
    );
  }
}
