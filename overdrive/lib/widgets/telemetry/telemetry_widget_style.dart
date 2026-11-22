/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [telemetry_widget_style.dart] - Shared visual primitives for telemetry widgets: liquid-glass card, layout mode helper, header, and progress bar.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';

// ── Legacy decoration helper — kept for non-glass fallback contexts ─────────

// Produces a bordered, shadowed box with a per-widget accent colour; superceded
// by TelemetryCard for most widgets but retained for reference or fallback use.
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

// ── "Moyen — gris" glass preset ───────────────────────────────────────────────

const _kMoyenGrisTheme = LiquidGlassThemeData(
  tintColor: Color(0xFF888888),
  tintOpacity: 0.14,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.04,
  edgeLightColor: Color(0x28888888),
  edgeShadowColor: Color(0x28888888),
  borderRadius: BorderRadius.all(Radius.circular(12)),
  innerShadowBlurRadius: 0.0,
);

const _kFill = Color(0x12888888);

/// Liquid-glass card wrapper used by all telemetry widgets.
class TelemetryCard extends StatelessWidget {
  const TelemetryCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kMoyenGrisTheme,
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: ColoredBox(color: _kFill, child: child),
        ),
      ),
    );
  }
}

// ── 2-mode layout logic ───────────────────────────────────────────────────────

enum TelemetryMode { small, large }

/// Returns [TelemetryMode.large] when the widget has enough space for a 3×3 cell.
/// Everything below that uses [TelemetryMode.small].
TelemetryMode telemetryMode(double w, double h) {
  if (w >= 155 && h >= 155) return TelemetryMode.large;
  return TelemetryMode.small;
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

/// Standard header row: label left, optional driver tag right.
class TelemetryHeader extends StatelessWidget {
  const TelemetryHeader({super.key, required this.label, this.driverId});
  final String label;
  final String? driverId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.label(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 10, letterSpacing: 0.6),
        ),
        const Spacer(),
        if (driverId != null)
          Text(
            driverId!,
            style: AppTextStyles.label(
              color: AppColors.gold,
            ).copyWith(fontSize: 10),
          ),
      ],
    );
  }
}

/// Animated progress bar with smooth tween.
class TelemetryBar extends StatelessWidget {
  const TelemetryBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 4.0,
    this.trackColor,
    this.radius,
  });
  final double fraction;
  final Color color;
  final double height;
  final Color? trackColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: fraction.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (_, f, _) => ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(color: trackColor ?? AppColors.surface),
              FractionallySizedBox(
                widthFactor: f,
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
