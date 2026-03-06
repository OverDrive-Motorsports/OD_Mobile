/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_router.dart - Application router configuration.
 ##
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final GoRouter appRouter = GoRouter(
    routes: [
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
            },
        ),
        GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) {
                return const SettingsScreen();
            },
        ),
    ],
);
