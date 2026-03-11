/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_navigation.dart - Glass bottom navigation bar.
 ##
 */

import 'dart:ui';
import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.10), width: 0.5),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex.clamp(0, 1).toInt(),
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag_outlined),
                selectedIcon: Icon(Icons.flag_rounded),
                label: 'F1',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
