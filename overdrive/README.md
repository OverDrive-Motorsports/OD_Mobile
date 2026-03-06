# OverDrive Mobile

Flutter mobile client for the OverDrive project.

## Module Purpose

The current app is a base mobile shell with:
- environment loading at startup
- a reusable REST client built on Dio
- a Home screen that calls `/health` and displays API status/time

## Tech Stack

- Flutter / Dart SDK `^3.10.7`
- `dio` for HTTP requests
- `flutter_dotenv` for environment variables
- `pretty_dio_logger` for request/response logging

## Project Layout

```text
lib/
  main.dart
  features/
    home/presentation/home_screen.dart
  services/
    api_service.dart
    api_interceptor.dart
    api_response.dart
  core/
    constants/app_constants.dart
    theme/app_theme.dart
    utils/logger.dart
  shared/
    widgets/app_scaffold.dart
```

## Startup Flow

1. `main()` calls `WidgetsFlutterBinding.ensureInitialized()`.
2. Environment file is loaded from `ENV_FILE` (`.env` by default).
3. `MyApp` reads `APP_ENV` and injects it into the app title.
4. The app opens `HomeScreen`.

Code reference: `lib/main.dart`.

## Home Screen Behavior

`HomeScreen` (`lib/features/home/presentation/home_screen.dart`) manages 3 UI states:
- `idle`
- `loading`
- `result`

When the user taps **Check Health**:
- it calls `ApiService.checkHealth()`
- on success, it renders `status` and `time` from the JSON response
- on failure, it renders an error message

## Network Layer

### Architecture

- UI should call `ApiService` only.
- HTTP client concerns are centralized in `services/`.
- API results are wrapped in `ApiResponse<T>` to avoid raw exception handling in UI code.

### `ApiService`

`lib/services/api_service.dart`:
- reads `API_BASE_URL` from `.env`
- configures Dio with `connectTimeout = 10s` and `receiveTimeout = 10s`
- registers `ApiInterceptor()` and `PrettyDioLogger(...)`
- validates `API_BASE_URL` before requests
- exposes generic `get<T>()` and `checkHealth()` for `GET /health`
- maps Dio errors to user-facing messages

Important: `PrettyDioLogger` is currently added unconditionally in the constructor.

### `ApiInterceptor`

`lib/services/api_interceptor.dart`:
- currently extends Dio `Interceptor` with no overrides
- acts as the insertion point for Bearer token injection, global request/response hooks, and centralized error/reporting policies

### `ApiResponse<T>`

`lib/services/api_response.dart` provides two explicit states:
- `ApiResponse.success(data)`
- `ApiResponse.failure(error)`

This keeps UI logic simple (`isSuccess`, `data`, `error`) and avoids `try/catch` in presentation code.

## Environment Configuration

The app uses two files:
- `.env` for development
- `.env.prod` for production

Required variables:
- `API_BASE_URL`
- `APP_ENV`

Local examples:

```env
# Android emulator
API_BASE_URL=http://10.0.2.2:8080
APP_ENV=dev
```

```env
# iOS simulator
API_BASE_URL=http://localhost:8080
APP_ENV=dev
```

Production example:

```env
API_BASE_URL=https://api.overdrive.com
APP_ENV=prod
```

`ENV_FILE` override:

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Android Networking Setup

`android/app/src/main/AndroidManifest.xml` includes:
- `android.permission.INTERNET`
- `android:usesCleartextTraffic="true"` for local HTTP development

## Commands

Install dependencies:

```bash
flutter pub get
```

Run in development:

```bash
flutter run
```

Run with production environment:

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

Static analysis:

```bash
flutter analyze
```

Format source:

```bash
dart format lib/
```

## Linting and Style

- Lint rules are configured in `analysis_options.yaml`.
- Formatting and indentation are configured in `.editorconfig`.
- Dart indentation in this project is set to 4 spaces.

## Current Gaps

- `core/constants/app_constants.dart` is a placeholder.
- `core/theme/app_theme.dart` is a placeholder.
- `core/utils/logger.dart` is a placeholder.
- `shared/widgets/app_scaffold.dart` is a placeholder.
- `test/widget_test.dart` is still the default Flutter counter test and does not match current UI.
