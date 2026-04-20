/*
 ##
 ## OverDrive 2026 — home_page.dart
 ## Minimal home page with the application menu overlay.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/menu_overlay.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: Stack(children: [MenuOverlay()]),
      ),
    );
  }
}
