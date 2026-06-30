/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_bar.dart - Themed search input field with focus-aware styling and a clear button.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ── Glass themes ──────────────────────────────────────────────────────────

const _kBorderColor = Color(0x26FFFFFF);

final _kSearchTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.12,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kCancelBtnTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.12,
  blurSigma: 20.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

// ── AppSearchBarProps ─────────────────────────────────────────────────────

/// A typed configuration object for the search bar.
class AppSearchBarProps {
  const AppSearchBarProps({
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.placeholder = 'Search',
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final String placeholder;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
}

// ── AppSearchBar ──────────────────────────────────────────────────────────

// Liquid-glass search field that shows a cancel button while focused or when text is present.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({required this.props, super.key});

  final AppSearchBarProps props;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.props.focusNode ?? _ownedFocusNode!;
  bool get _hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.focusNode != widget.props.focusNode) {
      _detachFocusNode(oldWidget.props.focusNode ?? _ownedFocusNode);
      if (oldWidget.props.focusNode == null) {
        _ownedFocusNode?.dispose();
        _ownedFocusNode = null;
      }
      _attachFocusNode();
    }
  }

  @override
  void dispose() {
    _detachFocusNode(_focusNode);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _attachFocusNode() {
    _ownedFocusNode ??= widget.props.focusNode == null ? FocusNode() : null;
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode(FocusNode? focusNode) {
    focusNode?.removeListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  void _handleClear() {
    if (!widget.props.enabled) return;
    if (widget.props.controller.text.isNotEmpty) {
      widget.props.controller.clear();
    }
    widget.props.onClear();
    widget.props.onSearch('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.props.enabled;

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.props.controller,
        builder: (context, value, _) {
          final hasText = value.text.isNotEmpty;
          final showCancel = isEnabled && (_hasFocus || hasText);

          return Row(
            children: [
              // ── Glass search field ──────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    CupertinoLiquidGlass(
                      theme: _kSearchTheme,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: isEnabled
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: TextField(
                                controller: widget.props.controller,
                                focusNode: _focusNode,
                                enabled: isEnabled,
                                autofocus: widget.props.autofocus,
                                cursorColor: AppColors.gold,
                                textInputAction: widget.props.textInputAction,
                                style: AppTextStyles.bodyBold().copyWith(
                                  fontSize: 15,
                                  color: isEnabled
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: widget.props.placeholder,
                                  hintStyle: AppTextStyles.body().copyWith(
                                    color: isEnabled
                                        ? AppColors.textSecondary
                                        : AppColors.textMuted,
                                  ),
                                ),
                                onChanged: widget.props.onSearch,
                                onSubmitted: widget.props.onSearch,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Focus border overlay — never recreates the TextField.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _hasFocus
                                  ? AppColors.white.withValues(alpha: 0.22)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cancel button — simple show/hide ────────────────────────
              if (showCancel) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleClear,
                  child: CupertinoLiquidGlass(
                    theme: _kCancelBtnTheme,
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 46,
                      height: 46,
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
