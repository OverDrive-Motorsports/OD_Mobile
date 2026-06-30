# Championship Services

## Purpose

Data contracts, domain models, and mock data for the championship module.
All files are pure Dart with no Flutter dependency (except `Color` from `dart:ui`).
`ChampionshipPage` is the sole consumer; the router wires mock data in directly.

---

## Files

### `championship_enums.dart`

Shared enums used throughout the module:
- `ChampionshipState`: `offSeason` | `eventWeekend` | `liveSession`
- `SessionStatus`: `completed` | `live` | `upcoming`
- `StandingType`: `drivers` | `teams` | `manufacturers`

### `championship_data.dart` — `ChampionshipData`

Top-level page payload combining common metadata with optional state-specific blocks.
The page derives its entire layout (live timing, schedule, off-season countdown, etc.)
from a single `ChampionshipData` instance — no per-championship page branching.

Key fields:
- `state`: drives which primary block is shown (live / weekend / off-season)
- `standings`: always present; rendered as one card per `ChampionshipStandingTable`
- `liveGroups`: present only during `liveSession`; feeds `ChampionshipTop3Card`
- `schedule`: present only during `eventWeekend`; feeds `ChampionshipScheduleCard`
- `nextEvent`: present only during `offSeason`; feeds `ChampionshipNextEventCard`
- `circuit` / `weather`: present during `eventWeekend` and `liveSession`

### `championship_circuit.dart`

Side models for circuit and event context:
- `ChampionshipCircuit` — circuit name, location, lap count, length in km
- `ChampionshipWeather` — track/air temp, condition string, rain chance
- `ChampionshipNextEvent` — event name, location, start `DateTime`
- `ChampionshipReplays` — label string for the replay CTA card

### `championship_session.dart` — `ChampionshipSession`

Single session entry for the weekend schedule (name, scheduled time, status).

### `championship_standing.dart`

Season standings models:
- `ChampionshipStandingTable` — one standings category (drivers, teams, etc.)
- `ChampionshipStandingEntry` — one row: position, name, points, optional team

### `championship_live_entry.dart`

Live timing models:
- `ChampionshipLiveGroup` — a labeled group of live entries (one per class in multi-class events)
- `ChampionshipLiveEntry` — one car: position, driver name, team, gap, lap, tyre compound, team color

---

## Mock Data (`championship_mock_data.dart`)

Exports three `ChampionshipData` instances covering all three page states:

| Export | Series | State | What it exercises |
|--------|--------|-------|-------------------|
| `championshipFormula1Mock` | Formula 1 | `liveSession` | 20-car live timing, live top 3, driver + team standings |
| `championshipWecMock` | WEC | `offSeason` | Next-event countdown, multi-class standings (Hypercar / LMP2 / GT3) |
| `championshipMotoGpMock` | MotoGP | `eventWeekend` | Circuit + weather card, tapable session schedule, driver standings |

Also exports:
- `championshipMocks` — ordered list of all three mocks
- `championshipDataById(String id)` — look up a mock by series ID; defaults to F1

---

## Extension Notes

- Adding a new championship requires only a new `ChampionshipData` constant — no page changes.
- Replace mock instances with real API responses behind an abstract service boundary
  without altering any widget code.
- All model classes are `@immutable` and `const`-constructible for efficient rebuilds.
