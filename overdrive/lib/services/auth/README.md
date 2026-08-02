# Auth Service

## Purpose

`auth_service.dart` manages the authentication lifecycle of the OverDrive mobile application.
It handles login, registration, session restoration, secure token persistence, token refresh,
and logout operations.

The service separates authentication logic from UI screens and keeps user session data securely
stored using encrypted device storage.

---

## Files

- `auth_service.dart` — main authentication manager responsible for user identity lifecycle and session state.

---

## Main Classes

| Class | Purpose |
|-------|---------|
| `AuthService` | Singleton service handling authentication operations and session state |
| `AuthTokens` | Immutable model containing JWT, refresh token, session ID and expiration data |
| `AuthServiceException` | Wrapper for authentication-related errors displayed to the application |

---

## Responsibilities

### Authentication Flow

| Method | Purpose |
|--------|---------|
| `login()` | Sends user credentials, receives authentication tokens and creates a session |
| `signup()` | Creates a new user account through backend registration endpoint |
| `logout()` | Removes stored credentials and resets authentication state |

---

### Session Management

| Method | Purpose |
|--------|---------|
| `initialize()` | Restores authentication state when the application starts |
| `hasValidSession()` | Checks stored credentials and validates current session |
| `refreshTokens()` | Requests new authentication tokens when the access token expires |

---

## Secure Storage

Authentication data is stored with `FlutterSecureStorage` to keep sessions persistent between app launches.

Stored values:

| Key | Purpose |
|-----|---------|
| `od_access_token` | JWT used for authenticated API requests |
| `od_session_id` | Backend session identifier |
| `od_refresh_token` | Token used to refresh expired access tokens |
| `od_expires_at` | Access token expiration timestamp |

---

## Authentication Flow

### Login


User credentials
|
v
AuthService.login()
|
v
POST /login
|
v
Receive JWT + refresh token + session ID
|
v
Save credentials securely
|
v
Authenticated session


---

### Registration


User information
|
v
AuthService.signup()
|
v
POST /register
|
v
Account created
|
v
User can authenticate


---

### Session Restoration

At application startup:


Application launch
|
v
hasValidSession()
|
+---- Valid token
| |
| v
| Continue session
|
+---- Expired token
|
v
refreshTokens()
|
+--------+--------+
| |
Success Failure
| |
v v
New session Logout user


---

## Dependencies

- `FlutterSecureStorage` — encrypted storage for authentication credentials.
- `Dio` — HTTP client for authentication requests.
- `flutter_dotenv` — API configuration management.
- `ChangeNotifier` — exposes authentication state changes.

---

## Error Handling

`AuthServiceException` converts backend and network errors into application-level messages.

Examples:

| Error | Cause |
|-------|-------|
| `JWT token missing` | Backend returned incomplete authentication response |
| `Refresh token missing` | Refresh response does not contain required credentials |
| `No refresh token` | Session cannot be renewed |
| `Backend timeout` | API request exceeded allowed timeout |

---

## Security Notes

- Authentication tokens are stored using encrypted platform storage:
  - Android Keystore
  - iOS Keychain
- Credentials are not stored in plain text.
- Refresh tokens are used only to maintain active sessions.
- Logout removes all locally stored authentication data.

---

## Extension Notes

- HTTP communication should use the shared `ApiClient` instead of creating separate Dio clients.
- New authenticated services should reuse the existing token management flow.
- Authentication providers can be added by extending the login flow without changing storage logic.
- UI validation should remain inside pages while authentication rules stay inside this service.