# Telemetry Page

## Purpose

Provides a live, customizable telemetry dashboard where users can arrange, resize, and configure
data widgets on a freeform grid. Data is driven by `TelemetrySimulator`, a `ChangeNotifier` that
emits mock F1 telemetry at 5 Hz (200 ms tick).

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

### Driver-aware widgets (show a driver selector in the menu)

| Widget | File | Default driver | Key data shown |
|--------|------|---------------|----------------|
| `SpeedometerWidget` | `speedometer_widget.dart` | VER | Speed (km/h), animated arc |
| `GearRpmWidget` | `gear_rpm_widget.dart` | VER | Gear number, RPM bar |
| `ThrottleBrakeWidget` | `throttle_brake_widget.dart` | VER | Throttle/brake bars |
| `LapDeltaWidget` | `lap_delta_widget.dart` | VER | Lap time vs best, sector splits |
| `DrsErsWidget` | `drs_ers_widget.dart` | VER | DRS state, ERS charge bar |
| `GForceWidget` | `g_force_widget.dart` | VER | Lateral / longitudinal G-force |
| `SectorSplitWidget` | `sector_split_widget.dart` | VER | S1 / S2 / S3 times vs personal best |
| `DriverSnapshotWidget` | `driver_snapshot_widget.dart` | VER | Compact driver card |
| `TireTempWidget` | `tire_temp_widget.dart` | VER | Per-corner tyre temperature |
| `FuelWidget` | `fuel_widget.dart` | VER | Fuel load (kg), kg/lap, laps remaining |
| `PitStrategyWidget` | `pit_strategy_widget.dart` | LEC | Tyre compound, age, pit window status |
| `EngineWidget` | `engine_widget.dart` | NOR | Engine mode badge, water/oil temp bars |

### Global widgets (no driver selector)

| Widget | File | Key data shown |
|--------|------|----------------|
| `WeatherWidget` | `weather_widget.dart` | Track conditions, temps, humidity, wind |
| `StandingsWidget` | `standings_widget.dart` | Live P1/P2/P3 comparison (all drivers) |

---

## Data Layer

### `TelemetrySimulator` (`telemetry_mock_data.dart`)

`ChangeNotifier` owned by `ChangeNotifierProvider` at page root. Ticks every 200 ms.

```dart
final sim = context.watch<TelemetrySimulator>();
final snap = sim.getSnapshot('VER');      // per-driver
final cond = sim.getTrackConditions();    // shared track data
```

### `TelemetrySnapshot`

Immutable value object emitted per driver per tick. Key fields:

| Field | Type | Notes |
|-------|------|-------|
| `speed` | `double` | km/h, 80–340 |
| `gear` | `int` | 1–8 |
| `throttle` / `brake` | `double` | 0.0–1.0 |
| `rpm` | `int` | 2 000–15 000 |
| `ersLevel` | `double` | 0.0–1.0 |
| `ersMode` | `String` | `'Deploy'` or `'Harvest'` |
| `gLat` / `gLon` | `double` | ±4 G / ±5 G |
| `tyreTemp` | `Map<String, double>` | keys: `fl`, `fr`, `rl`, `rr` |
| `fuelLoad` | `double` | kg remaining |
| `fuelPerLap` | `double` | average consumption |
| `tyreAge` | `int` | laps on current set |
| `tyreCompound` | `String` | `'Soft'`, `'Medium'`, `'Hard'` |
| `waterTemp` / `oilTemp` | `double` | engine temperatures (°C) |
| `engineMode` | `String` | `'Party'`, `'Standard'`, `'Conservation'` |
| `pitWindowOpen` | `bool` | true when tyreAge is 15–35 |
| `sectorTimes` | `List<double?>` | `null` if sector not yet completed |
| `gapToLeader` | `String` | `'LEADER'` or `'+X.Xs'` |
| `trend` | `String` | `'gaining'`, `'losing'`, `'stable'` |

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

### `telemetryDecoration` (`telemetry_widget_style.dart`)

Shared `BoxDecoration` for all widget cards. Accepts an optional `accentColor` that
tints the border and shadow (used by `EngineWidget` and `PitStrategyWidget` to reflect
state through color).

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

1. Create `lib/widgets/telemetry/my_widget.dart` — use `telemetryDecoration()` and
   `LayoutBuilder` + `scale` pattern for responsive sizing.
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
