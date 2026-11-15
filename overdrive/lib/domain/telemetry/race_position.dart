class RacePosition {
    const RacePosition({
        this.driverNumber,
        this.position,
        this.gapToLeader,
        this.gapAhead,
        this.gapBehind,
        this.lapsCompleted,
        this.timestamp,
    });

    final int? driverNumber;
    final int? position;
    final double? gapToLeader;
    final double? gapAhead;
    final double? gapBehind;
    final int? lapsCompleted;
    final DateTime? timestamp;
}
