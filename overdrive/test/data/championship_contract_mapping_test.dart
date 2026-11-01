import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/data/championship/championship_dto.dart';
import 'package:overdrive/data/championship/championship_mappers.dart';

void main() {
  group('Championship DTO contract mapping', () {
    test('maps current gateway payload fields to domain models', () {
      final championship = ChampionshipDto.fromJson({
        'id': 'openf1:championship:f1',
        'championshipCode': 'f1',
        'name': 'Formula 1',
        'provider': 'openf1',
        'category': 'single-seater',
        'isActive': true,
      });

      final mappedChampionship = ChampionshipMapper.fromChampionshipDto(championship);

      expect(mappedChampionship.id, 'openf1:championship:f1');
      expect(mappedChampionship.championshipCode, 'f1');
      expect(mappedChampionship.name, 'Formula 1');
      expect(mappedChampionship.provider, 'openf1');
      expect(mappedChampionship.category, 'single-seater');
      expect(mappedChampionship.isActive, true);

      final event = EventDto.fromJson({
        'eventId': 'evt-1',
        'championshipCode': 'f1',
        'seasonYear': 2026,
        'roundNumber': 1,
        'name': 'Monaco GP',
        'officialName': 'Monaco Grand Prix',
        'circuit': 'Circuit de Monaco',
        'location': 'Monaco',
        'countryName': 'Monaco',
        'countryCode': 'MC',
        'status': 'scheduled',
        'startDate': '2026-05-23T12:00:00Z',
        'endDate': '2026-05-25T18:00:00Z',
      });

      final mappedEvent = ChampionshipMapper.fromEventDto(event);
      expect(mappedEvent.eventId, 'evt-1');
      expect(mappedEvent.championshipCode, 'f1');
      expect(mappedEvent.seasonYear, 2026);
      expect(mappedEvent.roundNumber, 1);
      expect(mappedEvent.officialName, 'Monaco Grand Prix');
      expect(mappedEvent.countryName, 'Monaco');
      expect(mappedEvent.countryCode, 'MC');
      expect(mappedEvent.status, 'scheduled');

      final session = SessionDto.fromJson({
        'sessionId': 'sess-1',
        'eventId': 'evt-1',
        'type': 'race',
        'status': 'scheduled',
        'name': 'Race',
        'circuit': 'Circuit de Monaco',
        'broadcastUrl': 'https://example.com/broadcast',
        'startTime': '2026-05-25T14:00:00Z',
        'endTime': '2026-05-25T16:00:00Z',
      });

      final mappedSession = ChampionshipMapper.fromSessionDto(session);
      expect(mappedSession.sessionId, 'sess-1');
      expect(mappedSession.eventId, 'evt-1');
      expect(mappedSession.type, 'race');
      expect(mappedSession.name, 'Race');
      expect(mappedSession.broadcastUrl, 'https://example.com/broadcast');

      final driver = DriverDto.fromJson({
        'driverNumber': 1,
        'fullName': 'Max Verstappen',
        'nationality': 'NED',
        'currentTeamId': 'openf1:f1:team:red-bull-racing',
        'championshipCode': 'f1',
      });

      final mappedDriver = ChampionshipMapper.fromDriverDto(driver);
      expect(mappedDriver.driverNumber, 1);
      expect(mappedDriver.fullName, 'Max Verstappen');
      expect(mappedDriver.nationality, 'NED');
      expect(mappedDriver.currentTeamId, 'openf1:f1:team:red-bull-racing');
      expect(mappedDriver.championshipCode, 'f1');

      final team = TeamDto.fromJson({
        'teamId': 'team-redbull',
        'name': 'Red Bull Racing',
        'code': 'RBR',
        'color': '#1E41FF',
      });

      final mappedTeam = ChampionshipMapper.fromTeamDto(team);
      expect(mappedTeam.teamId, 'team-redbull');
      expect(mappedTeam.name, 'Red Bull Racing');
      expect(mappedTeam.code, 'RBR');
      expect(mappedTeam.color, '#1E41FF');

      final standing = StandingDto.fromJson({
        'position': 1,
        'driverNumber': 1,
        'teamId': 'team-redbull',
        'gapToLeader': '0.000s',
        'points': 25.5,
      });

      final mappedStanding = ChampionshipMapper.fromStandingDto(standing);
      expect(mappedStanding.position, 1);
      expect(mappedStanding.driverNumber, 1);
      expect(mappedStanding.teamId, 'team-redbull');
      expect(mappedStanding.gapToLeader, '0.000s');
      expect(mappedStanding.points, 25.5);
    });
  });
}
