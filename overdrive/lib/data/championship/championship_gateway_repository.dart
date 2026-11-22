import 'package:dio/dio.dart';

import '../../domain/championship/championship.dart';
import '../../domain/championship/championship_repository.dart';
import '../../domain/championship/driver.dart';
import '../../domain/championship/event.dart';
import '../../domain/championship/session.dart';
import '../../domain/championship/standing.dart';
import '../../domain/championship/team.dart';
import 'championship_dto.dart';
import 'championship_gateway_client.dart';
import 'championship_mappers.dart';

class ChampionshipGatewayRepository implements ChampionshipRepository {
  ChampionshipGatewayRepository({ChampionshipGatewayClient? client})
    : _client = client ?? ChampionshipGatewayClient();

  final ChampionshipGatewayClient _client;

  @override
  Future<List<Championship>> getChampionships() async {
    try {
      final response = await _client.get('/championships');
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Championship>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromChampionshipDto(
          ChampionshipDto.fromJson(map),
        );
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid championship payload');
    }
  }

  @override
  Future<List<Event>> getEventsByChampionship(
    String championshipCode, {
    int? season,
  }) async {
    try {
      final response = await _client.get(
        '/championships/$championshipCode/events',
        queryParameters: season == null ? null : {'season': season},
      );
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Event>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromEventDto(EventDto.fromJson(map));
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid event payload');
    }
  }

  @override
  Future<Event> getEvent(String eventId) async {
    try {
      final response = await _client.get('/events/$eventId');
      final payload = response.data;
      if (payload is! Map) {
        throw const UnknownChampionshipFailure('Invalid event payload');
      }
      return ChampionshipMapper.fromEventDto(
        EventDto.fromJson(Map<String, dynamic>.from(payload)),
      );
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (error) {
      if (error is ChampionshipFailure) {
        rethrow;
      }
      throw const UnknownChampionshipFailure('Invalid event payload');
    }
  }

  @override
  Future<List<Session>> getEventSessions(String eventId, {String? type}) async {
    try {
      final response = await _client.get(
        '/events/$eventId/sessions',
        queryParameters: type == null ? null : {'type': type},
      );
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Session>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromSessionDto(SessionDto.fromJson(map));
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid session payload');
    }
  }

  @override
  Future<Session> getSession(String sessionId) async {
    try {
      final response = await _client.get('/sessions/$sessionId');
      final payload = response.data;
      if (payload is! Map) {
        throw const UnknownChampionshipFailure('Invalid session payload');
      }
      return ChampionshipMapper.fromSessionDto(
        SessionDto.fromJson(Map<String, dynamic>.from(payload)),
      );
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (error) {
      if (error is ChampionshipFailure) {
        rethrow;
      }
      throw const UnknownChampionshipFailure('Invalid session payload');
    }
  }

  @override
  Future<List<Driver>> getSessionDrivers(
    String sessionId, {
    String? teamId,
  }) async {
    try {
      final response = await _client.get(
        '/sessions/$sessionId/drivers',
        queryParameters: teamId == null ? null : {'teamId': teamId},
      );
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Driver>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromDriverDto(DriverDto.fromJson(map));
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid driver payload');
    }
  }

  @override
  Future<List<Team>> getSessionTeams(String sessionId) async {
    try {
      final response = await _client.get('/sessions/$sessionId/teams');
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Team>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromTeamDto(TeamDto.fromJson(map));
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid team payload');
    }
  }

  @override
  Future<List<Standing>> getSessionStandings(
    String sessionId, {
    int? driverNumber,
  }) async {
    try {
      final response = await _client.get(
        '/sessions/$sessionId/standings',
        queryParameters: driverNumber == null
            ? null
            : {'driverNumber': driverNumber},
      );
      final payload = response.data;
      final list = payload is List ? payload : const <dynamic>[];

      return list.map<Standing>((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : const <String, dynamic>{};
        return ChampionshipMapper.fromStandingDto(StandingDto.fromJson(map));
      }).toList();
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (_) {
      throw const UnknownChampionshipFailure('Invalid standing payload');
    }
  }

  @override
  Future<Driver> getDriverProfile(
    int driverNumber, {
    String? championshipCode,
  }) async {
    try {
      final response = await _client.get(
        '/drivers/$driverNumber/profile',
        queryParameters: championshipCode == null
            ? null
            : {'championshipCode': championshipCode},
      );
      final payload = response.data;
      if (payload is! Map) {
        throw const UnknownChampionshipFailure(
          'Invalid driver profile payload',
        );
      }
      return ChampionshipMapper.fromDriverDto(
        DriverDto.fromJson(Map<String, dynamic>.from(payload)),
      );
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (error) {
      if (error is ChampionshipFailure) {
        rethrow;
      }
      throw const UnknownChampionshipFailure('Invalid driver profile payload');
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionDataset(
    String sessionId,
    String dataset,
  ) async {
    try {
      final response = await _client.get(
        '/sessions/$sessionId/datasets/$dataset',
      );
      final payload = response.data;
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
      throw const UnknownChampionshipFailure('Invalid dataset payload');
    } on DioException catch (error) {
      throw ChampionshipFailure.fromDio(error);
    } catch (error) {
      if (error is ChampionshipFailure) {
        rethrow;
      }
      throw const UnknownChampionshipFailure('Invalid dataset payload');
    }
  }
}
