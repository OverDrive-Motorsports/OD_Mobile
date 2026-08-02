# Widgets

This directory contains the shared presentation layer for the OverDrive app.
Pages should compose these widgets instead of rebuilding the same UI patterns.

## Principles

- Keep widgets reusable and explicitly typed.
- Keep business logic outside UI primitives whenever possible.
- Prefer small, composable files over page-specific one-off rendering.
- Use `AppColors` and `AppTextStyles` from `app_theme.dart` for shared color and typography choices.
- All glass surfaces use `cupertino_liquid_glass` with the dark theme preset.

---

## Directory Structure

```
widgets/
├── base/               Shared design-system primitives (buttons, modals, inputs, toasts, nav overlay)
├── calendar/           Monthly calendar grid and event list
├── championships/      Championship cards: circuit, weather, schedule, standings, top 3
├── navigation/         Bottom navigation shell (GoRouter integration)
├── telemetry/          22 live telemetry data cards + 4 support files for the freeform grid
└── tv/                 Live race video player and stream selector sheet
```

---

## `base/`

Design-system primitives shared across every page.

| File | Widget | Purpose |
|------|--------|---------|
| `app_button.dart` | `AppButton` | Primary, secondary, and danger button variants with press animation |
| `app_modal.dart` | `AppModal` / `showAppModal` | Bottom-sheet modal with blurred backdrop, title, body, and action buttons |
| `app_switch.dart` | `AppSwitch` | Liquid-glass toggle switch with spring physics; optionally paired with a label |
| `app_text_field.dart` | `AppTextField` | Themed text input with label, hint, and inline validation error display |
| `app_toast.dart` | `AppToast` / `showAppToast` | Auto-dismiss slide-up toast notification; only one visible at a time |
| `demo_liquid.dart` | `DemoLiquid` | Design-review showcase of all `cupertino_liquid_glass` theme presets |
| `error_message.dart` | `ErrorMessage` | Inline error text used below form fields and action results |
| `menu_overlay.dart` | `MenuOverlay` | App-wide bottom navigation overlay providing page shortcuts |
| `search_bar.dart` | `AppSearchBar` | Focus-aware search input with a clear button; presentational only |

---

## `calendar/`

| File | Widget | Purpose |
|------|--------|---------|
| `event_calendar.dart` | `EventCalendar` | Vertically scrolling race event cards with past/ongoing/upcoming styling |
| `monthly_calendar.dart` | `MonthlyCalendar` | Scrollable month grid with event marker dots and day selection |

`event_calendar.dart` also exports `CalendarEventMarker`, `CalendarScheduleEvent`, and
`CalendarScheduleStatus` — the calendar domain models consumed by `CalendarPage`.

---

## `championships/`

| File | Widget | Purpose |
|------|--------|---------|
| `championship_circuit_weather.dart` | `ChampionshipCircuitWeatherCard` | Circuit metadata + current weather conditions |
| `championship_icon.dart` | `ChampionshipIcon` | Series icon resolved by championship ID |
| `championship_next_event.dart` | `ChampionshipNextEventCard` | Countdown card for the next off-season event |
| `championship_schedule.dart` | `ChampionshipScheduleCard` | Weekend session list with completion status |
| `championship_standings.dart` | `ChampionshipStandingsWidget` | Driver/team standings table with animated tab switcher |
| `championship_top3.dart` | `ChampionshipTop3Card` | Live timing podium card showing top-3 drivers with gap, tyre, and team color |

See [`championships/README.md`](championships/README.md) for detailed API documentation.

---

## `navigation/`

| File | Widget | Purpose |
|------|--------|---------|
| `navigation_shell.dart` | `NavigationShell` | Bottom nav bar wrapping GoRouter's `StatefulShellRoute.indexedStack` for five main branches |

---

## `telemetry/`

22 live telemetry data cards plus 4 support files for the freeform drag-and-resize grid.

Full widget catalogue, data model reference, and conventions are in
[`telemetry/README.md`](telemetry/README.md).

Quick reference:

| Widget | Driver-aware | Key data shown |
|--------|-------------|----------------|
| `Speedometer` | yes | Speed arc (km/h) |
| `GearRpm` | yes | Gear number + RPM bar |
| `ThrottleBrake` | yes | Throttle / brake bars |
| `LapDelta` | yes | Lap time + delta |
| `DrsErs` | yes | DRS state + ERS charge |
| `GForce` | yes | Lateral + longitudinal G scatter |
| `SectorSplit` | yes | S1 / S2 / S3 vs personal best |
| `DriverSnapshot` | yes | Driver card (gap, trend, speed) |
| `TireTemps` | yes | Per-corner tyre temp heat map |
| `FuelGauge` | yes | Fuel load + laps remaining |
| `PitStrategy` | yes | Compound, tyre age, pit window |
| `EngineTemps` | yes | Engine mode + water/oil temp |
| `LapHistory` | yes | Per-lap time bar chart |
| `LapPosition` | yes | Position-history line chart |
| `LapTimer` | yes | Live current-lap counter |
| `PedalTrace` | yes | Rolling throttle/brake waveform |
| `Damage` | yes | Per-corner body damage bars |
| `Penalty` | yes | Time penalty + warning dots |
| `Weather` | no | Track conditions (shared) |
| `RaceStandings` | no | All-driver P1/P2/P3 comparison |
| `WeatherForecast` | no | Hourly forecast strip |
| `WeatherRadar` | no | Stylized radar sweep |

---

## `tv/`

| File | Widget | Purpose |
|------|--------|---------|
| `tv_live_player.dart` | `TvLivePlayer` | Full-screen WebView video player for a `TvStream`; falls back to an unavailable state when no URL is set |
| `tv_stream_selector_sheet.dart` | `TvStreamSelectorSheet` | Bottom sheet listing all available streams for selection |

---

## Maintenance Checklist

Before adding or editing a widget here, verify:
- Can this UI be reused elsewhere, or does it belong in the page file?
- Are state ownership and callbacks clearly typed?
- Does the visual treatment use `AppColors`/`AppTextStyles` rather than hardcoded values?
- Should the glass surface use `TelemetryCard` (telemetry) or a direct `CupertinoLiquidGlass` (everything else)?
