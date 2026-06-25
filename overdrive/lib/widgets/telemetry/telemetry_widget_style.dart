import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// Shared card decoration for all telemetry widgets.
// Pass accentColor to override the default gold border/glow with a state-driven color
// (e.g., EngineTemps uses red/gold/green to reflect the current engine mode).
BoxDecoration telemetryDecoration({Color? accentColor}) {
  final color = accentColor ?? AppColors.gold;

  return BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.12),
        blurRadius: 14,
        spreadRadius: 2,
      ),
    ],
  );
}
