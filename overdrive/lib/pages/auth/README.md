# Auth Pages

## Purpose

This folder contains the temporary authentication entry flow used by the mobile
app while real account services are not connected yet.

## Responsibilities

- `login_page.dart` owns the sign-in form, local validation, and success navigation.
- `register_page.dart` owns account creation form state, validation, and returning created credentials to login.
- `auth_page_shell.dart` provides the shared visual frame, footer link, and optional info card.

## Dependencies

- `FakeAuthService` for temporary local authentication behavior.
- Shared base widgets such as `OdButton`, `OdTextField`, `OdErrorMessage`, and `OdToast`.
- Theme tokens from `app_theme.dart`.

## Extension Notes

- Keep validation helpers isolated from layout code.
- Replace `FakeAuthService` with the real authentication service without changing shared auth widgets.
- Continue using `AuthPageShell` for new auth-related screens to keep spacing and branding consistent.
