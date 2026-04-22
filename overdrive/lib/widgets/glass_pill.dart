import 'package:flutter/material.dart';

class GlassPill extends StatelessWidget {
  const GlassPill({
    required this.child,
    this.highlighted = false,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    super.key,
  });

  final Widget child;
  final bool highlighted;
  final bool disabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = disabled
        ? Colors.white.withValues(alpha: 0.08)
        : highlighted
        ? Colors.white.withValues(alpha: 0.24)
        : Colors.white.withValues(alpha: 0.16);
    final borderColor = disabled
        ? Colors.white.withValues(alpha: 0.16)
        : highlighted
        ? Colors.white.withValues(alpha: 0.36)
        : Colors.white.withValues(alpha: 0.28);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
