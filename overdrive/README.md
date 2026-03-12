# OverDrive Mobile (Flutter)

Flutter mobile client for the OverDrive ecosystem.

## What Is Implemented

The current app is a multi-page shell focused on a liquid-glass iOS-style interface:

- **Home**: schedule dashboard with day tabs (`Hier`, `Aujourd'hui`, `A venir`)
- **Formula 1**: event sessions + driver standings (20 drivers)
- **TV**: single stream card (`CANAL+ SPORT CHINE`)
- **Global overlay menu**: `OD` (top-left) + `Accueil` button (top-right) on every page

Navigation between pages is controlled through a shared `ValueNotifier<int>`.

## Tech Stack

- Flutter / Dart SDK `^3.10.7`
- `go_router` for routing
- `flutter_dotenv` for environment loading
- `google_fonts` for typography
- `flutter_animate` (present in dependencies)
- `dio` + `pretty_dio_logger` for API client services

## Project Structure

```text
lib/
  main.dart
  core/
    router/
      app_router.dart
      app_scaffold.dart
      app_navigation_controller.dart
    theme/
      app_theme.dart
    constants/
      app_constants.dart
  pages/
    home/home_page.dart
    f1/f1_page.dart
    tv/tv_page.dart
  widgets/
    glass_card.dart
    top_left_menu_overlay.dart
    app_navigation.dart
  services/
    api_service.dart
    api_interceptor.dart
    api_response.dart
```

## App Bootstrap Flow

1. `main()` initializes Flutter bindings.
2. Environment file is loaded from `ENV_FILE` (`.env` by default).
3. `OverDriveApp` starts `MaterialApp.router` with `appRouter`.
4. The root route (`/`) renders `AppScaffold`.
5. `AppScaffold` switches pages via `IndexedStack` and `appNavigationIndex`.

## Routing and Navigation

- Routing entry point: `lib/core/router/app_router.dart`
- Shell state container: `lib/core/router/app_scaffold.dart`
- Shared index state: `lib/core/router/app_navigation_controller.dart`

The `TopLeftMenuOverlay` updates `appNavigationIndex`, and `AppScaffold` reacts by switching the visible page.

## Theming

Theme and design tokens are centralized in `lib/core/theme/app_theme.dart`:

- `AppColors`
- `AppTextStyles`
- `AppTheme.darkTheme`

Reusable liquid-glass components are in `lib/widgets/glass_card.dart`.

## Environment Configuration

Environment assets are declared in `pubspec.yaml`:

- `.env`
- `.env.prod`

Required variables:

- `API_BASE_URL`
- `APP_ENV`

Example (`.env`):

```env
API_BASE_URL=http://10.0.2.2:8080
APP_ENV=dev
```

For a real phone, `10.0.2.2` does not work. Use your computer LAN IP:

```env
API_BASE_URL=http://192.168.x.x:8080
APP_ENV=dev
```

Run with production env file:

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Commands

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run the app with filtered emulator noise logs:

```bash
./scripts/run_filtered_logs.sh
```

Analyze code:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Format source:

```bash
dart format lib test
```

## Notes

- `lib/widgets/app_navigation.dart` still exists in the repository but is not part of the current active navigation flow.
- API service files exist and are ready for backend integration, but current page content is mostly mocked UI data.
