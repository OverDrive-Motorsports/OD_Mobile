# Replay Page

## Purpose

`replay_page.dart` is a lightweight route used as the current destination for
replay CTAs coming from championship pages.

## Responsibilities

- Accept an injected title from the originating championship flow.
- Reuse the shared placeholder shell while the dedicated replay experience is
  still being designed.

## Dependencies

- `PlaceholderPage` from `pages/shared`.

## Extension Notes

- Keep navigation inputs data-driven so the future replay page can open with the
  right championship context.
- When the real replay feature is implemented, this route should stay small and
  compose replay-specific widgets rather than embed all UI directly here.
