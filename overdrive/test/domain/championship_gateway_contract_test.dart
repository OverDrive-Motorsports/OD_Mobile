import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/domain/championship/championship.dart';
import 'package:overdrive/domain/championship/championship_repository.dart';
import 'package:overdrive/domain/championship/championship_use_cases.dart';
import 'package:overdrive/domain/championship/driver.dart';
import 'package:overdrive/domain/championship/event.dart';
import 'package:overdrive/domain/championship/session.dart';
import 'package:overdrive/domain/championship/standing.dart';
import 'package:overdrive/domain/championship/team.dart';

void main() {
  group('Gateway Championship contract', () {
    test('Championship stores gateway response fields', () {
      const championship = Championship(
        championshipCode: 'f1',
        name: 'Formula 1',
        provider: 'openf1',
        season: 2026,
        championshipsCode: 'XX',
      );

      expect(championship.championshipCode, 'f1');
      expect(championship.name, 'Formula 1');
      expect(championship.provider, 'openf1');
      expect(championship.season, 2026);
      expect(championship.championshipsCode, 'XX');
    });

    test('Event stores eventId and session metadata fields', () {
      final event = Event(
        eventId: 'evt_1255',
        championshipCode: 'f1',
        name: 'Bahrain Grand Prix',
        circuit: 'Bahrain International Circuit',
        location: 'Sakhir',
        startDate: DateTime(2026, 3, 6),
        endDate: DateTime(2026, 3, 8),
        status: 'finished',
      );

      expect(event.eventId, 'evt_1255');
      expect(event.championshipCode, 'f1');
      expect(event.circuit, 'Bahrain International Circuit');
      expect(event.location, 'Sakhir');
      expect(event.status, 'finished');
    });

    test('Session stores gateway fields and weatherAtStart', () {
      final session = Session(
        sessionId: 'sess_9998',
        eventId: 'evt_1255',
        type: 'race',
        status: 'finished',
        circuit: 'Bahrain International Circuit',
        startTime: DateTime.parse('2026-03-08T15:00:00Z'),
        endTime: DateTime.parse('2026-03-08T17:00:00Z'),
        weatherAtStart: WeatherAtStart(
          airTemperature: 28.4,
          trackTemperature: 34.1,
          rainfall: false,
        ),
      );

      expect(session.sessionId, 'sess_9998');
      expect(session.type, 'race');
      expect(session.status, 'finished');
      expect(session.weatherAtStart?.airTemperature, 28.4);
      expect(session.weatherAtStart?.rainfall, false);
    });

    test('Driver and Team follow gateway fields', () {
      const driver = Driver(
        driverNumber: 63,
        fullName: 'George Russell',
        teamId: 'mercedes',
        teamName: 'Mercedes',
        nationality: 'GBR',
      );

      const team = Team(teamId: 'mercedes', name: 'Mercedes', color: '#27F4D2');

      expect(driver.driverNumber, 63);
      expect(driver.fullName, 'George Russell');
      expect(team.teamId, 'mercedes');
      expect(team.color, '#27F4D2');
    });

    test('Standing stores the generic standings contract', () {
      const standing = Standing(
        position: 1,
        driverNumber: 63,
        teamId: 'mercedes',
        gapToLeader: '0.000',
        points: 25,
      );

      expect(standing.position, 1);
      expect(standing.driverNumber, 63);
      expect(standing.teamId, 'mercedes');
      expect(standing.points, 25);
      expect(standing.gapToLeader, '0.000');
    });

    test('Championship failure maps gateway errors to typed exceptions', () {
      final failure = ChampionshipFailure.fromDio(
        DioException(
          requestOptions: RequestOptions(
            path: '/v1/championship/championships',
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/v1/championship/championships',
            ),
            statusCode: 401,
            data: {'error': 'unauthorized'},
          ),
        ),
      );

      expect(failure, isA<UnauthorizedChampionshipFailure>());
      expect(failure.message, 'unauthorized');
    });

    test('Additional championship use cases expose repository accessors', () async {
      final repo = _FakeChampionshipRepository();

      final getEvent = GetEvent(repo);
      final getSession = GetSession(repo);
      final getDriverProfile = GetDriverProfile(repo);
      final getSessionDataset = GetSessionDataset(repo);

      await expectLater(getEvent.call('evt_1255'), completion(isA<Event>()));
      await expectLater(getSession.call('sess_9998'), completion(isA<Session>()));
      await expectLater(
        getDriverProfile.call(63, championshipCode: 'f1'),
        completion(isA<Driver>()),
      );
      await expectLater(
        getSessionDataset.call('sess_9998', 'session_result'),
        completion(isA<Map<String, dynamic>>()),
      );
    });
  });
}

class _FakeChampionshipRepository implements ChampionshipRepository {
  @override
  Future<List<Championship>> getChampionships() async => const [];

  @override
  Future<List<Event>> getEventsByChampionship(String championshipCode, {int? season}) async => const [];

  @override
  Future<Event> getEvent(String eventId) async => Event(
    eventId: 'evt_1255',
    championshipCode: 'f1',
    name: 'Bahrain Grand Prix',
    startDate: DateTime(2026, 3, 6),
    endDate: DateTime(2026, 3, 8),
  );

  @override
  Future<List<Session>> getEventSessions(String eventId, {String? type}) async => const [];

  @override
  Future<Session> getSession(String sessionId) async => const Session(
    sessionId: 'sess_9998',
    eventId: 'evt_1255',
    type: 'race',
    status: 'finished',
  );

  @override
  Future<List<Driver>> getSessionDrivers(String sessionId, {String? teamId}) async => const [];

  @override
  Future<List<Team>> getSessionTeams(String sessionId) async => const [];

  @override
  Future<List<Standing>> getSessionStandings(String sessionId, {int? driverNumber}) async => const [];

  @override
  Future<Driver> getDriverProfile(int driverNumber, {String? championshipCode}) async => const Driver(
    driverNumber: 63,
    fullName: 'George Russell',
  );

  @override
  Future<Map<String, dynamic>> getSessionDataset(String sessionId, String dataset) async => {'ok': true};
}
