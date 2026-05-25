# TV Page

## Purpose

`tv_page.dart` renders the full-screen TV experience. It displays the active
live player, top overlay controls, stream metadata, and a stream picker sheet.

## Responsibilities

- Maintain the currently selected `TvStream`.
- Compose `TvLivePlayer` as the full-screen background player.
- Provide floating controls for leaving the TV page and opening stream selection.
- Keep stream selection inside a reusable modal sheet.

## Dependencies

- `tv_mock_data.dart` for temporary stream data.
- `TvLivePlayer` from `widgets/tv/tv_live_player.dart`.
- `TvStreamSelectorSheet` from `widgets/tv/tv_stream_selector_sheet.dart`.
- `OdModal` for stream selection.

## Extension Notes

- Swap mock streams for the real TV/live service when the backend is ready.
- Keep page-level logic focused on selection and navigation; put player-specific behavior in TV widgets.
