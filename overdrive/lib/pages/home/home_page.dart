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
      body: Stack(children: <Widget>[SizedBox.expand(), MenuOverlay()]),
    );
  }
}
