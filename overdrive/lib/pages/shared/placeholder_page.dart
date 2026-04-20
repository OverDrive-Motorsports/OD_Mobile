import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/menu_overlay.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: Stack(
          children: [
            SafeArea(
              child: Center(child: Text(title, style: AppTextStyles.display())),
            ),
            const MenuOverlay(),
          ],
        ),
      ),
    );
  }
}
