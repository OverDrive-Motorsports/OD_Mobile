/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_page.dart - Replay route shell passing a championship-provided title to the shared placeholder page.
 ##
 */

import 'package:flutter/material.dart';

import '../shared/placeholder_page.dart';

/// Lightweight replay route that displays the injected replay section title.
class ReplayPage extends StatelessWidget {
  const ReplayPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(title: title);
  }
}
