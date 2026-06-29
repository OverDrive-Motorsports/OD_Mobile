/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_modal.dart - Bottom-sheet modal wrapper with title, body, and optional action buttons.
 ##
 */

import 'dart:ui';

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ── Glass theme ───────────────────────────────────────────────────────────

const _kTopRadius = 28.0;
const _kEdgeColor = Color(0x60DDDDDD);
const _kFillColor = Color(0x14DDDDDD);

final _kSheetTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.50,
  blurSigma: 44.0,
  noiseOpacity: 0.02,
  specularOpacity: 0.20,
  vibrancyIntensity: 0.10,
  edgeLightColor: _kEdgeColor,
  edgeShadowColor: _kEdgeColor,
);

// ── AppModal ──────────────────────────────────────────────────────────────

/// Shows the shared OverDrive liquid-glass bottom sheet.
class AppModal {
  const AppModal._();

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool showHandle = true,
    bool isDismissible = true,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      _AppModalRoute<T>(
        title: title,
        child: child,
        showHandle: showHandle,
        isDismissible: isDismissible,
      ),
    );
  }
}

// ── Route ─────────────────────────────────────────────────────────────────

// Custom PopupRoute that composes the blurred backdrop and the animated sheet.
class _AppModalRoute<T> extends PopupRoute<T> {
  _AppModalRoute({
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
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(curve);

    final scaleAnim = Tween<double>(begin: 0.97, end: 1.0).animate(curve);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // ── Backdrop ──────────────────────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible
                  ? () => Navigator.of(context).maybePop()
                  : null,
              child: FadeTransition(
                opacity: curve,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const ColoredBox(color: Color(0x55000000)),
                ),
              ),
            ),
          ),

          // ── Sheet — extends past safe area to screen edge ─────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: slideAnim,
              child: ScaleTransition(
                scale: scaleAnim,
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: curve,
                  child: _AppModalSheet(
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

// ── Sheet ─────────────────────────────────────────────────────────────────

// Liquid-glass bottom sheet with drag-to-dismiss gesture and optional handle/title.
class _AppModalSheet extends StatefulWidget {
  const _AppModalSheet({
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
  State<_AppModalSheet> createState() => _AppModalSheetState();
}

class _AppModalSheetState extends State<_AppModalSheet> {
  double _dragOffset = 0;

  // Accumulates the downward drag offset, clamped to 240 logical pixels.
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.isDismissible) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, 240);
    });
  }

  // Dismisses when drag exceeds 110 px or fling velocity exceeds 800 px/s; otherwise snaps back.
  void _handleDragEnd(DragEndDetails details) {
    if (!widget.isDismissible) return;

    final shouldDismiss =
        _dragOffset > 110 ||
        (details.primaryVelocity != null &&
            details.primaryVelocity! > 800);
    if (shouldDismiss) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: GestureDetector(
            onVerticalDragUpdate:
                widget.isDismissible ? _handleDragUpdate : null,
            onVerticalDragEnd:
                widget.isDismissible ? _handleDragEnd : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 680,
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoLiquidGlass(
                  theme: _kSheetTheme,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_kTopRadius),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(_kTopRadius),
                    ),
                    child: ColoredBox(
                      color: _kFillColor,
                      child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + safeBottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Handle ─────────────────────────────────────
                          if (widget.showHandle) ...[
                            Center(
                              child: Container(
                                width: 38,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.white
                                      .withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── Title ──────────────────────────────────────
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyBold().copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 4),
                              child: Container(
                                height: 0.5,
                                color: AppColors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // ── Content ────────────────────────────────────
                          Flexible(
                            fit: FlexFit.loose,
                            child: SingleChildScrollView(
                              child: widget.child,
                            ),
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
        ),
    );
  }
}
