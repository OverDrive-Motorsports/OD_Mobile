# Profile Page

## Purpose

`profile_page.dart` renders the profile screen from external profile data plus immutable local page definitions.

## Responsibilities

- Display the account hero card.
- Expose provider and quick-action entry points.
- Keep modal and toast copy centralized instead of scattering raw strings through the layout.

## Dependencies

- Shared base widgets such as `OdButton`, `OdModal`, and `OdToast`.
- `MenuOverlay` for app navigation.
- Theme tokens from `app_theme.dart`.

## Data Model

- `ProfilePageData` contains the external payload consumed by the page.
- `ProfileUserData` describes the displayed user identity.
- `ProfileProviderData` reserves structure for connected providers.

## Extension Notes

- Replace `profilePagePreviewData` with live route or state-managed data when backend integration is ready.
- Add provider list rendering without moving copy or interaction rules back into the widget tree.
