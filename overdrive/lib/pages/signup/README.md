# Signup Page

## Purpose

`signup_page.dart` renders the account creation screen.
It collects username, email, and password information, validates user input locally,
sends registration data to the authentication service, and redirects the user
to the login screen after successful account creation.

The page is responsible only for registration UI flow. Account creation logic and
backend communication are handled by `auth_service.dart`.

---

## Files

- `signup_page.dart` — complete registration screen with input validation,
  loading state management, backend error display, and navigation to login.

---

## Data Models (used from external files)

| Model | Purpose |
|-------|---------|
| `AuthService` | Sends registration requests and manages authentication communication |
| `AuthServiceException` | Represents registration errors returned by backend |

---

## Dependencies

- `AuthService` from `services/auth/auth_service.dart`.
- `AppColors` and `AppTextStyles` from `core/theme/app_theme.dart`.
- `GoRouter` for navigation between authentication routes.
- Flutter form widgets for input validation and user interaction.

---

## Registration Flow

1. User enters username, email and password.
2. Local validators check required fields and password requirements.
3. Registration request is sent through `AuthService.signup()`.
4. Backend creates the account.
5. User is redirected to the login page.

---

## Validation

Current client-side checks:

- Username must not be empty.
- Email must have a valid format.
- Password must respect minimum length requirements.
- Confirmation password must match the original password.

Backend validation remains responsible for:
- Existing email detection.
- Existing username detection.
- Password security policies.
- Account creation rules.

---

## Extension Notes

- Add password visibility toggle for better user experience.
- Add stronger password rules (uppercase, numbers, special characters).