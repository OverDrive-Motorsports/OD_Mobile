class Driver {
  const Driver({
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
}
