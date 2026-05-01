/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_bar.dart - Reusable presentational search bar widget.
 ##
 */

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'glass_pill.dart';

/// A typed configuration object for the search bar.
class SearchBarProps {
  const SearchBarProps({
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

/// A presentational search bar with an external controller and callbacks.
class SearchBar extends StatefulWidget {
  const SearchBar({required this.props, super.key});

  final SearchBarProps props;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

/// The state that manages focus and the clear action.
class _SearchBarState extends State<SearchBar> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.props.focusNode ?? _ownedFocusNode!;

  bool get _hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
  }

  @override
  void didUpdateWidget(covariant SearchBar oldWidget) {
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
    if (mounted) {
      setState(() {});
    }
  }

  void _handleClear() {
    if (!widget.props.enabled) {
      return;
    }

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

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.props.controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        final showClearAction = isEnabled && (_hasFocus || hasText);

        return Row(
          children: [
            Expanded(
              child: GlassPill(
                highlighted: isEnabled && _hasFocus,
                disabled: !isEnabled,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.props.controller,
                        focusNode: _focusNode,
                        enabled: isEnabled,
                        autofocus: widget.props.autofocus,
                        cursorColor: AppColors.accent,
                        textInputAction: widget.props.textInputAction,
                        style: AppTextStyles.bodyBold().copyWith(
                          fontSize: 14,
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: showClearAction
                  ? Padding(
                      key: const ValueKey('search-clear-action'),
                      padding: const EdgeInsets.only(left: 12),
                      child: GestureDetector(
                        onTap: _handleClear,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('search-clear-hidden')),
            ),
          ],
        );
      },
    );
  }
}
