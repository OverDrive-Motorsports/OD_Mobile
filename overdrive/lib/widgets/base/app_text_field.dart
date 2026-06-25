/*
##
## OverDrive 2026
## All Technical rights reserved
##
## app_text_field.dart - Shared rounded input field with optional icon and inline error state.
##
*/

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'error_message.dart';

// ---------------------------------------------------------------------------
// Glass theme
// ---------------------------------------------------------------------------

const _kFieldBorderColor = Color(0x22FFFFFF);

final _kFieldTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.12,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.03,
  edgeLightColor: _kFieldBorderColor,
  edgeShadowColor: _kFieldBorderColor,
);

/// A shared rounded text field with optional icon and error message.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorMessage,
    this.leadingIcon,
    this.onClear,
    this.onChanged,
    super.key,
  });

  final String placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorMessage;
  final IconData? leadingIcon;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  static const double _cornerRadius = 20;

  TextEditingController? _ownedController;
  late final FocusNode _focusNode;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  bool get _hasError =>
      widget.errorMessage != null && widget.errorMessage!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ownedController = widget.controller == null
        ? TextEditingController()
        : null;
    _focusNode = FocusNode()..addListener(_handleVisualStateChange);
    _controller.addListener(_handleVisualStateChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleVisualStateChange);
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
      }
      _ownedController = widget.controller == null
          ? TextEditingController()
          : null;
      _controller.addListener(_handleVisualStateChange);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleVisualStateChange)
      ..dispose();
    _controller.removeListener(_handleVisualStateChange);
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleVisualStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    final borderColor = _hasError
        ? AppColors.red
        : _focusNode.hasFocus
        ? AppColors.white.withValues(alpha: 0.22)
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.dark),
          child: CupertinoLiquidGlass(
            theme: _kFieldTheme,
            borderRadius: BorderRadius.circular(_cornerRadius),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cornerRadius),
              child: Stack(
                children: [
                  CupertinoTextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    cursorColor: AppColors.gold,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    placeholder: widget.placeholder,
                    placeholderStyle: AppTextStyles.body(
                      color: AppColors.white.withValues(alpha: 0.38),
                    ).copyWith(fontSize: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(_cornerRadius),
                      ),
                    ),
                    prefix: widget.leadingIcon == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Icon(
                              widget.leadingIcon,
                              size: 18,
                              color: AppColors.white.withValues(alpha: 0.60),
                            ),
                          ),
                    suffix: widget.onClear != null && hasText
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: _handleClear,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          )
                        : null,
                    onChanged: widget.onChanged,
                  ),

                  // ── Focus / error border overlay ─────────────────────────
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_cornerRadius),
                          border: Border.all(
                            color: borderColor,
                            width: _hasError ? 1.4 : 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 8),
          ErrorMessage(message: widget.errorMessage!),
        ],
      ],
    );
  }
}
