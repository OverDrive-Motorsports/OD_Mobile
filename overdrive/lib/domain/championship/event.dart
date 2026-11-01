class Event {
  const Event({
    required this.eventId,
    required this.championshipId,
    required this.championshipCode,
    required this.seasonYear,
    required this.roundNumber,
    required this.name,
    required this.startDate,
    required this.endDate,
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
  final String? circuit;
  final String? location;
  final String? countryName;
  final String? countryCode;
  final String? externalKey;
  final DateTime startDate;
  final DateTime endDate;
  final String? status;
}
