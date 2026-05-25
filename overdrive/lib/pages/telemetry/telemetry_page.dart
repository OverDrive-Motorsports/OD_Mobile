/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_page.dart - Telemetry screen placeholder.
 ##
 */

import 'package:flutter/material.dart';
import '../shared/placeholder_page.dart';

const String _telemetryPageTitle = 'Telemetry';

/// Temporary telemetry screen backed by the shared placeholder shell.
class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: _telemetryPageTitle);
  }
}
