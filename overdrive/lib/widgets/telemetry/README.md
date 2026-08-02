# Telemetry Widgets

Presentational widgets for the live telemetry dashboard. Each widget reads from
`TelemetrySimulator` via `context.watch<TelemetrySimulator>()` and renders a single
data card for the freeform grid.

---

## Shared Conventions

- All widgets are wrapped in a `GestureDetector` with `onTap` to open the context menu.
- `onTap` calls `showTelemetryWidgetMenu` from `telemetry_widget_menu.dart`.
- `onRemove` and `onReset` are obtained via `TelemetryItemActions.maybeOf(context)` —
  they are injected by `GridItemWidget` without any constructor parameters on the widget itself.
- All cards use `TelemetryCard` from `telemetry_widget_style.dart` (a `CupertinoLiquidGlass`
  wrapper with the "Moyen-gris" preset: tintOpacity 0.14, blurSigma 22.0).
- Layout uses `LayoutBuilder` + `telemetryMode()` to switch between `small` (< 155 px) and
  `large` (≥ 155 px both dimensions) layouts.
- Animated numeric transitions use `TweenAnimationBuilder<double>` to avoid jarring jumps.

---

## Driver-Aware Widgets

These widgets track a specific driver and expose a driver selector in the context menu.

### `speedometer.dart` — `Speedometer`

Displays current speed as a large numeral with an animated arc gauge.

- Data: `snapshot.speed`
- Default driver: `VER`

### `gear_rpm.dart` — `GearRpm`

Shows current gear (large numeral) and RPM as a filled progress bar with threshold coloring.

- Data: `snapshot.gear`, `snapshot.rpm`
- Default driver: `VER`

### `throttle_brake.dart` — `ThrottleBrake`

Side-by-side vertical bars for throttle (green) and brake (red) input. The channels are
mutually exclusive — both cannot be non-zero simultaneously in the simulator.

- Data: `snapshot.throttle`, `snapshot.brake`
- Default driver: `VER`

### `lap_delta.dart` — `LapDelta`

Current lap time, personal best lap, and delta (+ ahead / − behind) formatted as `+0.000`.

- Data: `snapshot.currentLapTime`, `snapshot.bestLapTime`
- Default driver: `VER`

### `drs_ers.dart` — `DrsErs`

DRS active/inactive badge and ERS charge level bar with deploy/harvest mode label.

- Data: `snapshot.drs`, `snapshot.ersLevel`, `snapshot.ersMode`
- Default driver: `VER`

### `g_force.dart` — `GForce`

G-force scatter plot with a trailing dot trail showing the last 8 samples. Listens to
the `TelemetrySimulator` directly (not via `context.watch`) to accumulate the trail across
frames without rebuilding the entire widget tree.

- Data: `snapshot.gLat`, `snapshot.gLon`
- Default driver: `VER`

### `sector_split.dart` — `SectorSplit`

Three sector rows (S1 / S2 / S3) each showing the current time vs personal best.
Completed sectors are highlighted; incomplete sectors show a dash.

- Data: `snapshot.sectorTimes`, `snapshot.bestSectorTimes`
- Default driver: `VER`

### `driver_snapshot.dart` — `DriverSnapshot`

Compact card showing driver code, position, gap to leader, current speed, and a trend arrow.

- Data: `snapshot.position`, `snapshot.gapToLeader`, `snapshot.trend`, `snapshot.speed`
- Default driver: `VER`

### `tire_temps.dart` — `TireTemps`

Four tyre temperature readings (FL / FR / RL / RR) in car-corner layout. Color shifts
from blue (cold) through green (optimal) to red (overheating). Wear percentage also shown.

- Data: `snapshot.tyreTemp`, `snapshot.tyreWear`, `snapshot.tyreCompound`
- Default driver: `VER`

### `fuel_gauge.dart` — `FuelGauge`

Current fuel load (kg), consumption per lap, and estimated laps remaining.
A segmented bar shifts green → orange → red as fuel decreases.

- Data: `snapshot.fuelLoad`, `snapshot.fuelPerLap`
- Default driver: `VER`

### `pit_strategy.dart` — `PitStrategy`

Tyre compound circle (color-coded S/M/H), tyre age in laps, and a pit window badge
(green when open, gold otherwise). The pit window is considered open between laps 15–35.

- Data: `snapshot.tyreCompound`, `snapshot.tyreAge`, `snapshot.pitWindowOpen`
- Default driver: `LEC`

### `engine_temps.dart` — `EngineTemps`

Engine mode badge (`Party` / `Standard` / `Conservation`) with water and oil temperature
bars. The card accent color reflects the current engine mode.

- Data: `snapshot.engineMode`, `snapshot.waterTemp`, `snapshot.oilTemp`
- Default driver: `NOR`

### `lap_history.dart` — `LapHistory`

Bar chart of per-lap times across the stint, with the best lap highlighted in gold.

- Data: `snapshot.lapHistory` (list of `LapData`)
- Default driver: `VER`

### `lap_position.dart` — `LapPosition`

Line chart of race position across completed laps (1 = leader at top).

- Data: `snapshot.positionHistory` (list of `PositionData`)
- Default driver: `VER`

### `lap_timer.dart` — `LapTimer`

Live current-lap elapsed time counter, refreshed on every simulator tick.

- Data: `snapshot.currentLapTime`
- Default driver: `VER`

### `pedal_trace.dart` — `PedalTrace`

Scrolling dual-channel trace (throttle green, brake red) over the last N samples.
Uses a `CustomPainter` to draw the rolling waveform.

- Data: `snapshot.pedalHistory` (list of `PedalSample`)
- Default driver: `VER`

### `damage.dart` — `Damage`

Per-corner body damage level as colored bars (OK → minor → high → critical).

- Data: `snapshot.damage` (map with keys `fl`, `fr`, `rl`, `rr`)
- Default driver: `LEC`

### `penalty.dart` — `Penalty`

Time penalty (seconds) and warning dot accumulation. Warning dots escalate in color
from gold to red as the count increases toward 3 (black-flag threshold).

- Data: `snapshot.penaltySeconds`, `snapshot.warnings`
- Default driver: `VER`

---

## Global Widgets

These widgets display track-level or multi-driver data and have no driver selector.

### `weather.dart` — `Weather`

Ambient conditions shared across all drivers: track temperature, air temperature,
humidity, and wind speed. Reads from `TelemetrySimulator.getTrackConditions()`.

- Data: `TrackConditions` (not per-driver)

### `race_standings.dart` — `RaceStandings`

Live comparison card for all three simulated drivers (VER / LEC / NOR).
Shows position, gap to leader, speed, and gaining/losing trend.

- Data: `sim.getSnapshot('VER')`, `sim.getSnapshot('LEC')`, `sim.getSnapshot('NOR')`

### `weather_forecast.dart` — `WeatherForecast`

Horizontal scrolling hourly forecast strip showing condition icons, temperature,
precipitation chance, and wind speed for the next several hours.

- Data: `snapshot.hourlyForecast` (list of `HourlyForecast`)

### `weather_radar.dart` — `WeatherRadar`

Stylized radar sweep animation showing approaching weather fronts.
The sweep angle and blip positions are derived from the current `TrackConditions`.

- Data: `TrackConditions`

---

## Shared Utilities

### `telemetry_mock_data.dart`

Contains `TelemetrySimulator`, `TelemetrySnapshot`, `TrackConditions`, and all supporting
value-object types (`LapData`, `PositionData`, `PedalSample`, `HourlyForecast`).

See [pages/telemetry/README.md](../../pages/telemetry/README.md) for the full field reference.

### `telemetry_item_actions.dart` — `TelemetryItemActions`

`InheritedWidget` injected by `GridItemWidget`. Provides `onRemove` and `onReset`
callbacks to descendant widgets without constructor changes.

### `telemetry_widget_style.dart` — `TelemetryCard` / `TelemetryMode`

`TelemetryCard` is the liquid-glass card wrapper used by every telemetry widget.
`TelemetryMode` (`small` / `large`) drives responsive layout switching.
`telemetryDecoration()` is available for raw `BoxDecoration` use cases.

### `telemetry_widget_menu.dart` — `showTelemetryWidgetMenu`

Opens a custom `PopupRoute` (centered blur modal) for the widget context menu.
Provides optional driver selector rows, "Reset size", and "Remove widget" actions.
`teamColor(String team)` is also exported for consistent team color mapping.
