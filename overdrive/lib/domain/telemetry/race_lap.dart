class RaceLap {
    const RaceLap({
        this.lapNumber,
        this.lapDuration,
        this.sector1,
        this.sector2,
        this.sector3,
        this.isPitOutLap,
    });

    final int? lapNumber;
    final double? lapDuration;
    final double? sector1;
    final double? sector2;
    final double? sector3;
    final bool? isPitOutLap;
}

class RaceLaps {
    const RaceLaps({
        this.laps = const [],
        this.bestLap,
        this.averageLap,
    });

    final List<RaceLap> laps;
    final double? bestLap;
    final double? averageLap;
}
