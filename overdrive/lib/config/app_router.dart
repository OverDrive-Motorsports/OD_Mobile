/*
##
## OverDrive 2026
## All Technical rights reserved
##
## AppRouter - GoRouter configuration with all routes and navigation logic.
##
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/calendar/calendar_page.dart';
import '../pages/championship/championship_page.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/signup/signup_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/search/search_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/telemetry/telemetry_page.dart';
import '../pages/tv/live_race_page.dart';
import '../pages/tv/tv_page.dart';
import '../services/auth/auth_service.dart';
import '../services/championship/championship_mock_data.dart';
import '../widgets/navigation/navigation_shell.dart';

// ── Route paths ───────────────────────────────────────────────────────────

/// Typed path constants — single source of truth for navigation targets.
abstract final class RoutePaths {
  static const String login = '/login';
  static const String home = '/';
  static const String championship = '/championship';
  static const String calendar = '/calendar';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String tv = '/tv';
  static const String liveRace = '/tv/live-race';
  static const String telemetry = '/telemetry';
  static const String settings = '/settings';
}

// ── Router factory ────────────────────────────────────────────────────────

/// Creates the app's [GoRouter] with auth redirects: unauthenticated → [RoutePaths.login]; authenticated at login → [RoutePaths.home].
GoRouter createRouter(AuthService authService) {
  return GoRouter(
    refreshListenable: authService,
    initialLocation: RoutePaths.home,
    redirect: (_, state) {
      final authenticated = authService.isAuthenticated;

      final publicRoutes = [RoutePaths.login, '/signup'];

      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!authenticated && !isPublicRoute) {
        return RoutePaths.login;
      }

      if (authenticated && isPublicRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    routes: [
      // ── Login (outside nav shell) ─────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (_, _) => const SignupPage(),
      ),
      // ── Main shell — five bottom-nav branches ─────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => NavigationShell(navigationShell: shell),
        branches: [
          // 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: 'home',
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          // 1 — Championship
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.championship,
                name: 'championship',
                builder: (_, _) =>
                    ChampionshipPage(data: championshipFormula1Mock),
              ),
            ],
          ),
          // 2 — Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.calendar,
                name: 'calendar',
                builder: (_, _) => const CalendarPage(),
              ),
            ],
          ),
          // 3 — Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.search,
                name: 'search',
                builder: (_, _) => const SearchPage(),
              ),
            ],
          ),
          // 4 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: 'profile',
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ── Standalone routes (no nav shell) ─────────────────────────────────
      GoRoute(
        path: RoutePaths.tv,
        name: 'tv',
        builder: (_, _) => const TvPage(),
        routes: [
          GoRoute(
            path: 'live-race',
            name: 'liveRace',
            builder: (_, _) => const LiveRacePage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.telemetry,
        name: 'telemetry',
        builder: (_, _) => const TelemetryPage(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        builder: (_, _) => const SettingsPage(),
      ),
    ],
  );
}
