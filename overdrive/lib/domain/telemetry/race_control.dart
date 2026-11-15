class RaceControl {
    const RaceControl({
        this.category,
        this.flag,
        this.penalty,
        this.safetyCar,
        this.message,
        this.lapNumber,
        this.timestamp,
    });

    final String? category;
    final String? flag;
    final String? penalty;
    final String? safetyCar;
    final String? message;
    final int? lapNumber;
    final DateTime? timestamp;
}
