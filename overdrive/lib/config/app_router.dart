/**
##
## OverDrive 2026
## All Technical rights reserved
##
## app_router.dart - GoRouter configuration with all routes and navigation logic.
##
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/calendar/calendar_page.dart';
import '../pages/championship/championship_page.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/search/search_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/telemetry/telemetry_page.dart';
import '../pages/tv/live_race_page.dart';
import '../pages/tv/tv_page.dart';
import '../services/auth_service.dart';
import '../widgets/navigation_shell.dart';

/// Route paths
class RoutePaths {
static const String login = '/login';
static const String home = '/';
static const String search = '/search';
static const String calendar = '/calendar';
static const String championship = '/championship';
static const String tv = '/tv';
static const String telemetry = '/telemetry';
static const String liveRace = '/tv/live-race';
static const String profile = '/profile';
static const String settings = '/settings';
}

/// Creates the GoRouter for the app with authentication support
GoRouter createRouter(AuthService authService) {
return GoRouter(
    refreshListenable: authService,
    initialLocation: RoutePaths.home,
    redirect: (context, state) {
    final isAuthenticated = authService.isAuthenticated;
    final isLoggingIn = state.matchedLocation == RoutePaths.login;

    // If not authenticated and not already going to login, redirect to login
    if (!isAuthenticated && !isLoggingIn) {
        return RoutePaths.login;
    }

    // If authenticated and trying to access login, redirect to home
    if (isAuthenticated && isLoggingIn) {
        return RoutePaths.home;
    }

    // No redirect needed
    return null;
    },
    routes: <RouteBase>[
    // Login route (not part of bottom navigation)
    GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
        },
    ),
    // Main navigation shell with bottom tab bar
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
        // Home branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.home,
                name: 'home',
                builder: (BuildContext context, GoRouterState state) {
                return const HomePage();
                },
            ),
            ],
        ),
        // Search branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.search,
                name: 'search',
                builder: (BuildContext context, GoRouterState state) {
                return const SearchPage();
                },
            ),
            ],
        ),
        // Calendar branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.calendar,
                name: 'calendar',
                builder: (BuildContext context, GoRouterState state) {
                return const CalendarPage();
                },
            ),
            ],
        ),
        // Championship branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.championship,
                name: 'championship',
                builder: (BuildContext context, GoRouterState state) {
                return const ChampionshipPage();
                },
            ),
            ],
        ),
        // TV branch with Live Race subroute
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.tv,
                name: 'tv',
                builder: (BuildContext context, GoRouterState state) {
                return const TvPage();
                },
                routes: <RouteBase>[
                GoRoute(
                    path: 'live-race',
                    name: 'liveRace',
                    builder: (BuildContext context, GoRouterState state) {
                    return const LiveRacePage();
                    },
                ),
                ],
            ),
            ],
        ),
        // Telemetry branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.telemetry,
                name: 'telemetry',
                builder: (BuildContext context, GoRouterState state) {
                return const TelemetryPage();
                },
            ),
            ],
        ),
        // Profile branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.profile,
                name: 'profile',
                builder: (BuildContext context, GoRouterState state) {
                return const ProfilePage();
                },
            ),
            ],
        ),
        // Settings branch
        StatefulShellBranch(
            routes: <RouteBase>[
            GoRoute(
                path: RoutePaths.settings,
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) {
                return const SettingsPage();
                },
            ),
            ],
        ),
        ],
    ),
    ],
    errorBuilder: (context, state) => Scaffold(
    body: Center(
        child: Text('Page not found: ${state.uri}'),
    ),
    ),
);
}
