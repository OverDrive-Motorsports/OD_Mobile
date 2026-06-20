# Telemetry Widgets

Presentational widgets for the live telemetry dashboard. Each widget reads from
`TelemetrySimulator` via `context.watch<TelemetrySimulator>()` and renders a single
data card for the grid.

---

## Shared Conventions

- All widgets are wrapped in a `GestureDetector` with `onTap` to open the context menu.
- `onTap` calls `showTelemetryWidgetMenu` from `telemetry_widget_menu.dart`.
- `onRemove` and `onReset` are obtained via `TelemetryItemActions.maybeOf(context)` —
  they are injected by `GridItemWidget` without any constructor parameters on the widget itself.
- All cards use `telemetryDecoration()` from `telemetry_widget_style.dart` for consistent
  visual styling.
- Layout uses `LayoutBuilder` + a `scale` factor clamped to a safe range so widgets look
  reasonable at any grid size.
- Animated numeric transitions use `TweenAnimationBuilder<double>` to avoid jarring jumps.

---

## Driver-Aware Widgets

These widgets track a specific driver and expose a driver selector in the context menu.

### `speedometer_widget.dart` — `SpeedometerWidget`

Displays current speed as a large number with an animated arc gauge.

- Data: `snapshot.speed`
- Default driver: `VER`

### `gear_rpm_widget.dart` — `GearRpmWidget`

Shows current gear (large numeral) and RPM as a filled progress bar.

- Data: `snapshot.gear`, `snapshot.rpm`
- Default driver: `VER`

### `throttle_brake_widget.dart` — `ThrottleBrakeWidget`

Side-by-side vertical bars for throttle (green) and brake (red) input.

- Data: `snapshot.throttle`, `snapshot.brake`
- Default driver: `VER`

### `lap_delta_widget.dart` — `LapDeltaWidget`

Current lap time, best lap time, and the three sector split times vs personal best.

- Data: `snapshot.currentLapTime`, `snapshot.bestLapTime`, `snapshot.sectorTimes`,
  `snapshot.bestSectorTimes`
- Default driver: `VER`

### `drs_ers_widget.dart` — `DrsErsWidget`

DRS active/inactive badge and ERS charge level bar with deploy/harvest mode label.

- Data: `snapshot.drs`, `snapshot.ersLevel`, `snapshot.ersMode`
- Default driver: `VER`

### `g_force_widget.dart` — `GForceWidget`

Lateral (gLat) and longitudinal (gLon) G-force displayed as animated bars with
color coding (green → orange → red).

- Data: `snapshot.gLat`, `snapshot.gLon`
- Default driver: `VER`

### `sector_split_widget.dart` — `SectorSplitWidget`

Three sector rows (S1 / S2 / S3) each showing current time vs personal best.
Completed sectors are highlighted; incomplete sectors show a dash.

- Data: `snapshot.sectorTimes`, `snapshot.bestSectorTimes`
- Default driver: `VER`

### `driver_snapshot_widget.dart` — `DriverSnapshotWidget`

Compact card showing driver name, team, position, gap to leader, and trend arrow.

- Data: `snapshot.gapToLeader`, `snapshot.trend`, `snapshot.speed`
- Default driver: `VER`

### `tire_temp_widget.dart` — `TireTempWidget`

Four tyre temperature readings (FL / FR / RL / RR) laid out in car-corner positions.
Color shifts from blue (cold) through green (optimal) to red (overheating).

- Data: `snapshot.tyreTemp` (map with keys `fl`, `fr`, `rl`, `rr`)
- Default driver: `VER`

### `fuel_widget.dart` — `FuelWidget`

Current fuel load (kg), consumption per lap, and estimated laps remaining.
A color bar shifts green → orange → red as fuel decreases.

- Data: `snapshot.fuelLoad`, `snapshot.fuelPerLap`
- Default driver: `VER`

### `pit_strategy_widget.dart` — `PitStrategyWidget`

Tyre compound circle (color-coded S/M/H), tyre age in laps, and a pit window badge
(green when open, gold otherwise).

- Data: `snapshot.tyreCompound`, `snapshot.tyreAge`, `snapshot.pitWindowOpen`
- Default driver: `LEC`

### `engine_widget.dart` — `EngineWidget`

Engine mode badge (`Party` / `Standard` / `Conservation`) with water and oil
temperature bars. Card accent color reflects the current engine mode.

- Data: `snapshot.engineMode`, `snapshot.waterTemp`, `snapshot.oilTemp`
- Default driver: `NOR`

---

## Global Widgets

These widgets display track-level or multi-driver data and have no driver selector.

### `weather_widget.dart` — `WeatherWidget`

Ambient conditions shared across all drivers: track temperature, air temperature,
humidity, and wind speed. Reads from `TelemetrySimulator.getTrackConditions()`.

- Data: `TrackConditions` (not per-driver)
- `const` widget — no internal state

### `standings_widget.dart` — `StandingsWidget`

Compact live comparison card for all three drivers (P1 VER / P2 LEC / P3 NOR).
Shows position, gap to leader, speed, and gaining/losing trend.

- Data: `sim.getSnapshot('VER')`, `sim.getSnapshot('LEC')`, `sim.getSnapshot('NOR')`
- `const` widget — no internal state

---

## Shared Utilities

### `telemetry_mock_data.dart`

Contains `TelemetrySimulator`, `TelemetrySnapshot`, `TrackConditions`,
`TelemetryMockData` (driver roster), and the internal `_DriverState` simulation engine.

See [pages/telemetry/README.md](../../pages/telemetry/README.md) for full field reference.

### `telemetry_item_actions.dart` — `TelemetryItemActions`

`InheritedWidget` injected by `GridItemWidget`. Provides `onRemove` and `onReset`
callbacks to descendant widgets without constructor changes.

### `telemetry_widget_style.dart` — `telemetryDecoration`

Returns the shared `BoxDecoration` for all telemetry cards. Pass `accentColor` to
override the default gold border/glow with a state-driven color.

### `telemetry_widget_menu.dart` — `showTelemetryWidgetMenu`

Opens a custom `PopupRoute` (centered blur modal) for the widget context menu.
`teamColor(String team)` is also exported from here for consistent team color mapping.

---

## Deprecated / Unused Files

| File | Status |
|------|--------|
| `driver_picker_overlay.dart` | Replaced by `telemetry_widget_menu.dart` |
| `lap_timer_widget.dart` | Not in the active widget catalogue |
| `rpm_bar_widget.dart` | Not in the active widget catalogue |
| `speed_gauge_widget.dart` | Not in the active widget catalogue |

These files are kept for reference but not imported by the active page.
