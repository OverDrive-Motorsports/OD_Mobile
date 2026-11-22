import 'package:dio/dio.dart';

import 'championship.dart';
import 'driver.dart';
import 'event.dart';
import 'session.dart';
import 'standing.dart';
import 'team.dart';

abstract class ChampionshipRepository {
  Future<List<Championship>> getChampionships();

  Future<List<Event>> getEventsByChampionship(
    String championshipCode, {
    int? season,
  });

  Future<Event> getEvent(String eventId);

  Future<List<Session>> getEventSessions(String eventId, {String? type});

  Future<Session> getSession(String sessionId);

  Future<List<Driver>> getSessionDrivers(String sessionId, {String? teamId});

  Future<List<Team>> getSessionTeams(String sessionId);

  Future<List<Standing>> getSessionStandings(
    String sessionId, {
    int? driverNumber,
  });

  Future<Driver> getDriverProfile(int driverNumber, {String? championshipCode});

  Future<Map<String, dynamic>> getSessionDataset(
    String sessionId,
    String dataset,
  );
}

abstract class ChampionshipFailure implements Exception {
  const ChampionshipFailure(this.message);

  final String message;

  static ChampionshipFailure fromDio(DioException exception) {
    final data = exception.response?.data;
    if (data is Map) {
      final errorMessage = data['error'];
      if (errorMessage is String && errorMessage.trim().isNotEmpty) {
        return _failureFromStatus(
          statusCode: exception.response?.statusCode,
          message: errorMessage.trim(),
        );
      }
    }

    return _failureFromStatus(
      statusCode: exception.response?.statusCode,
      message: exception.message ?? 'Unexpected championship gateway error',
    );
  }

  static ChampionshipFailure _failureFromStatus({
    required int? statusCode,
    required String message,
  }) {
    if (statusCode == 401 || message.toLowerCase() == 'unauthorized') {
      return UnauthorizedChampionshipFailure(message);
    }

    if (statusCode == 400 || message.toLowerCase() == 'invalid parameter') {
      return InvalidParameterChampionshipFailure(message);
    }

    if (statusCode == 502) {
      return GatewayUnavailableChampionshipFailure(message);
    }

    return UnknownChampionshipFailure(message);
  }

  @override
  String toString() => message;
}

class UnauthorizedChampionshipFailure extends ChampionshipFailure {
  const UnauthorizedChampionshipFailure(super.message);
}

class InvalidParameterChampionshipFailure extends ChampionshipFailure {
  const InvalidParameterChampionshipFailure(super.message);
}

class GatewayUnavailableChampionshipFailure extends ChampionshipFailure {
  const GatewayUnavailableChampionshipFailure(super.message);
}

class UnknownChampionshipFailure extends ChampionshipFailure {
  const UnknownChampionshipFailure(super.message);
}
