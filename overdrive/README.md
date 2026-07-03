# OverDrive

A minimalist Flutter application focused on a `Home` page and several placeholder pages accessible from the menu.

## Detailed Documentation

- `ARCHITECTURE_LIB.md`

## Current Structure

### Authentication
- `lib/pages/auth/auth_gate.dart` routes the app based on session validity (entry point)
- `lib/pages/auth/login_page.dart` login screen with email/password validation
- `lib/pages/auth/signup_page.dart` signup screen with password confirmation
- `lib/services/auth_service.dart` handles OAuth token acquisition, storage, and refresh

### Pages & UI
- `lib/main.dart` configures the app, theme, and launches `AuthGate`
- `lib/pages/home/home_page.dart` displays the home screen with menu overlay
- `lib/widgets/menu_overlay.dart` displays `OD`, the `Menu` button, navigation shortcuts, and the `Health` action  
- `lib/pages/shared/placeholder_page.dart` provides a reusable placeholder screen with a centered title  
- `lib/pages/profile/profile_page.dart` displays the `Profile` page  
- `lib/pages/settings/settings_page.dart` displays the `Settings` page  
- `lib/pages/calendar/calendar_page.dart` displays the `Calendar` page  
- `lib/pages/championship/championship_page.dart` displays the `Championship` page  
- `lib/pages/tv/tv_page.dart` displays the `TV` page  
- `lib/pages/telemetry/telemetry_page.dart` displays the `Telemetry` page  
- `lib/pages/search/search_page.dart` displays the `Search` page  

### Services
- `lib/services/health_service.dart` handles health check: `GET /health`  
- `lib/services/api_client.dart` configures the HTTP client with auth interceptors
- `lib/core/theme/app_theme.dart` centralizes the theme, colors, and styles  

## Header Convention

All Dart files in `lib/` now start with the following standard header, adapted to each file:

```dart
/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [FileName] - [Brief description of the file's purpose]
 ##
 */

## Backend

The application communicates with the backend via the following endpoints:

### Authentication Endpoints
- `POST /auth/login` - Login with email/password, returns `{access_token, refresh_token, expires_in}`
- `POST /auth/signup` - Signup with email/password, returns `{access_token, refresh_token, expires_in}`
- `POST /auth/refresh` - Refresh expired tokens using refresh token

### Health Check
- `GET /health` - Returns server health status: `{status, time}`

### Base URL Configuration
The backend URL is resolved in the following priority order:

1. `API_BASE_URL` environment variable (if set)
2. Platform default:
   - Android emulator: `http://10.0.2.2:8080`
   - iOS, Web, physical devices: `http://localhost:8080`

**Note:** On a real Android phone, set `API_BASE_URL` to your computer's LAN IP (e.g., `http://192.168.1.100:8080`)

## Authentication

### Session Flow
1. **App Startup**: `AuthGate` checks `AuthService.hasValidSession()`
2. **Valid Session**: User navigated to `HomePage` directly
3. **Invalid/Expired Session**: User shown `LoginPage`
4. **Token Refresh**: If token expired but refresh token valid, automatically refreshes before showing `LoginPage`

### Secure Token Storage
- Access tokens and refresh tokens are stored using `FlutterSecureStorage`
- iOS: Stored in Keychain
- Android: Stored in Keystore (encrypted)
- Tokens are **not** stored in shared preferences or unencrypted storage

### Form Validation
- **Email**: Required, must contain `@`, minimum 5 characters
- **Password**: Required, minimum 8 characters
- **Confirm Password** (signup only): Must match password field
- Validation errors displayed inline in red text

### Error Handling
- **Invalid credentials**: Server error message displayed
- **Network timeout**: Helpful message about emulator configuration
- **Empty fields**: Inline validation errors prevent submission
- **Malformed response**: Generic error message + check backend

## Tests

The existing widget test verifies that the home screen correctly displays OD and the Menu button.

## Code Quality

Useful commands :

```bash
dart format lib
flutter analyze
```
