/*
 ##
 ## OverDrive 2026 — app_shell.dart
 ## Shell sans nav bar — navigation via slide menu uniquement.
 ##
 */

import 'package:flutter/material.dart';
import '../../pages/home/home_page.dart';
import '../../pages/f1/f1_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> implements _AppShellNavigable {
  int _index = 0;

  int _coerceIndex(int index) => index.clamp(0, _pages.length - 1).toInt();

  @override
  void setIndex(int i) {
    setState(() => _index = _coerceIndex(i));
  }

  static const List<Widget> _pages = [
    HomePage(),
    F1Page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _coerceIndex(_index),
        children: _pages,
      ),
    );
  }
}

abstract class _AppShellNavigable {
  void setIndex(int i);
}
