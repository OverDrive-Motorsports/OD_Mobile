/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_modal.dart - Shared blurred bottom sheet helper with drag dismissal.
##
*/

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A helper used to show the shared OverDrive bottom sheet.
class OdModal {
  const OdModal._();

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool showHandle = true,
    bool isDismissible = true,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      _OdModalRoute<T>(
        title: title,
        child: child,
        showHandle: showHandle,
        isDismissible: isDismissible,
      ),
    );
  }
}

/// A custom popup route used by the shared modal.
class _OdModalRoute<T> extends PopupRoute<T> {
  _OdModalRoute({
    required this.title,
    required this.child,
    required this.showHandle,
    required this.isDismissible,
  });

  final String? title;
  final Widget child;
  final bool showHandle;
  final bool isDismissible;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 280);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible
                  ? () => Navigator.of(context).maybePop()
                  : null,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.60),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: _OdModalSheet(
                    title: title,
                    showHandle: showHandle,
                    isDismissible: isDismissible,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The visual bottom sheet shown by the modal route.
class _OdModalSheet extends StatefulWidget {
  const _OdModalSheet({
    required this.child,
    required this.showHandle,
    required this.isDismissible,
    this.title,
  });

  final String? title;
  final Widget child;
  final bool showHandle;
  final bool isDismissible;

  @override
  State<_OdModalSheet> createState() => _OdModalSheetState();
}

/// The state that manages drag dismissal and sheet offset.
class _OdModalSheetState extends State<_OdModalSheet> {
  static const double _baseBottomOffset = 18;
  static const double _topRadius = 28;

  double _dragOffset = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.isDismissible) {
      return;
    }

    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, 220);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.isDismissible) {
      return;
    }

    final shouldDismiss =
        _dragOffset > 120 ||
        details.primaryVelocity != null && details.primaryVelocity! > 900;
    if (shouldDismiss) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final bottomOffset = viewInsets > 0 ? 0.0 : _baseBottomOffset;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, bottomOffset + _dragOffset, 0),
        child: GestureDetector(
          onVerticalDragUpdate: widget.isDismissible ? _handleDragUpdate : null,
          onVerticalDragEnd: widget.isDismissible ? _handleDragEnd : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_topRadius),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.94),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(_topRadius),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showHandle) ...[
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.handle,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyBold().copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        Flexible(
                          fit: FlexFit.loose,
                          child: SingleChildScrollView(child: widget.child),
                        ),
                      ],
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
}
