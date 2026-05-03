/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_page.dart - Championship screen placeholder.
 ##
 */

import 'package:flutter/material.dart';

import '../shared/placeholder_page.dart';

const String _championshipPageTitle = 'Championship';

/// Temporary championship screen backed by the shared placeholder shell.
class ChampionshipPage extends StatelessWidget {
  const ChampionshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: _championshipPageTitle);
  }
}
