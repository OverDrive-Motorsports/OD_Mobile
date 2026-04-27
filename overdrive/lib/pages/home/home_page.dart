/*
##
## OverDrive 2026
## All Technical rights reserved
##
## home_page.dart - Home screen with championship standings only.
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
      body: Stack(
        children: <Widget>[
          ColoredBox(color: AppColors.black, child: SizedBox.expand()),
          _HomeChampionshipContent(),
          MenuOverlay(),
        ],
      ),
    );
  }
}

class _HomeChampionshipContent extends StatelessWidget {
  const _HomeChampionshipContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
