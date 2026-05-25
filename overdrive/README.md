# OverDrive Flutter App

A minimalist Flutter application focused on a `Home` page and several placeholder pages accessible from the menu.

## Detailed Documentation

- `ARCHITECTURE_LIB.md`

## Current Structure

- `lib/main.dart` directly launches `HomePage` and configures the global theme  
- `lib/pages/home/home_page.dart` displays the home screen shell with a solid black background and the floating menu overlay  
- `lib/widgets/menu_overlay.dart` displays `OD`, the `Menu` button, navigation shortcuts, and the `Health` action  
- `lib/widgets/calendar/` contains reusable calendar widgets and models kept independent from page-level demo data  
- `lib/pages/shared/placeholder_page.dart` provides a reusable placeholder screen with a centered title  
- `lib/pages/profile/profile_page.dart` displays the `Profile` page  
- `lib/pages/settings/settings_page.dart` displays the `Settings` page  
- `lib/pages/calendar/calendar_page.dart` displays the `Calendar` page  
- `lib/pages/championship/championship_page.dart` displays the `Championship` page  
- `lib/pages/tv/tv_page.dart` displays the `TV` page  
- `lib/pages/telemetry/telemetry_page.dart` displays the `Telemetry` page  
- `lib/pages/search/search_page.dart` displays the `Search` page  
- `lib/services/health_service.dart` handles the only backend interaction: `GET /health`  
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

The only backend interaction retained is:

- `GET /health`

The backend URL is read from API_BASE_URL if defined. Otherwise, the application uses:

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

Useful commands :

```bash
dart format lib
flutter analyze
```
