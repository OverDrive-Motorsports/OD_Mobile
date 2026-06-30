# OverDrive 2026 — External Dependencies

All packages declared in `pubspec.yaml`. Listed alphabetically within their sections.

---

## Runtime Dependencies

### `cupertino_icons: ^1.0.8`

**Purpose**: Provides the complete set of Apple SF Symbols–style icons as a Flutter
icon font, accessible through the `CupertinoIcons` class.

**Usage in this project**: Used throughout all pages and widgets for iconography that
matches the iOS visual language the app targets (e.g. `CupertinoIcons.speedometer`,
`CupertinoIcons.bolt`, navigation arrows, close buttons).

**Configuration**: No additional setup required — included automatically when
`uses-material-design: true` is set in `pubspec.yaml`.

---

### `cupertino_liquid_glass: ^0.6.0`

**Purpose**: Flutter implementation of Apple's liquid glass effect introduced in iOS 26.
Renders real-time blurred, tinted, specular glass surfaces backed by a
`BackdropFilter`.

**Usage in this project**:
- `TelemetryCard` (`widgets/telemetry/telemetry_widget_style.dart`) wraps every
  telemetry grid widget in a `CupertinoLiquidGlass` with the "Moyen-gris" preset
  (`tintOpacity: 0.14`, `blurSigma: 22.0`).
- `AppSwitch` (`widgets/base/app_switch.dart`) uses a custom dark liquid-glass
  theme for the toggle track.
- `EventCalendar` (`widgets/calendar/event_calendar.dart`) applies three distinct
  glass presets for past, upcoming, and ongoing race cards.
- Championship widgets, modals, and the navigation shell all use
  `LiquidGlassThemeData.dark()` variants for surface cards.

**Configuration**: Requires content behind the glass (a real backdrop). Works best
with `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` so content
extends under the status bar, which is set in `main.dart`.

---

### `dio: ^5.9.2`

**Purpose**: Feature-rich HTTP client for Dart supporting interceptors, request
cancellation, timeouts, and typed response handling.

**Usage in this project**: Used exclusively in `HealthService`
(`services/health_service.dart`) to make `GET /health` requests to the backend API.
The service reads the base URL from `.env` via `flutter_dotenv`, with automatic
fallbacks for Android emulator (`10.0.2.2`) and iOS simulator (`localhost`).

**Configuration**: Timeout values — `connectTimeout: 15 s`, `receiveTimeout: 60 s` —
are set in `HealthService`'s constructor. No global interceptor is registered.

---

### `flutter_dotenv: ^5.1.0`

**Purpose**: Loads key-value pairs from a `.env` file into `dotenv.env` at runtime,
providing a safe way to inject environment-specific configuration without hardcoding
values in source code.

**Usage in this project**: Loaded in `main()` before `runApp`. The `API_BASE_URL`
key is read by `HealthService` to determine the backend endpoint. The `.env` file
is declared as a Flutter asset in `pubspec.yaml` so it is bundled with the app.

**Configuration**:
- The `.env` file must be in the project root and declared under `assets:` in
  `pubspec.yaml`.
- An alternate env file path can be injected at build time via
  `--dart-define=ENV_FILE=path/to/file.env` (used in CI or test environments).
- If the file is missing, `main()` silently continues — the app falls back to
  the default API base URL.

---

### `go_router: ^14.6.0`

**Purpose**: Declarative URL-based routing for Flutter, supporting deep links,
redirects, path parameters, and nested navigation with `StatefulShellRoute`.

**Usage in this project**:
- `createRouter(AuthService)` in `config/app_router.dart` builds the `GoRouter`
  instance with all routes and an auth redirect guard.
- `StatefulShellRoute.indexedStack` powers the five-branch bottom navigation
  (Home, Championship, Calendar, Search, Profile) without losing scroll state
  when switching tabs.
- `NavigationShell` (`widgets/navigation/navigation_shell.dart`) receives the
  `StatefulNavigationShell` and renders the custom bottom nav bar.
- Route path constants are centralised in `RoutePaths` (inside `app_router.dart`)
  and mirrored in `AppRoutes` (`core/navigation/app_routes.dart`) for legacy
  `MaterialApp.onGenerateRoute` use in widget tests.

**Configuration**: `GoRouter.refreshListenable` is wired to `AuthService` so that
any authentication state change automatically triggers the redirect guard.

---

### `google_fonts: ^6.2.1`

**Purpose**: Provides access to all Google Fonts directly in Flutter without manual
font asset management — fonts are fetched at runtime or bundled via a local cache.

**Usage in this project**: The Orbitron font family is used for display-level
headings (speed readings, large numerals, the OverDrive wordmark) via
`GoogleFonts.orbitron(...)` in `AppTextStyles.display()` (`core/theme/app_theme.dart`).
In widget tests, `GoogleFonts.config.allowRuntimeFetching = false` is set to prevent
network calls during test runs.

**Configuration**: No API key required. Runtime fetching is enabled by default;
set `GoogleFonts.config.allowRuntimeFetching = false` in non-production environments
where network access is undesirable.

---

### `provider: ^6.1.0`

**Purpose**: Lightweight state management and dependency injection for Flutter,
built on top of `InheritedWidget`. Provides `ChangeNotifierProvider`, `Consumer`,
`context.watch`, and `context.read`.

**Usage in this project**:
- `AuthService` is provided at the root via `ChangeNotifierProvider` in
  `OverDriveApp.build()` (`main.dart`), making the auth state available to
  `createRouter` through a `Consumer`.
- `TelemetrySimulator` is provided at the telemetry page root via
  `ChangeNotifierProvider`, scoped to `TelemetryPage`. Every telemetry widget
  subscribes via `context.watch<TelemetrySimulator>()` to rebuild on each 200 ms tick.

**Configuration**: No additional setup. `provider` works without code generation.

---

### `webview_flutter: ^4.13.1`

**Purpose**: Embeds a native web view (WKWebView on iOS, WebView on Android) inside
a Flutter widget, enabling display of web content and embedded video players.

**Sub-packages**:
- `webview_flutter_android: ^4.10.4` — Android WebView implementation
- `webview_flutter_wkwebview: ^3.23.1` — iOS/macOS WKWebView implementation

**Usage in this project**: `TvLivePlayer` (`widgets/tv/tv_live_player.dart`) embeds
a YouTube player via a `WebViewController` loading the stream's `videoUrl` as an
HTML string. A loading overlay is shown until `WebResourceLoadingRequest` completes.
The widget falls back to a styled unavailable card when `stream.videoUrl` is null.

**Configuration**:
- Android: `WebViewAndroidWidget()` is registered automatically by the plugin.
- iOS: Requires no additional `Info.plist` keys for YouTube embeds.
- JavaScript is enabled on the controller (`setJavaScriptMode(JavaScriptMode.unrestricted)`).

---

## Development Dependencies

### `flutter_lints: ^6.0.0`

**Purpose**: A curated set of lint rules recommended by the Flutter team, enforcing
idiomatic Dart style, avoiding common pitfalls, and keeping the codebase consistent.

**Usage in this project**: Activated via `analysis_options.yaml` at the project root.
Running `flutter analyze` applies all enabled rules. Individual rules can be suppressed
inline with `// ignore: rule_name` when a documented exception is needed.

**Configuration**: Rules are configured in `analysis_options.yaml`. The project
currently uses the default `flutter` rule set with no customizations.
