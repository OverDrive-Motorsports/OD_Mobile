class ChampionshipDto {
  const ChampionshipDto({
    this.id,
    required this.championshipCode,
    required this.name,
    this.provider,
    this.category,
    this.isActive = true,
  });

  final String? id;
  final String championshipCode;
  final String name;
  final String? provider;
  final String? category;
  final bool isActive;

  factory ChampionshipDto.fromJson(Map<String, dynamic> json) {
    return ChampionshipDto(
      id: json['id']?.toString(),
      championshipCode: (json['championshipCode'] ?? json['code'] ?? '')
          .toString(),
      name: (json['name'] ?? '').toString(),
      provider: json['provider']?.toString(),
      category: json['category']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'championshipCode': championshipCode,
    'name': name,
    if (provider != null) 'provider': provider,
    if (category != null) 'category': category,
    'isActive': isActive,
  };
}

class EventDto {
  const EventDto({
    required this.eventId,
    required this.championshipCode,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.championshipId,
    this.seasonYear,
    this.roundNumber,
    this.officialName,
    this.circuit,
    this.location,
    this.countryName,
    this.countryCode,
    this.externalKey,
    this.status,
  });

  final String eventId;
  final String? championshipId;
  final String championshipCode;
  final int? seasonYear;
  final int? roundNumber;
  final String name;
  final String? officialName;
  final DateTime startDate;
  final DateTime endDate;
  final String? circuit;
  final String? location;
  final String? countryName;
  final String? countryCode;
  final String? externalKey;
  final String? status;

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      eventId: (json['eventId'] ?? json['id'] ?? '').toString(),
      championshipId: json['championshipId']?.toString(),
      championshipCode: (json['championshipCode'] ?? '').toString(),
      seasonYear: _readInt(json['seasonYear'] ?? json['season']),
      roundNumber: _readInt(json['roundNumber']),
      name: (json['name'] ?? '').toString(),
      officialName: json['officialName']?.toString(),
      startDate:
          _readDateTime(json['startDate']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate:
          _readDateTime(json['endDate']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      circuit: json['circuit']?.toString(),
      location: json['location']?.toString(),
      countryName: json['countryName']?.toString(),
      countryCode: json['countryCode']?.toString(),
      externalKey: json['externalKey']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class SessionDto {
  const SessionDto({
    required this.sessionId,
    required this.eventId,
    required this.type,
    required this.status,
    this.name,
    this.circuit,
    this.externalKey,
    this.broadcastUrl,
    this.startTime,
    this.endTime,
  });

  final String sessionId;
  final String eventId;
  final String type;
  final String status;
  final String? name;
  final String? circuit;
  final String? externalKey;
  final String? broadcastUrl;
  final DateTime? startTime;
  final DateTime? endTime;

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      sessionId: (json['sessionId'] ?? '').toString(),
      eventId: (json['eventId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      name: json['name']?.toString(),
      circuit: json['circuit']?.toString(),
      externalKey: json['externalKey']?.toString(),
      broadcastUrl: json['broadcastUrl']?.toString(),
      startTime: _readDateTime(json['startTime']),
      endTime: _readDateTime(json['endTime']),
    );
  }
}

class DriverDto {
  const DriverDto({
    required this.driverNumber,
    required this.fullName,
    this.nationality,
    this.currentTeamId,
    this.championshipCode,
  });

  final int driverNumber;
  final String fullName;
  final String? nationality;
  final String? currentTeamId;
  final String? championshipCode;

  factory DriverDto.fromJson(Map<String, dynamic> json) {
    return DriverDto(
      driverNumber: _readInt(json['driverNumber']) ?? 0,
      fullName: (json['fullName'] ?? '').toString(),
      nationality: json['nationality']?.toString(),
      currentTeamId: json['currentTeamId']?.toString(),
      championshipCode: json['championshipCode']?.toString(),
    );
  }
}

class TeamDto {
  const TeamDto({
    required this.teamId,
    required this.name,
    this.code,
    this.color,
  });

  final String teamId;
  final String name;
  final String? code;
  final String? color;

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    return TeamDto(
      teamId: (json['teamId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      code: json['code']?.toString(),
      color: (json['color'] ?? json['colorHex'] ?? json['teamColor'])
          ?.toString(),
    );
  }
}

class StandingDto {
  const StandingDto({
    required this.position,
    this.driverNumber,
    this.teamId,
    this.gapToLeader,
    this.points,
  });

  final int position;
  final int? driverNumber;
  final String? teamId;
  final String? gapToLeader;
  final double? points;

  factory StandingDto.fromJson(Map<String, dynamic> json) {
    return StandingDto(
      position: _readInt(json['position']) ?? 0,
      driverNumber: _readInt(json['driverNumber']),
      teamId: json['teamId']?.toString(),
      gapToLeader: json['gapToLeader']?.toString(),
      points: _readDouble(json['points']),
    );
  }
}

int? _readInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double? _readDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

DateTime? _readDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
