/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## placeholder_page.dart - Reusable placeholder screen with centered page title.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/menu_overlay.dart';

/// Reusable shell for pages that only need a centered title for now.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 22),
                ),
              ),
            ),
          ),
          const MenuOverlay(),
        ],
      ),
    );
  }
}
