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
import 'app_scaffold.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AppScaffold();
      },
    ),
  ],
);
