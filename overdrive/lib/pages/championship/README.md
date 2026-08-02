# Championship Page

## Purpose

`championship_page.dart` renders one adaptive championship experience from
`ChampionshipData`. The page does not branch into separate per-series screens:
the same structure is reused for Formula 1 live timing, WEC off-season, and
MotoGP event-weekend flows.

## Responsibilities

- Render the shared hero block from the championship headline and metadata.
- Build a common stack of content blocks from available data:
  primary card, schedule, standings, replay CTA.
- Keep the route layer small and push most presentation details into reusable
  championship widgets.
- Derive visual variations from the data model instead of hardcoding per-series
  UI branches.

## Structure

- `ChampionshipPage`: route-level composition and page spacing.
- `_PageHero`: main title plus secondary metadata line.
- `_buildPrimaryBlock`: chooses one leading card from the available data.
  Live: direct overview with top 3 and action buttons.
  Weekend: circuit and weather card.
  Off-season: next-event countdown card.
- `_StandingsBlock` and `_LiveStandingsBlock`: adapt page data to the shared
  `ChampionshipStandingsWidget`.

## Dependencies

- `services/championship/*`: enums, models, and mocks.
- `widgets/championships/championship_top3.dart`
- `widgets/championships/championship_schedule.dart`
- `widgets/championships/championship_standings.dart`
- `widgets/championships/championship_circuit_weather.dart`
- `widgets/championships/championship_next_event.dart`
- `pages/replay/replay_page.dart`

## Notes

- Live standings reuse the same standings widget as season standings and only
  change the mapped labels and values.
- When multiple standing categories exist, the page groups them into separate
  cards automatically.
- Active championship files all keep the standard OverDrive file header so the
  module stays traceable and consistent.
