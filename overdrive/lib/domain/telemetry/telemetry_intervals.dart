class TelemetryIntervals {
    const TelemetryIntervals({
        this.driverNumber,
        this.gapToLeader,
        this.gapAhead,
        this.timestamp,
    });

    final int? driverNumber;
    final double? gapToLeader;
    final double? gapAhead;
    final DateTime? timestamp;
}
