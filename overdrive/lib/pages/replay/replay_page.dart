/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_page.dart - Temporary replay library screen.
 ##
 */

import 'package:flutter/material.dart';

import '../shared/placeholder_page.dart';

class ReplayPage extends StatelessWidget {
  const ReplayPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(title: title);
  }
}
