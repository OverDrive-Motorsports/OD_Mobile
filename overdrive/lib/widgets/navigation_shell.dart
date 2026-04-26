/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## navigation_shell.dart - Bottom navigation shell with tab bar.
 ##
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

/// Bottom navigation item definition
class NavItem {
  final String label;
  final IconData icon;
  final String route;

  NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Navigation shell with bottom tab bar
class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    required this.navigationShell,
    super.key,
  });

  // Define navigation items in order matching the routes
  static final List<NavItem> navItems = [
    NavItem(
      label: 'Home',
      icon: Icons.home_rounded,
      route: '/',
    ),
    NavItem(
      label: 'Search',
      icon: Icons.search_rounded,
      route: '/search',
    ),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_month_rounded,
      route: '/calendar',
    ),
    NavItem(
      label: 'Championship',
      icon: Icons.sports_motorsports_rounded,
      route: '/championship',
    ),
    NavItem(
      label: 'TV',
      icon: Icons.tv_rounded,
      route: '/tv',
    ),
    NavItem(
      label: 'Telemetry',
      icon: Icons.analytics_rounded,
      route: '/telemetry',
    ),
  ];

  void _onTabChanged(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabChanged,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withAlpha(51), // ~20% opacity
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(
          navItems.length,
          (index) => NavigationDestination(
            icon: Icon(navItems[index].icon),
            selectedIcon: Icon(navItems[index].icon),
            label: navItems[index].label,
          ),
        ),
      ),
    );
  }
}
