# OverDrive Flutter App

The `overdrive/` module contains the Flutter mobile application for OverDrive.
It provides authentication screens, shared navigation, reusable UI primitives,
and data-driven motorsport pages.

## Current Structure

- `lib/main.dart` starts the app, loads the optional environment file, and uses the shared dark theme.
- `lib/core/navigation/app_routes.dart` centralizes route names, page builders, and menu entries.
- `lib/core/theme/app_theme.dart` centralizes app colors, typography, and Flutter theme configuration.
- `lib/pages/auth/` contains the temporary local login and registration flow.
- `lib/pages/home/` hosts the current home shell and shared menu overlay.
- `lib/pages/calendar/` composes championship filters, the monthly calendar, and event cards.
- `lib/pages/championship/` renders adaptive championship pages from data models and mocks.
- `lib/pages/profile/`, `lib/pages/settings/`, `lib/pages/search/`, and `lib/pages/tv/` provide the main app surfaces.
- `lib/pages/replay/` and `lib/pages/telemetry/` currently reuse the shared placeholder route.
- `lib/widgets/` contains shared base widgets, calendar widgets, TV widgets, championship widgets, and navigation primitives.
- `lib/services/` contains temporary mock services and the retained backend health check.

## Theme Convention

Pages and widgets should use `AppColors` and `AppTextStyles` from
`lib/core/theme/app_theme.dart` for visual colors and typography. Do not add new
theme tokens without confirming the need first.

## Header Convention

Active Dart files in `lib/` use the standard OverDrive header adapted to each
file:

```dart
/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## file_name.dart - Brief description of the file purpose.
 ##
 */
```

## Backend

The retained backend interaction is:

- `GET /health`

The backend URL is read from `API_BASE_URL` when defined. Otherwise, the
application uses:

- `http://10.0.2.2:8080` on Android
- `http://localhost:8080` elsewhere

## Environment

Supported environment files:

- `.env` for development
- `.env.prod` for production

Required variables:

- `API_BASE_URL`
- `APP_ENV`

Run with the production environment file:

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Code Quality

Useful commands:

```bash
dart format lib
flutter analyze
```

There is no dedicated test suite in this module at the moment.
