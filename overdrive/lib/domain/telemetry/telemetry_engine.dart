class TelemetryEngine {
    const TelemetryEngine({
        this.rpm,
        this.gear,
        this.throttlePercent,
        this.brakePercent,
        this.drsActive,
        this.timestamp,
    });

    final double? rpm;
    final int? gear;
    final double? throttlePercent;
    final double? brakePercent;
    final bool? drsActive;
    final DateTime? timestamp;
}
