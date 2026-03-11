/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_scaffold.dart - Root scaffold with page stack.
 ##
 */

import 'package:flutter/material.dart';
import '../../pages/home/home_page.dart';
import '../../pages/f1/f1_page.dart';
import 'app_navigation_controller.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    F1Page(),
  ];

  int _coerceIndex(int index) => index.clamp(0, _pages.length - 1).toInt();

  void _syncNavigationIndex() {
    final nextIndex = _coerceIndex(appNavigationIndex.value);
    if (!mounted || _selectedIndex == nextIndex) return;
    setState(() => _selectedIndex = nextIndex);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _coerceIndex(appNavigationIndex.value);
    appNavigationIndex.addListener(_syncNavigationIndex);
  }

  @override
  void dispose() {
    appNavigationIndex.removeListener(_syncNavigationIndex);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _coerceIndex(_selectedIndex),
        children: _pages,
      ),
    );
  }
}
