/*
##
## OverDrive 2026
## All Technical rights reserved
##
## glass_pill.dart - Reusable translucent pill surface for compact controls.
##
*/

import 'package:flutter/material.dart';

/// A small translucent pill container used by compact controls.
class GlassPill extends StatelessWidget {
  const GlassPill({
    required this.child,
    this.highlighted = false,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final bool highlighted;
  final bool disabled;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor =
        backgroundColor ??
        (disabled
            ? Colors.white.withValues(alpha: 0.08)
            : highlighted
            ? Colors.white.withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.16));
    final resolvedBorderColor =
        borderColor ??
        (disabled
            ? Colors.white.withValues(alpha: 0.16)
            : highlighted
            ? Colors.white.withValues(alpha: 0.36)
            : Colors.white.withValues(alpha: 0.28));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(22),
        border: Border.all(color: resolvedBorderColor),
      ),
      child: child,
    );
  }
}
