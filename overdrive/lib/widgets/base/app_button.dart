/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_button.dart - Reusable button component in primary, secondary, and danger variants.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ── Glass theme — "Moyen — gris" ─────────────────────────────────────────

const _kBorderColor = Color(0x28888888);
const _kBorderColorPressed = Color(0x40888888);
const _kFillColor = Color(0x12888888);

final _kButtonTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.14,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.04,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kButtonThemePressed = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.20,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.12,
  vibrancyIntensity: 0.06,
  edgeLightColor: _kBorderColorPressed,
  edgeShadowColor: _kBorderColorPressed,
);

// ── AppButton ─────────────────────────────────────────────────────────────

/// Shared liquid-glass button for labeled or icon-only actions (pass [icon] without [label] for the compact variant).
class AppButton extends StatefulWidget {
  const AppButton({
    this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  }) : assert(
         label != null || icon != null,
         'Provide a label, an icon, or both.',
       );

  final String? label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _brightness;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;
  bool get _isIconOnly => widget.label == null;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    // Brightness goes from 0 (normal) → -0.06 (slightly dimmed) on press.
    _brightness = Tween<double>(begin: 0.0, end: -0.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      opacity: _isDisabled ? 0.38 : 1.0,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _isDisabled ? null : widget.onPressed,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_brightnessMatrix(_brightness.value)),
                  child: child,
                ),
              );
            },
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 90),
                child: CupertinoLiquidGlass(
                  key: ValueKey(_ctrl.value > 0.5),
                  theme: _ctrl.value > 0.5 ? _kButtonThemePressed : _kButtonTheme,
                  borderRadius: BorderRadius.circular(999),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: ColoredBox(
                      color: _kFillColor,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 44,
                          minWidth: _isIconOnly ? 44 : 0,
                        ),
                        child: Padding(
                          padding: _isIconOnly
                              ? const EdgeInsets.all(10)
                              : const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                          child: _isIconOnly
                              ? _buildIconContent()
                              : _buildLabelContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContent() {
    if (widget.isLoading) {
      return const CupertinoActivityIndicator(
        radius: 9,
        color: AppColors.white,
      );
    }
    return Icon(widget.icon, size: 20, color: AppColors.white);
  }

  Widget _buildLabelContent() {
    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const CupertinoActivityIndicator(radius: 9, color: AppColors.white),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: AppColors.white),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyBold(color: AppColors.white).copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

/// Returns a 5×4 color matrix that shifts brightness by [delta] (−1…+1).
List<double> _brightnessMatrix(double delta) {
  final v = 1.0 + delta;
  return [
    v, 0, 0, 0, 0,
    0, v, 0, 0, 0,
    0, 0, v, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
