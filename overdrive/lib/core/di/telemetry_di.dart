
import '../../data/telemetry/telemetry_gateway_repository.dart';
import '../../domain/telemetry/telemetry_repository.dart';
import '../../domain/telemetry/telemetry_use_cases.dart';

class TelemetryDependencyProvider {
  TelemetryDependencyProvider({TelemetryRepository? repository})
    : repository = repository ?? TelemetryGatewayRepository();

  final TelemetryRepository repository;

  GetTelemetrySpeed get getTelemetrySpeedUseCase =>
      GetTelemetrySpeed(repository);

  GetTelemetryEngine get getTelemetryEngineUseCase =>
      GetTelemetryEngine(repository);

  GetTelemetryLocation get getTelemetryLocationUseCase =>
      GetTelemetryLocation(repository);

  GetTelemetryIntervals get getTelemetryIntervalsUseCase =>
      GetTelemetryIntervals(repository);

  GetRaceLaps get getRaceLapsUseCase => GetRaceLaps(repository);

  GetRacePositions get getRacePositionsUseCase =>
      GetRacePositions(repository);

  GetRaceStints get getRaceStintsUseCase => GetRaceStints(repository);

  GetRacePitStops get getRacePitStopsUseCase => GetRacePitStops(repository);

  GetRaceWeather get getRaceWeatherUseCase => GetRaceWeather(repository);

  GetRaceControl get getRaceControlUseCase => GetRaceControl(repository);

  GetRaceRadio get getRaceRadioUseCase => GetRaceRadio(repository);
}
