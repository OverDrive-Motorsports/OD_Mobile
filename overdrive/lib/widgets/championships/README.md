# Championship Widgets

## Purpose

This folder contains the reusable presentation widgets used by the championship
pages.

## Widgets

### `championship_top3.dart`

Compact live top-3 card.

Inputs:

- `entries`
- `accentColor`
- `label`

Behavior:

- Shows the first 3 live entries in a single row.
- Highlights P1 differently from P2 and P3.
- Supports optional per-class labels for multi-class live timing.

### `championship_schedule.dart`

Weekend program card.

Inputs:

- `sessions`
- `now`
- `title`

Behavior:

- Finds the next upcoming session automatically.
- Shows compact status badges for completed, next, and upcoming sessions.
- Tapping a row opens the shared modal with the session name as title.

### `championship_standings_widget.dart`

Reusable standings card with optional section switching.

Inputs:

- `title`
- `sections`
- `initialSectionIndex`

Behavior:

- Handles one or multiple tabs of standings data.
- Keeps rendering concerns separate from championship-specific models.

### `championship_replay_btn.dart`

Replay library CTA card.

Inputs:

- `replays`
- `onTap`

Behavior:

- Renders a compact card with play icon, label, subtitle, and chevron.
- Delegates navigation to the caller.

### `championship_icon.dart`

Centered championship tile used elsewhere in the app.

### Header convention

All active widget files in this folder keep the standard OverDrive header block.
This makes ownership and intent consistent across the championship module.
