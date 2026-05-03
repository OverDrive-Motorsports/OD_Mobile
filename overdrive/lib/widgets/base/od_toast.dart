/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_toast.dart - Shared singleton toast overlay for temporary feedback.
##
*/

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum ToastType { error, success, info }

/// A helper used to show a single shared toast at a time.
class OdToast {
  const OdToast._();

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
      builder: (_) => _OdToastEntry(
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
class _OdToastEntry extends StatefulWidget {
  const _OdToastEntry({
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
  State<_OdToastEntry> createState() => _OdToastEntryState();
}

/// The state that runs the toast animations and auto-dismiss timer.
class _OdToastEntryState extends State<_OdToastEntry>
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
      begin: const Offset(0, 0.28),
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
    final bottomOffset = MediaQuery.paddingOf(context).bottom + 24;

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomOffset,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.toastSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, size: 18, color: style.color),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: AppTextStyles.body().copyWith(fontSize: 14),
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
    );
  }
}

/// A small style object used internally by the toast widget.
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
