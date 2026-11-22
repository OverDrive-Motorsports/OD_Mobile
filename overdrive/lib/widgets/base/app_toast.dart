/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_toast.dart - Ephemeral toast notification with auto-dismiss and slide-up animation.
 ##
 */

import 'dart:async';

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ── Glass theme ───────────────────────────────────────────────────────────

const _kToastBorderColor = Color(0x22FFFFFF);

final _kToastTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.28,
  blurSigma: 32.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.06,
  edgeLightColor: _kToastBorderColor,
  edgeShadowColor: _kToastBorderColor,
);

/// Semantic toast styles mapped to shared app colors and icons.
enum ToastType { error, success, info }

/// A helper used to show a single shared toast at a time.
class AppToast {
  const AppToast._();

  static OverlayEntry? _activeEntry;
  static VoidCallback? _removeActiveEntry;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _removeActiveEntry?.call();

    late final OverlayEntry entry;
    void removeEntry() {
      if (_activeEntry == entry) {
        _activeEntry = null;
        _removeActiveEntry = null;
      }

      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (_) => _AppToastEntry(
        message: message,
        type: type,
        duration: duration,
        onDismissed: removeEntry,
      ),
    );

    _activeEntry = entry;
    _removeActiveEntry = removeEntry;
    overlay.insert(entry);
  }
}

/// A temporary toast overlay entry with its own animation lifecycle.
class _AppToastEntry extends StatefulWidget {
  const _AppToastEntry({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppToastEntry> createState() => _AppToastEntryState();
}

class _AppToastEntryState extends State<_AppToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Runs the reverse animation then notifies the overlay controller to remove this entry.
  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) {
      return;
    }

    _isDismissing = true;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final style = _ToastStyle.resolve(widget.type);
    final topOffset = MediaQuery.paddingOf(context).top + 14;

    return Positioned(
      left: 20,
      right: 20,
      top: topOffset,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoLiquidGlass(
                    theme: _kToastTheme,
                    borderRadius: BorderRadius.circular(999),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(style.icon, size: 20, color: style.color),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: AppTextStyles.body().copyWith(
                                  fontSize: 15,
                                ),
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
      ),
    );
  }
}

// Maps a ToastType to the appropriate icon and accent colour for the toast pill.
class _ToastStyle {
  const _ToastStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  static _ToastStyle resolve(ToastType type) {
    return switch (type) {
      ToastType.error => const _ToastStyle(
        icon: Icons.close_rounded,
        color: AppColors.red,
      ),
      ToastType.success => const _ToastStyle(
        icon: Icons.check_rounded,
        color: AppColors.green,
      ),
      ToastType.info => const _ToastStyle(
        icon: Icons.info_outline_rounded,
        color: AppColors.blue,
      ),
    };
  }
}
