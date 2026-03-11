import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/router/app_navigation_controller.dart';
import '../core/theme/app_theme.dart';

class TopLeftMenuOverlay extends StatefulWidget {
  const TopLeftMenuOverlay({super.key});

  @override
  State<TopLeftMenuOverlay> createState() => _TopLeftMenuOverlayState();
}

class _TopLeftMenuOverlayState extends State<TopLeftMenuOverlay>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _menuCtrl;
  late final Animation<double> _menuFade;
  late final Animation<Offset> _menuSlide;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _menuFade = CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOut);
    _menuSlide = Tween<Offset>(
      begin: const Offset(0.06, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _menuCtrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _menuCtrl.forward() : _menuCtrl.reverse();
  }

  void _closeMenu() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _menuCtrl.reverse();
  }

  void _navigateTo(int index) {
    _closeMenu();
    setAppNavigationIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    const sidePad = 12.0;

    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black.withOpacity(0.12)),
            ),
          ),
        Positioned(
          top: topPad + 7,
          left: sidePad,
          child: Text(
            'OD',
            style: AppTextStyles.display().copyWith(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Positioned(
          top: topPad + 8,
          right: sidePad,
          child: _TopLeftButton(
            isOpen: _isOpen,
            onTap: _toggleMenu,
          ),
        ),
        Positioned(
          top: topPad + 54,
          right: sidePad,
          child: FadeTransition(
            opacity: _menuFade,
            child: SlideTransition(
              position: _menuSlide,
              child: IgnorePointer(
                ignoring: !_isOpen,
                child: ValueListenableBuilder<int>(
                  valueListenable: appNavigationIndex,
                  builder: (context, selectedIndex, child) {
                    return _CompactMenu(
                      selectedIndex: selectedIndex,
                      onClose: _closeMenu,
                      onNavigate: _navigateTo,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopLeftButton extends StatelessWidget {
  const _TopLeftButton({
    required this.isOpen,
    required this.onTap,
  });

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isOpen ? Colors.white.withOpacity(0.24) : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Accueil',
              style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMenu extends StatelessWidget {
  const _CompactMenu({
    required this.selectedIndex,
    required this.onClose,
    required this.onNavigate,
  });

  final int selectedIndex;
  final VoidCallback onClose;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 212,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xDB1C1C1E), Color(0xCF111113)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompactMenuEntry(
                icon: Icons.home_rounded,
                label: 'Accueil',
                active: selectedIndex == 0,
                onTap: () => onNavigate(0),
              ),
              _CompactMenuEntry(
                customLeading: const _F1Glyph(),
                label: 'Formule 1',
                active: selectedIndex == 1,
                onTap: () => onNavigate(1),
              ),
              _CompactMenuEntry(
                icon: Icons.live_tv_rounded,
                label: 'TV',
                active: selectedIndex == 2,
                onTap: () => onNavigate(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMenuEntry extends StatelessWidget {
  const _CompactMenuEntry({
    required this.label,
    required this.onTap,
    this.icon,
    this.customLeading,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? customLeading;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: customLeading ?? Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(color: Colors.white).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _F1Glyph extends StatelessWidget {
  const _F1Glyph();

  @override
  Widget build(BuildContext context) {
    return Text(
      'F1',
      style: AppTextStyles.bodyBold(color: AppColors.red).copyWith(
        fontSize: 15,
        letterSpacing: -0.4,
      ),
    );
  }
}
