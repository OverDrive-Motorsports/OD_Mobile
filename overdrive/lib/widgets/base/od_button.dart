/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_button.dart - Shared OverDrive pill button with subtle press feedback.
##
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A shared OverDrive button used for regular actions.
class OdButton extends StatefulWidget {
  const OdButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool fullWidth;

  @override
  State<OdButton> createState() => _OdButtonState();
}

/// The state that handles the pressed visual effect.
class _OdButtonState extends State<OdButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final style = _ButtonStyle.button();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      opacity: _isDisabled ? 0.45 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _isPressed && !_isDisabled ? 0.985 : 1,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isDisabled ? null : widget.onPressed,
                onHighlightChanged: (isHighlighted) {
                  if (_isDisabled) {
                    return;
                  }
                  setState(() => _isPressed = isHighlighted);
                },
                borderRadius: BorderRadius.circular(999),
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isPressed
                        ? style.backgroundColor.withValues(alpha: 0.10)
                        : style.backgroundColor,
                    borderRadius: BorderRadius.circular(999),
                    border: style.borderColor == null
                        ? null
                        : Border.all(
                            color: _isPressed
                                ? style.borderColor!.withValues(alpha: 0.28)
                                : style.borderColor!,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: widget.fullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        CupertinoActivityIndicator(
                          radius: 9,
                          color: style.foregroundColor,
                        ),
                        const SizedBox(width: 10),
                      ] else if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          size: 18,
                          color: style.foregroundColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyBold(
                          color: style.foregroundColor,
                        ).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small style object used internally by the button.
class _ButtonStyle {
  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  factory _ButtonStyle.button() {
    return _ButtonStyle(
      backgroundColor: AppColors.white.withValues(alpha: 0.05),
      foregroundColor: AppColors.white,
      borderColor: AppColors.white.withValues(alpha: 0.18),
    );
  }
}
