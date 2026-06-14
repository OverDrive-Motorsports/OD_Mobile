/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## navigation_shell.dart - Navigation shell with menu overlay.
 ##
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'menu_overlay.dart';

const _routesWithoutMenu = {'/tv', '/telemetry'};

/// Navigation shell wrapping pages with the floating menu overlay
class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final showMenu = !_routesWithoutMenu.contains(currentPath);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          if (showMenu) const MenuOverlay(),
        ],
      ),
    );
  }
}
