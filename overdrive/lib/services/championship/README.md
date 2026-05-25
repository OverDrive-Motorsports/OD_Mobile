# Championship Services

## Purpose

This folder contains the data contract for the championship module: enums,
models, and demo mocks used to drive `ChampionshipPage`.

## Files

### `championship_enums.dart`

- `ChampionshipState`: `offSeason`, `eventWeekend`, `liveSession`
- `SessionStatus`: `completed`, `live`, `upcoming`
- `StandingType`: `drivers`, `teams`, `manufacturers`

### `championship_data.dart`

- Main page payload.
- Combines the common metadata, optional state-specific blocks, standings, and
  replay CTA data.

### `championship_circuit.dart`

- `ChampionshipCircuit`
- `ChampionshipWeather`
- `ChampionshipNextEvent`
- `ChampionshipReplays`

These models feed the weekend and off-season cards.

### `championship_session.dart`

- `ChampionshipSession`

Used by the schedule widget to render the event-weekend program.

### `championship_standing.dart`

- `ChampionshipStandingTable`
- `ChampionshipStandingEntry`

These are page-level standings models, later mapped to the shared standings UI
widget.

### `championship_live_entry.dart`

- `ChampionshipLiveGroup`
- `ChampionshipLiveEntry`

Used by live sessions for top 3 cards and full timing tables.

## Mock Data

### `championship_mock_data.dart`

Exports:

- `championshipFormula1Mock`
- `championshipWecMock`
- `championshipMotoGpMock`
- `championshipMocks`
- `championshipDataById`

### Formula 1 mock

- State: `liveSession`
- Goal: validate single-class live timing.
- Covers:
  live top 3
  live standings title derived from laps
  drivers + teams season standings

### WEC mock

- State: `offSeason`
- Goal: validate off-season countdown and multi-category standings.
- Covers:
  next-event countdown
  3 standing categories: `Hypercar`, `LMP2`, `GT3`
  per-category drivers + teams sections

### MotoGP mock

- State: `eventWeekend`
- Goal: validate schedule-driven weekend rendering.
- Covers:
  circuit/weather summary
  tapable schedule rows
  drivers + constructors standings

## Documentation Notes

- Adding a new championship should only require appending a new
  `ChampionshipData` object to `championshipMocks`.
- The page structure is intentionally data-driven so the UI layer does not need
  per-championship branching.
