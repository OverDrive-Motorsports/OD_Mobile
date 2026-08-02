# Championship Widgets

## Purpose

Reusable presentation widgets for all championship pages. Each widget is data-driven
and works identically for Formula 1, WEC, and MotoGP — no per-series branching.

---

## Widgets

### `championship_circuit_weather.dart` — `ChampionshipCircuitWeatherCard`

Combined card displaying circuit metadata (name, location, lap count, circuit length)
alongside current weather conditions (track temp, air temp, rain chance).

Inputs:
- `circuit`: `ChampionshipCircuit`
- `weather`: `ChampionshipWeather`
- `accentColor`: tints the card border

### `championship_icon.dart` — `ChampionshipIcon`

Championship series icon resolved by series ID string. Used in cards and page headers.

Inputs:
- `championshipId`: series identifier (e.g. `'formula_1'`, `'wec'`, `'motogp'`)
- `size`: icon diameter

Behavior:
- Maps known IDs to `IconData` symbols; falls back to a generic trophy icon.

### `championship_next_event.dart` — `ChampionshipNextEventCard`

Off-season card showing a live countdown (days / hours / minutes) and event details
for the next scheduled championship event.

Inputs:
- `event`: `ChampionshipNextEvent`
- `accentColor`

Behavior:
- Countdown recomputes on every rebuild (no internal timer).

### `championship_schedule.dart` — `ChampionshipScheduleCard`

Weekend session list with completion status badges for each session.

Inputs:
- `sessions`: `List<ChampionshipSession>`
- `title`: optional card heading

Behavior:
- Automatically identifies the next upcoming session and highlights it.
- Status badge distinguishes `completed`, `live`, and `upcoming` sessions.

### `championship_standings.dart` — `ChampionshipStandingsWidget`

Standings table with an animated pill-switcher tab bar for multiple categories
(e.g. Drivers / Teams, or multi-class WEC categories).

Inputs:
- `tables`: `List<ChampionshipStandingTable>`
- `accentColor`

Behavior:
- Animates between standing categories using a custom `_SwitchPillPainter`.
- Supports text-avatar fallback when no image is available.

### `championship_top3.dart` — `ChampionshipTop3Card`

Live timing podium card showing the top-3 race entries with gap, tyre compound,
and team color strip.

Inputs:
- `group`: `ChampionshipLiveGroup`
- `accentColor`

Behavior:
- Renders P1 / P2 / P3 in a three-column layout; P1 gets stronger visual emphasis.
- Shows a delta row (gap + tyre compound badge) below each driver's name.
- Supports optional per-class label for multi-class championships (WEC, etc.).

---

## Header Convention

All files in this folder carry the standard OverDrive 2026 file header block,
keeping ownership and intent consistent across the championship module.
