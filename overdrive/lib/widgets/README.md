# Widgets

This directory contains the shared UI widgets used across the OverDrive application.

The idea is simple:
- `widgets/` contains reusable UI building blocks
- pages consume these widgets instead of duplicating their rendering
- when behavior is specific to a page, it should stay in that page or in a dedicated hook/service
- calendar-related widgets now live in `widgets/calendar/`

<br>



## `glass_pill.dart`

Reusable visual primitive for buttons and fields using a "pill" style.

Responsibilities:
- apply the semi-transparent background
- handle normal, focus/highlight, and disabled borders
- centralize shared styling across multiple widgets

Typical use cases:
- menu button
- search bar
- future compact buttons or floating controls

<br>

## `search_bar.dart`

Reusable and purely presentational search bar.

Responsibilities:
- display the search icon
- display the text field
- display the clear action as an external button when the field is focused or non-empty
- expose typed callbacks to the parent

This widget should not:
- make API calls
- know which page it is rendered in
- contain search business logic

Main API:
- `SearchBar`
- `SearchBarProps`

Available props:
- `controller`
- `onSearch`
- `onClear`
- `placeholder`
- `enabled`
- `autofocus`
- `focusNode`
- `textInputAction`

<br>

## `menu_overlay.dart`

Navigation overlay displayed above pages.

Responsibilities:
- display the `OD` logo
- display the `Menu` button
- open/close the floating panel
- provide quick navigation actions
- display backend health status through `HealthService`

This file contains several related widgets:
- `MenuOverlay`
- `MenuButton`
- `MenuPanel`
- `MenuAction`
- `MenuEntry`

<br>

## `calendar/monthly_calendar.dart`

Reusable monthly calendar decoupled from pages.

Responsibilities:
- display a full month view
- handle vertical navigation between months with `PageView`
- expose a typed API for the selected date and callbacks
- stay intentionally minimal in its rendering

Main API:
- `MonthlyCalendar`

Available props:
- `selectedDate`
- `initialMonth`
- `eventsByDate`
- `onDateSelected`
- `onMonthChanged`
- `isLoading`
- `firstAvailableMonth`
- `lastAvailableMonth`
- `today`
- `weekdayLabels`
- `monthLabelBuilder`

Note:
- this widget remains purely presentational and does not embed any demo data

<br>

## `calendar/event_calendar.dart`

Reusable event list decoupled from pages.

Responsibilities:
- display events inside OverDrive-styled cards
- visually differentiate past, ongoing, and upcoming events
- expose a typed API based on a list of `CalendarScheduleEvent`
- remain presentational so it can be reused on other screens
- expose shared calendar event models used by other calendar widgets

Main API:
- `EventCalendar`
- `CalendarEventMarker`
- `CalendarScheduleEvent`
- `CalendarScheduleStatus`

Available props:
- `events`
- `today`
- `selectedDate`
- `onEventTap`
- `emptyTitle`
- `emptySubtitle`

Note:
- this widget does not embed any hardcoded event list

<br>

## `championships/championship_icon.dart`

Reusable championship tile inspired by sports app grids.

Responsibilities:
- display a circular dark championship icon container based on `GlassPill`
- render a centered asset logo or emoji fallback
- display the championship name below the icon
- optionally display a small muted subtitle
- optionally display a favorite star prefix before the title
- expose a simple tap callback

Main API:
- `ChampionshipIcon`

Available props:
- `name`
- `logoAsset`
- `subtitle`
- `isFavorite`
- `onTap`

<br>

## `championships/championship_standings_widget.dart`

Reusable championship standings card with an optional segmented switch between sections.

Responsibilities:
- display a standings title
- optionally switch between multiple standings sections inside the same card
- display column headers such as driver or constructor, wins, and points
- display a main row title with an optional subtitle
- support avatar initials or remote images for each standings row

Main API:
- `ChampionshipStandingsWidget`
- `ChampionshipStandingsSection`
- `ChampionshipStandingEntry`

Available props on `ChampionshipStandingsWidget`:
- `title`
- `sections`
- `initialSectionIndex`

Available props on `ChampionshipStandingsSection`:
- `label`
- `entries`
- `leadingColumnLabel`
- `middleColumnLabel`
- `trailingColumnLabel`

Available props on `ChampionshipStandingEntry`:
- `position`
- `title`
- `trailingValue`
- `subtitle`
- `middleValue`
- `imageUrl`
- `avatarLabel`
- `avatarColor`

Note:
- this widget remains presentational and should not embed demo data directly

<br>

## Directory Rules

- prefer reusable and well-isolated widgets
- keep props explicitly typed
- avoid injecting business logic into UI primitives
- extract shared styling into a common widget when multiple components look alike

<br>

## Recommended Checklist

Before adding a new widget here, ask:
- can this component be reused elsewhere?
- does it stay presentational or at least well decoupled?
- should part of its styling be factored into something like `GlassPill`?
