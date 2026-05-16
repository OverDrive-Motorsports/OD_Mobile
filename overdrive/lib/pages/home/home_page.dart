/*
##
## OverDrive 2026
## All Technical rights reserved
##
## home_page.dart - Empty home screen scaffold.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/menu_overlay.dart';

/// The home screen shell used as the current app entry point.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: _HomeBackdrop()),
          MenuOverlay(),
        ],
      ),
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.grayOpaque.withValues(alpha: 0.16),
            AppColors.black,
            AppColors.black,
          ],
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.grayOpaque.withValues(alpha: 0.12),
              Colors.transparent,
              AppColors.black.withValues(alpha: 0.92),
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
      ),
    );
  }
}
