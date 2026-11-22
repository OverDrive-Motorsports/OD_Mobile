/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## placeholder_page.dart - Generic placeholder screen displaying a centered title, used by unfinished routes.
 ##
 */

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable shell for pages that only need a centered title for now.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(child: Text(title, style: AppTextStyles.display())),
    );
  }
}
