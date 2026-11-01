class Standing {
  const Standing({
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
}
