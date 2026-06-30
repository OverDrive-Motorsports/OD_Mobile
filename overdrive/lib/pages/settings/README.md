# Settings Page

## Purpose

`settings_page.dart` renders the application settings screen from immutable toggle and action definitions.

## Responsibilities

- Maintain local toggle state.
- Render grouped settings sections with shared widgets.
- Centralize modal copy and action metadata outside the widget tree.

## Dependencies

- `AppButton`, `AppSwitch`, `AppModal`, `AppToast` from `widgets/base/`.
- `NavigationShell` provides the bottom navigation frame (injected by GoRouter).
- Theme tokens from `app_theme.dart`.

## Data Model

- `SettingsToggleDefinition` describes a toggle row and its default value.
- `SettingsActionDefinition` describes a footer action button.
- `SettingsModalContent` stores storage modal copy.

## Extension Notes

- Replace local state with persisted settings when profile or device storage is connected.
- Keep new toggles and actions declarative by adding definitions instead of duplicating widget code.
