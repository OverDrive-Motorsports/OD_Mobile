/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## f1_page.dart - Empty placeholder page.
 ##
 */

import 'package:flutter/material.dart';
import '../../widgets/top_left_menu_overlay.dart';

class F1Page extends StatelessWidget {
  const F1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(),
          TopLeftMenuOverlay(),
        ],
      ),
    );
  }
}
