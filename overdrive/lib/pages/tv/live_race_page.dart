/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## live_race_page.dart - Full-screen live race TV page embedding TvLivePlayer with stream selection controls.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/base/app_button.dart';

// Full-screen live race page — embeds the TV player and stream controls once wired.
class LiveRacePage extends StatelessWidget {
  const LiveRacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: AppButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Live Race',
          style: AppTextStyles.display(color: AppColors.textPrimary),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Live Race', style: AppTextStyles.display()),
            const SizedBox(height: 8),
            Text(
              'Live race screen content coming soon',
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
