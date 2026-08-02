# Telemetry Page

## Purpose

Provides a live, customizable telemetry dashboard where users can arrange, resize, and configure
data widgets on a freeform grid. Data is driven by `TelemetrySimulator`, a `ChangeNotifier` that
emits mock F1 telemetry at 5 Hz (200 ms tick) for three drivers: VER, LEC, and NOR.

---

## Architecture

```
TelemetryPage (StatelessWidget)
└── ChangeNotifierProvider<TelemetrySimulator>
    └── _TelemetryBoard (StatefulWidget)
        ├── AppBar  (add widget button, live indicator)
        └── SingleChildScrollView (horizontal)
            └── Scrollbar + SingleChildScrollView (vertical)
                └── GridBoard
                    └── GridItemWidget × N
                        └── TelemetryItemActions (InheritedWidget)
                            └── <telemetry widget child>
```

`TelemetryPage` is purely a provider wrapper — all state lives in `_TelemetryBoard`.

---

## Grid System

### `grid/grid_item.dart` — `GridItem`

Immutable descriptor for a widget's position and size on the grid.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier for the placed widget |
| `col` | `int` | 0-based column (grid units) |
| `row` | `int` | 0-based row (grid units) |
| `colSpan` | `int` | Width in grid cells |
| `rowSpan` | `int` | Height in grid cells |
| `child` | `Widget` | The telemetry widget to render |

### `grid/grid_board.dart` — `GridBoard`

Freeform Stack-based grid. Manages placement validation and interaction counting.

Key parameters:

| Param | Default | Description |
|-------|---------|-------------|
| `cols` | responsive | Computed from screen width |
| `rows` | 15 | Total vertical cells |
| `cellSize` | 64 px | Square cell size |
| `gap` | 5 px | Space between cells |

Grid background (cell outlines + dot sub-grid) fades in via `AnimatedOpacity` only
while a drag or resize is active (`_interactionCount > 0`). This prevents visual noise
during normal browsing.

### `grid/grid_item_widget.dart` — `GridItemWidget`

Handles all touch interactions for a single grid item.

**Drag** — long-press anywhere on the widget body, then move:
- `onLongPressStart` → enters drag mode, triggers haptic (`mediumImpact`)
- `onLongPressMoveUpdate` → moves the live position using `localOffsetFromOrigin`
- `onLongPressEnd` → commits to nearest grid cell

**Resize** — long-press on the bottom-right 44 × 44 px hitbox, then move:
- Same long-press pattern, triggers haptic (`lightImpact`)
- Only the size changes; position stays fixed

**Why long-press instead of immediate pan?**
The grid lives inside a `SingleChildScrollView`. Standard `onPanStart` enters the gesture
arena simultaneously with the scroll view, which always wins. Long press is committed after
500 ms and cannot be reclaimed by the scroll recognizer afterward.

**Menu** — short tap on any widget body opens the context menu (`showTelemetryWidgetMenu`).
Tap and long-press are naturally distinguished by duration in Flutter's gesture arena.

---

## Widget Catalogue

`_TelemetryBoard` manages a list of `GridItem` objects. The `_WidgetType` enum and
`_buildWidget` factory function map enum values to concrete widget instances.

### Driver-aware widgets (show a driver selector in the context menu)

| Widget | File | Default driver | Key data shown |
|--------|------|---------------|----------------|
| `Speedometer` | `speedometer.dart` | VER | Speed (km/h), animated arc |
| `GearRpm` | `gear_rpm.dart` | VER | Gear number, RPM bar |
| `ThrottleBrake` | `throttle_brake.dart` | VER | Throttle/brake bars |
| `LapDelta` | `lap_delta.dart` | VER | Lap time vs best, sector splits |
| `DrsErs` | `drs_ers.dart` | VER | DRS state, ERS charge bar |
| `GForce` | `g_force.dart` | VER | Lateral / longitudinal G-force scatter trail |
| `SectorSplit` | `sector_split.dart` | VER | S1 / S2 / S3 times vs personal best |
| `DriverSnapshot` | `driver_snapshot.dart` | VER | Compact driver card with gap and trend |
| `TireTemps` | `tire_temps.dart` | VER | Per-corner tyre temperature heat map |
| `FuelGauge` | `fuel_gauge.dart` | VER | Fuel load (kg), kg/lap, laps remaining |
| `PitStrategy` | `pit_strategy.dart` | LEC | Tyre compound, age, pit window status |
| `EngineTemps` | `engine_temps.dart` | NOR | Engine mode badge, water/oil temp bars |
| `LapHistory` | `lap_history.dart` | VER | Per-lap time chart across the stint |
| `LapPosition` | `lap_position.dart` | VER | Position-history line chart across laps |
| `LapTimer` | `lap_timer.dart` | VER | Live current-lap elapsed time counter |
| `PedalTrace` | `pedal_trace.dart` | VER | Scrolling throttle/brake trace over time |
| `Damage` | `damage.dart` | LEC | Per-corner body damage level bars |
| `Penalty` | `penalty.dart` | VER | Time penalty and warning dot accumulation |

### Global widgets (no driver selector)

| Widget | File | Key data shown |
|--------|------|----------------|
| `Weather` | `weather.dart` | Track conditions, temps, humidity, wind |
| `RaceStandings` | `race_standings.dart` | Live P1/P2/P3 comparison (all drivers) |
| `WeatherForecast` | `weather_forecast.dart` | Hourly forecast strip with condition icons |
| `WeatherRadar` | `weather_radar.dart` | Stylized radar sweep for approaching weather |

---

## Data Layer

### `TelemetrySimulator` (`telemetry_mock_data.dart`)

`ChangeNotifier` owned by `ChangeNotifierProvider` at page root. Ticks every 200 ms.

```dart
final sim = context.watch<TelemetrySimulator>();
final snap = sim.getSnapshot('VER');      // per-driver snapshot
final cond = sim.getTrackConditions();    // shared track data
```

### `TelemetrySnapshot`

Immutable value object emitted per driver per tick. Key fields:

| Field | Type | Notes |
|-------|------|-------|
| `speed` | `double` | km/h, 80–340 |
| `gear` | `int` | 1–8 |
| `throttle` / `brake` | `double` | 0.0–1.0, mutually exclusive |
| `rpm` | `int` | 2 000–15 000 |
| `drs` | `bool` | DRS gate open |
| `ersLevel` | `double` | 0.0–1.0 |
| `ersMode` | `String` | `'Deploy'` or `'Harvest'` |
| `gLat` / `gLon` | `double` | ±4 G lateral / ±5 G longitudinal |
| `tyreTemp` | `Map<String, double>` | keys: `fl`, `fr`, `rl`, `rr` |
| `tyreWear` | `Map<String, double>` | per-corner wear fraction 0.0–1.0 |
| `fuelLoad` | `double` | kg remaining |
| `fuelPerLap` | `double` | average consumption |
| `tyreAge` | `int` | laps on current set |
| `tyreCompound` | `String` | `'Soft'`, `'Medium'`, `'Hard'` |
| `waterTemp` / `oilTemp` | `double` | engine temperatures (°C) |
| `engineMode` | `String` | `'Party'`, `'Standard'`, `'Conservation'` |
| `pitWindowOpen` | `bool` | true when tyreAge is in the strategy window |
| `sectorTimes` | `List<double?>` | `null` if sector not yet completed |
| `bestSectorTimes` | `List<double?>` | personal best per sector |
| `currentLapTime` | `double` | elapsed seconds this lap |
| `bestLapTime` | `double` | personal best lap in seconds |
| `gapToLeader` | `String` | `'LEADER'` or `'+X.Xs'` |
| `trend` | `String` | `'gaining'`, `'losing'`, `'stable'` |
| `position` | `int` | current race position (1–3) |
| `lapCount` | `int` | laps completed |
| `damage` | `Map<String, double>` | per-corner damage 0.0–1.0 |
| `penaltySeconds` | `int` | accumulated time penalty |
| `warnings` | `int` | warning count (0–3) |
| `lapHistory` | `List<LapData>` | per-lap time and gap history |
| `positionHistory` | `List<PositionData>` | per-lap position history |
| `pedalHistory` | `List<PedalSample>` | rolling throttle/brake trace samples |
| `hourlyForecast` | `List<HourlyForecast>` | upcoming weather forecast |

### `TrackConditions`

Shared across all drivers. Fluctuates slightly on every tick.

| Field | Type | Range |
|-------|------|-------|
| `trackTemp` | `double` | 35–65 °C |
| `airTemp` | `double` | 18–40 °C |
| `humidity` | `double` | 20–90 % |
| `conditions` | `String` | `'Dry'` or `'Damp'` |
| `windSpeed` | `double` | 0–40 km/h |

---

## Shared Infrastructure

### `TelemetryItemActions` (`telemetry_item_actions.dart`)

`InheritedWidget` injected by `GridItemWidget` around every child widget. Avoids
threading `onRemove` and `onReset` callbacks through widget constructors.

```dart
// Inside any telemetry widget:
final actions = TelemetryItemActions.maybeOf(context);
actions?.onRemove?.call();
actions?.onReset?.call();
```

### `TelemetryCard` (`telemetry_widget_style.dart`)

Liquid-glass card wrapper applied by every telemetry widget. Uses the `CupertinoLiquidGlass`
"Moyen-gris" preset (tintOpacity: 0.14, blurSigma: 22.0). `telemetryDecoration()` is also
available for widgets that need raw `BoxDecoration` instead.

### `TelemetryMode` (`telemetry_widget_style.dart`)

```dart
enum TelemetryMode { small, large }
TelemetryMode telemetryMode(double w, double h) { ... }
```

`small` when either dimension is below 155 px; `large` otherwise. All widgets switch
their layout based on this enum instead of hardcoded breakpoints.

### `showTelemetryWidgetMenu` (`telemetry_widget_menu.dart`)

Custom `PopupRoute` showing a blurred centered modal with:
- Optional driver selector rows (omit for global widgets)
- "Reset size" action
- "Remove widget" action

```dart
showTelemetryWidgetMenu(
  context,
  widgetLabel: 'Speedometer',
  currentDriverId: _driverId,
  onDriverSelected: (id) => setState(() => _driverId = id),
  onReset: actions?.onReset,
  onRemove: actions?.onRemove,
);
```

---

## Adding a New Widget Type

1. Create `lib/widgets/telemetry/my_widget.dart` — wrap content in `TelemetryCard`,
   use `LayoutBuilder` + `telemetryMode()` for responsive sizing.
2. Add an entry to `_WidgetType` enum in `telemetry_page.dart`.
3. Add a case to `_buildWidget` factory.
4. Wire `onTap` → `showTelemetryWidgetMenu` using `TelemetryItemActions.maybeOf(context)`.

---

## Grid Constants (`_TelemetryBoardState`)

| Constant | Value | Description |
|----------|-------|-------------|
| `_minCols` | 5 | Minimum column count regardless of screen width |
| `_rows` | 15 | Fixed row count (scroll vertically for the rest) |
| `_cellSize` | 64 px | Cell square side |
| `_gap` | 5 px | Gap between cells |
| `_defaultColSpan` | 2 | Initial width of newly added widgets |
| `_defaultRowSpan` | 2 | Initial height of newly added widgets |
