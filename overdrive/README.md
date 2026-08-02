# OverDrive Flutter App

OverDrive is a Flutter mobile application designed for a motorsport platform.
The application provides race information, live telemetry visualization,
championship tracking, TV streaming, user profile management and authentication.

---

# Project Structure

The application follows a layered Flutter architecture separating:

- Presentation layer (pages and widgets)
- Services layer (business and API communication)
- Core layer (theme, navigation, shared configuration)

```
lib/
├── config/             Application configuration and routing
├── core/               Shared application logic (theme, navigation)
├── pages/              Application screens
├── services/           Business logic and backend communication
├── widgets/            Reusable UI components
└── main.dart           Application entry point
```

---

# Application Entry

## `lib/main.dart`

Responsible for:

- Initializing the Flutter application.
- Loading environment configuration.
- Configuring application theme.
- Initializing authentication state.
- Starting application routing.

---

# Navigation

## `lib/config/app_router.dart`

The application uses `GoRouter` for navigation.

Responsibilities:

- Define application routes.
- Manage authentication redirects.
- Handle page transitions.

---

# Pages

All application screens are located in:

```
lib/pages/
```

## Authentication

### `pages/login/`

Provides user login functionality.

Features:

- Email/password authentication.
- Form validation.
- Backend authentication request.
- Session creation.

---

### `pages/signup/`

Provides account creation.

Features:

- Username validation.
- Email validation.
- Password validation.
- Password confirmation.
- Backend registration request.

---

## Main Application Pages

| Page | Purpose |
|------|---------|
| `home/` | Main application dashboard |
| `profile/` | User information and profile actions |
| `settings/` | Application preferences |
| `calendar/` | Race event calendar |
| `championship/` | Championship information |
| `telemetry/` | Live race telemetry dashboard |
| `tv/` | Race video streaming |
| `search/` | Search functionality |
| `shared/` | Shared placeholder pages |

---

# Authentication

Authentication logic is isolated inside:

```
lib/services/auth/
```

## `auth_service.dart`

Responsible for:

- Login.
- Signup.
- Session management.
- JWT storage.
- Refresh token handling.
- Logout.
- Session validation.

Authentication data is stored securely using:

```
FlutterSecureStorage
```

Storage:

- Android → Keystore
- iOS → Keychain

---

## Authentication Flow

```
Application Start
        |
        v
Restore Stored Session
        |
        v
Validate Token
        |
        +------ Valid ------> Home
        |
        +------ Expired -----> Refresh Token
                                      |
                                      +---- Success ---> Home
                                      |
                                      +---- Failed ----> Login
```

---

# Services

Business logic and backend communication are located in:

```
lib/services/
```

Structure:

```
services/
├── auth/              Authentication and session management
├── calendar/          Calendar data handling
├── championship/      Championship models and data
├── tv/                TV stream management
└── health/            Backend health checking
```

---

# API Communication

HTTP communication is handled through:

```
services/auth/api_client.dart
```

Responsibilities:

- Configure Dio client.
- Add authorization headers.
- Handle expired tokens.
- Refresh authentication session.
- Retry failed requests.

---

# Backend Configuration

Backend URL is configured using:

```env
API_BASE_URL=http://localhost:3001
```

Resolution priority:

1. `.env` configuration.
2. Platform defaults.

## Android Emulator

```
http://10.0.2.2:3001
```

## Web / Desktop / iOS Simulator

```
http://localhost:3001
```

For physical devices:

```
http://YOUR_LOCAL_IP:3001
```

---

# Widgets

Reusable UI components are stored in:

```
lib/widgets/
```

Structure:

```
widgets/
├── base/
├── calendar/
├── championships/
├── navigation/
├── telemetry/
└── tv/
```

---

# Base Widgets

Located in:

```
widgets/base/
```

Contains shared design components:

| Widget | Purpose |
|-|-|
| `AppButton` | Application buttons |
| `AppModal` | Bottom sheet dialogs |
| `AppTextField` | Styled input fields |
| `AppToast` | Notifications |
| `ErrorMessage` | Error display component |
| `AppSwitch` | Toggle controls |
| `MenuOverlay` | Navigation overlay |

---

# Telemetry System

Located in:

```
pages/telemetry/
widgets/telemetry/
```

Provides:

- Live telemetry dashboard.
- Draggable widgets.
- Resizable grid layout.
- Race data visualization.

Supported widgets include:

- Speedometer.
- RPM indicator.
- Gear display.
- Throttle/brake visualization.
- Lap timing.
- Tire temperatures.
- Fuel information.
- Weather data.
- Race standings.

---

# Theme System

Global styling is centralized in:

```
lib/core/theme/app_theme.dart
```

Contains:

- Application colors.
- Typography.
- Shared design tokens.

All UI components should use:

```dart
AppColors
AppTextStyles
```

instead of hardcoded values.

---

# Environment

Supported environment files:

```
.env
.env.prod
```

Required variables:

```env
API_BASE_URL
APP_ENV
```

Production launch:

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

---

# Development Commands

Format project:

```bash
dart format lib
```

Analyze code:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

---
