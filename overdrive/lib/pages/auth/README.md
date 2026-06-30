# Auth Pages

## Purpose

Authentication entry flow for the mobile app. Uses a local in-memory service
(`FakeAuthService`) while the real backend account system is not yet connected.
All three files share `AuthPageShell` for consistent visual framing.

---

## Files

### `login_page.dart` — `LoginPage`

Sign-in form with email and password fields, inline validation, and navigation to
the registration screen. On success, calls `AuthService.login()` which notifies the
GoRouter redirect logic to push the user to the home screen.

### `register_page.dart` — `RegisterPage`

Account creation form with full-name, email, and password fields plus local
validation rules (minimum length, email format). On success, pops back to login
with a pre-filled email so the user can sign in immediately.

### `auth_page_shell.dart` — `AuthPageShell`

Shared visual frame providing consistent background, logo placement, optional
info card, and footer link row. All auth screens should use this shell to keep
spacing and branding consistent.

---

## Dependencies

- `FakeAuthService` (singleton) for in-memory credential storage.
- `AppButton`, `AppTextField`, `ErrorMessage`, `AppToast` from `widgets/base/`.
- Theme tokens from `app_theme.dart`.
- GoRouter (`context.go`) for navigation after authentication.

---

## Extension Notes

- Replace `FakeAuthService` calls in `LoginPage` and `RegisterPage` with the real
  authentication service without touching `AuthPageShell` or base widgets.
- Keep validation helpers (`_validateEmail`, `_validatePassword`) isolated from
  layout code so they can be unit-tested independently.
- Use `AuthPageShell` for any new auth-related screens (forgot password, OTP, etc.).
