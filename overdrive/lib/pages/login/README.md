# Login Page

## Purpose

`login_page.dart` renders the authentication screen for existing users.
It provides an email/password form, performs local validation before submitting,
sends credentials to the authentication service, stores the received session tokens,
and redirects authenticated users to the main application.

The page only handles UI state and user interaction. Authentication logic remains
centralized inside `auth_service.dart`.

---

## Files

- `login_page.dart` — complete login screen with form validation, loading state,
  backend error display, and navigation after successful authentication.

---

## Data Models (used from external files)

| Model | Purpose |
|-------|---------|
| `AuthService` | Handles login requests, token storage and session management |
| `AuthServiceException` | Represents authentication failures returned by backend |
| `AuthTokens` | Stores access token, refresh token, session ID and expiration data |

---

## Dependencies

- `AuthService` from `services/auth/auth_service.dart`.
- `AppColors` and `AppTextStyles` from `core/theme/app_theme.dart`.
- `GoRouter` for application navigation.
- Flutter `Form` and `TextFormField` widgets for input handling.

---

## Authentication Flow

1. User enters email and password.
2. Local validators check required fields and minimal format rules.
3. Credentials are sent to `AuthService.login()`.
4. Backend response tokens are securely stored.
5. User is redirected to the application home route.

---

## Validation

Current client-side checks:

- Email must not be empty.
- Email must contain a valid basic format.
- Password must contain at least 8 characters.

Backend validation remains the source of truth for authentication.

---

## Extension Notes

- Add password visibility toggle without changing authentication logic.
- Add dedicated error mapping for backend responses (invalid credentials, blocked user, expired session).