class RaceWeather {
    const RaceWeather({
        this.timestamp,
        this.airTemperature,
        this.trackTemperature,
        this.humidity,
        this.windSpeed,
        this.rainfall,
    });

    final DateTime? timestamp;
    final double? airTemperature;
    final double? trackTemperature;
    final double? humidity;
    final double? windSpeed;
    final double? rainfall;
}
