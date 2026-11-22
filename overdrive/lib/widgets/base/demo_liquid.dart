/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## demo_liquid.dart - Demo widget showcasing CupertinoLiquidGlass presets for design review.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';

/// An empty liquid glass surface with configurable intensity and tint.
class DemoLiquid extends StatelessWidget {
  const DemoLiquid({
    this.tintOpacity = 0.14,
    this.blurSigma = 22.0,
    this.noiseOpacity = 0.0,
    this.specularOpacity = 0.10,
    this.vibrancyIntensity = 0.04,
    this.edgeColor = const Color(0x30FFFFFF),
    this.fillColor,
    this.borderRadius = 20.0,
    this.height = 72.0,
    this.width = double.infinity,
    super.key,
  });

  final double tintOpacity;
  final double blurSigma;
  final double noiseOpacity;
  final double specularOpacity;
  final double vibrancyIntensity;
  final Color edgeColor;

  /// Optional solid fill layered inside the glass (white or grey tint).
  final Color? fillColor;

  final double borderRadius;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassThemeData.dark().copyWith(
      tintOpacity: tintOpacity,
      blurSigma: blurSigma,
      noiseOpacity: noiseOpacity,
      specularOpacity: specularOpacity,
      vibrancyIntensity: vibrancyIntensity,
      edgeLightColor: edgeColor,
      edgeShadowColor: edgeColor,
    );

    final radius = BorderRadius.circular(borderRadius);

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: theme,
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: width,
            height: height,
            child: fillColor != null
                ? ColoredBox(color: fillColor!)
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
