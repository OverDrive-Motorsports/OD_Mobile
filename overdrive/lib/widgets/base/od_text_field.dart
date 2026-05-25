/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_text_field.dart - Shared rounded input field with optional icon and inline error state.
##
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'od_error_message.dart';

/// A shared rounded text field with optional icon and error message.
class OdTextField extends StatefulWidget {
  const OdTextField({
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
  State<OdTextField> createState() => _OdTextFieldState();
}

/// The state that manages focus, clearing and optional internal control.
class _OdTextFieldState extends State<OdTextField> {
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
  void didUpdateWidget(covariant OdTextField oldWidget) {
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
        ? AppColors.white.withValues(alpha: 0.18)
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.inputSurface,
            borderRadius: BorderRadius.circular(_cornerRadius),
            border: Border.all(color: borderColor),
          ),
          child: CupertinoTextField(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(_cornerRadius)),
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
        ),
        if (_hasError) ...[
          const SizedBox(height: 8),
          OdErrorMessage(message: widget.errorMessage!),
        ],
      ],
    );
  }
}
