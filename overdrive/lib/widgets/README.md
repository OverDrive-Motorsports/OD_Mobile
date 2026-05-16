# Widgets

This directory contains the shared presentation layer for the OverDrive app.
Pages should compose these widgets instead of rebuilding the same UI patterns.

## Principles

- Keep widgets reusable and explicitly typed.
- Keep business logic outside UI primitives whenever possible.
- Prefer small, composable files over page-specific one-off rendering.
- Reuse shared visual primitives such as `GlassPill` or the base widget library before adding new styles.

## Base Widgets

### `base/od_button.dart`

Reusable pill button for standard actions across the app.

Main API:
- `OdButton`

Props:
- `label`: button text.
- `onPressed`: tap callback. Passing `null` disables the button.
- `leadingIcon`: optional icon displayed before the label.
- `isLoading`: replaces the icon with a spinner and disables taps.
- `fullWidth`: stretches the button to the available width.

Behavior:
- Uses a 44px minimum touch target.
- Applies a subtle press animation for active taps.
- Keeps one consistent dark outlined visual style for the whole app.

### `base/od_text_field.dart`

Reusable rounded text field inspired by Cupertino input styling.

Main API:
- `OdTextField`

Props:
- `placeholder`: placeholder text.
- `controller`: optional external controller. The widget creates one internally when omitted.
- `obscureText`: hides the text for passwords or secrets.
- `keyboardType`: configures the keyboard type.
- `errorMessage`: optional inline error message displayed under the field.
- `leadingIcon`: optional icon inside the field.
- `onClear`: optional callback enabling the clear action when text is not empty.
- `onChanged`: input callback.

Behavior:
- Uses a dark rounded container and white input text.
- Uses the app accent color for the cursor.
- Highlights the field in red when `errorMessage` is present.

### `base/od_error_message.dart`

Reusable error presentation widget with two visual variants.

Main API:
- `OdErrorMessage`
- `ErrorMessageVariant`

Props:
- `message`: required main message.
- `subtitle`: optional secondary text for the banner variant.
- `variant`: either `inline` or `banner`.

Behavior:
- `inline` is intended for field-level validation.
- `banner` is intended for section or page-level feedback.

### `base/od_toast.dart`

Singleton toast overlay for temporary feedback messages.

Main API:
- `OdToast.show`
- `ToastType`

Arguments:
- `context`
- `message`
- `type`
- `duration`

Behavior:
- Only one toast can be visible at a time.
- Showing a new toast removes the currently displayed one first.
- Appears with slide-up and fade animations.

### `base/od_modal.dart`

Reusable bottom sheet helper with a blurred backdrop and rounded top corners.

Main API:
- `OdModal.show`

Arguments:
- `context`
- `title`
- `child`
- `showHandle`
- `isDismissible`

Behavior:
- Uses a custom popup route.
- Keeps the sheet slightly below the screen edge for a native floating-sheet feel.
- Supports tap-outside dismissal and drag-down dismissal when enabled.

### `base/od_switch.dart`

Reusable Cupertino switch row.

Main API:
- `OdSwitch`

Props:
- `value`
- `onChanged`
- `label`

Behavior:
- Keeps native Cupertino switch dimensions.
- Uses the OverDrive red accent for the active track.
- When `label` is present, the widget renders a 44px high row.

## Shared Primitives

### `glass_pill.dart`

Reusable translucent pill surface used by compact controls.

Main API:
- `GlassPill`

Props:
- `child`
- `highlighted`
- `disabled`
- `padding`
- `backgroundColor`
- `borderColor`
- `borderRadius`

Typical usage:
- menu trigger
- search surface
- future compact floating controls

### `search_bar.dart`

Presentational search bar with externalized state and callbacks.

Main API:
- `SearchBar`
- `SearchBarProps`

`SearchBarProps` fields:
- `controller`
- `onSearch`
- `onClear`
- `placeholder`
- `enabled`
- `autofocus`
- `focusNode`
- `textInputAction`

Behavior:
- Displays a clear action when the field is focused or non-empty.
- Does not perform searches by itself.
- Does not own search business logic.

### `menu_overlay.dart`

Floating top-level menu overlay used above pages.

Main API:
- `MenuOverlay`

Related widgets in the same file:
- `MenuButton`
- `MenuPanel`
- `MenuAction`
- `MenuEntry`

Behavior:
- Displays the `OD` brand mark and the menu trigger.
- Opens a floating panel with navigation and backend health actions.
- Uses `HealthService` for the health check action.

## Calendar Widgets

### `calendar/monthly_calendar.dart`

Reusable monthly calendar view decoupled from page logic.

Main API:
- `MonthlyCalendar`

Props:
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

Behavior:
- Uses a vertical `PageView` to navigate months.
- Supports external selection control.
- Remains presentational and demo-data free.

### `calendar/event_calendar.dart`

Reusable list of schedule cards and related calendar models.

Main API:
- `EventCalendar`
- `CalendarEventMarker`
- `CalendarScheduleEvent`
- `CalendarScheduleStatus`

Props on `EventCalendar`:
- `events`
- `today`
- `selectedDate`
- `onEventTap`
- `emptyTitle`
- `emptySubtitle`

Behavior:
- Distinguishes past, ongoing and upcoming events.
- Supports empty-state rendering.
- Stays presentation-focused so it can be reused on multiple pages.

## Championship Widgets

### `championships/championship_icon.dart`

Reusable championship tile with centered logo content.

Main API:
- `ChampionshipIcon`

Props:
- `name`
- `logoAsset`
- `subtitle`
- `isFavorite`
- `onTap`

Behavior:
- Supports both asset logos and emoji fallback content.
- Reuses `GlassPill` for the circular icon surface.

### `championships/championship_top3.dart`

Compact live podium card used by championship live pages.

Main API:
- `ChampionshipTop3`

Props:
- `entries`
- `accentColor`
- `label`

Behavior:
- Displays the first 3 live entries in a compact 3-column layout.
- Supports optional per-category labels for multi-class live timing.
- Gives the leader a stronger visual emphasis than P2 and P3.

### `championships/championship_schedule.dart`

Reusable weekend program card.

Main API:
- `ChampionshipSchedule`

Props:
- `sessions`
- `now`
- `title`

Behavior:
- Automatically identifies the next upcoming session.
- Displays session badges for completed, next, live, and upcoming states.
- Opens the shared `OdModal` with the session name when a row is tapped.

### `championships/championship_standings_widget.dart`

Reusable standings card with optional section switching.

Main API:
- `ChampionshipStandingsWidget`
- `ChampionshipStandingsSection`
- `ChampionshipStandingEntry`

Props on `ChampionshipStandingsWidget`:
- `title`
- `sections`
- `initialSectionIndex`

Props on `ChampionshipStandingsSection`:
- `label`
- `entries`
- `leadingColumnLabel`
- `middleColumnLabel`
- `trailingColumnLabel`

Props on `ChampionshipStandingEntry`:
- `position`
- `title`
- `trailingValue`
- `subtitle`
- `middleValue`
- `imageUrl`
- `avatarLabel`
- `avatarColor`

Behavior:
- Switches cleanly between multiple standings sections.
- Supports text avatars or remote images.
- Keeps all standings rendering presentational.

### `championships/championship_replay_btn.dart`

Reusable replay call-to-action card.

Main API:
- `ChampionshipReplayBtn`

Props:
- `replays`
- `onTap`

Behavior:
- Renders a compact replay library entry card.
- Keeps navigation handling outside the widget.

## Maintenance Checklist

Before adding or editing a widget here, verify:
- Can this UI be reused elsewhere?
- Are state ownership and callbacks clearly typed?
- Can optional behavior be explained with a short inline comment?
- Should the visual treatment be extracted into a smaller shared primitive?
