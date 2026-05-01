/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## menu_overlay.dart - Overlay menu and quick navigation panel.
 ##
 */

import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/health_service.dart';
import 'glass_pill.dart';

/// A floating top menu shown above the current page.
class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

/// The state that controls the menu open and close animations.
class _MenuOverlayState extends State<MenuOverlay>
    with SingleTickerProviderStateMixin {
  final HealthService _healthService = HealthService();

  bool _isOpen = false;
  bool _isLoadingHealth = false;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.06, -0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _animationController.forward() : _animationController.reverse();
  }

  void _closeMenu() {
    if (!_isOpen) {
      return;
    }

    setState(() => _isOpen = false);
    _animationController.reverse();
  }

  void _goHome() {
    _closeMenu();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showHealthStatus() async {
    if (_isLoadingHealth) {
      return;
    }

    _closeMenu();
    setState(() => _isLoadingHealth = true);

    try {
      final health = await _healthService.getHealth();
      if (!mounted) {
        return;
      }

      _showMessage(
        message: 'Backend health: ${health.status} (${health.timestampLabel})',
        backgroundColor: AppColors.success,
      );
    } on HealthServiceException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        message: 'Backend indisponible: ${exception.message}',
        backgroundColor: AppColors.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingHealth = false);
      }
    }
  }

  void _showMessage({required String message, required Color backgroundColor}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(backgroundColor: backgroundColor, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ),
        Positioned(
          top: topPadding + 7,
          left: 12,
          child: Text('OD', style: AppTextStyles.display()),
        ),
        Positioned(
          top: topPadding + 8,
          right: 12,
          child: MenuButton(isOpen: _isOpen, onTap: _toggleMenu),
        ),
        Positioned(
          top: topPadding + 54,
          right: 12,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: IgnorePointer(
                ignoring: !_isOpen,
                child: MenuPanel(
                  isLoadingHealth: _isLoadingHealth,
                  onHealthTap: _showHealthStatus,
                  onHomeTap: _goHome,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact pill button used to open and close the menu.
class MenuButton extends StatelessWidget {
  const MenuButton({required this.isOpen, required this.onTap, super.key});

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPill(
        highlighted: isOpen,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Menu',
              style: AppTextStyles.bodyBold().copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// A floating panel that groups the menu actions.
class MenuPanel extends StatelessWidget {
  const MenuPanel({
    required this.isLoadingHealth,
    required this.onHealthTap,
    required this.onHomeTap,
    super.key,
  });

  final bool isLoadingHealth;
  final VoidCallback onHealthTap;
  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    final actions = <MenuEntry>[
      MenuEntry(icon: Icons.home_outlined, label: 'Home', onTap: onHomeTap),
      MenuEntry(
        icon: Icons.monitor_heart_outlined,
        label: isLoadingHealth ? 'Health...' : 'Health',
        onTap: onHealthTap,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 212,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xDB1C1C1E), Color(0xCF111113)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in actions) ...[
                MenuAction(
                  icon: action.icon,
                  label: action.label,
                  onTap: action.onTap,
                ),
                if (action != actions.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


/// A simple data object that describes one menu action.
class MenuEntry {
  const MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// A visual row used inside the menu panel.
class MenuAction extends StatelessWidget {
  const MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body().copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
