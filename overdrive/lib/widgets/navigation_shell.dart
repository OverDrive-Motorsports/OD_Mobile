/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## navigation_shell.dart - Liquid glass floating bottom navigation shell.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

const double _kBarHeight = 52.0;

// ---------------------------------------------------------------------------
// NavigationShell
// ---------------------------------------------------------------------------

class NavigationShell extends StatefulWidget {
  const NavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  bool _shrink = false;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 2.0 && !_shrink) {
        setState(() => _shrink = true);
      } else if (delta < -2.0 && _shrink) {
        setState(() => _shrink = false);
      }
    } else if (notification is ScrollEndNotification && _shrink) {
      setState(() => _shrink = false);
    }
    return false;
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // No extra bottom gap — pill sits right at the system inset boundary.
    // extendBody: true makes the page content fill behind the bar so there
    // is no black strip below the pill.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.black,
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: widget.navigationShell,
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: bottomInset,
          ),
          child: AnimatedScale(
            scale: _shrink ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: _GlassBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onTap,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GlassBar — spring-animated liquid selector
// ---------------------------------------------------------------------------

const _tabs = <(IconData, IconData)>[
  (CupertinoIcons.house, CupertinoIcons.house_fill),
  (CupertinoIcons.search, CupertinoIcons.search),
  (CupertinoIcons.flag, CupertinoIcons.flag_fill),
  (CupertinoIcons.calendar, CupertinoIcons.calendar_today),
  (CupertinoIcons.person, CupertinoIcons.person_fill),
];

class _GlassBar extends StatefulWidget {
  const _GlassBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_GlassBar> createState() => _GlassBarState();
}

class _GlassBarState extends State<_GlassBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final ValueNotifier<double> _position;
  late final ValueNotifier<double> _velocity;

  // Same spring constants as the cupertino_liquid_glass package.
  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 320.0,
    damping: 22.0,
  );

  int get _maxIndex => _tabs.length - 1;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentIndex.toDouble();
    _position = ValueNotifier(initial);
    _velocity = ValueNotifier(0.0);
    _ctrl = AnimationController.unbounded(vsync: this, value: initial)
      ..addListener(() {
        _position.value = _ctrl.value;
        _velocity.value = _ctrl.velocity;
      });
  }

  @override
  void didUpdateWidget(_GlassBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _animateTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _position.dispose();
    _velocity.dispose();
    super.dispose();
  }

  void _animateTo(int index, {double initialVelocity = 0.0}) {
    _ctrl.animateWith(SpringSimulation(
      _spring,
      _position.value,
      index.toDouble(),
      initialVelocity,
    ));
  }

  // Drag gesture — swipe across the bar to slide the selector.
  void _onDragUpdate(DragUpdateDetails d, double contentWidth) {
    _ctrl.stop();
    final tabWidth = contentWidth / _tabs.length;
    final delta = d.delta.dx / tabWidth;
    _position.value = (_position.value + delta).clamp(0.0, _maxIndex.toDouble());
    _velocity.value = delta;
  }

  void _onDragEnd(DragEndDetails d, double contentWidth) {
    final tabWidth = contentWidth / _tabs.length;
    final flingVel = d.velocity.pixelsPerSecond.dx / tabWidth;
    int target = _position.value.round();
    if (flingVel.abs() > 3.0) {
      target = flingVel > 0
          ? _position.value.ceil()
          : _position.value.floor();
    }
    target = target.clamp(0, _maxIndex);
    widget.onTap(target);
    _animateTo(target, initialVelocity: flingVel);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoLiquidGlass(
      borderRadius: const BorderRadius.all(Radius.circular(28.0)),
      child: SizedBox(
        height: _kBarHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => _onDragUpdate(d, contentWidth),
              onHorizontalDragEnd: (d) => _onDragEnd(d, contentWidth),
              child: Stack(
                children: [
                  // Liquid selector pill (spring + velocity stretch).
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _SelectorPainter(
                        position: _position,
                        velocity: _velocity,
                        tabCount: _tabs.length,
                      ),
                      size: Size(contentWidth, _kBarHeight),
                    ),
                  ),
                  // Icon row — color interpolates with position.
                  Row(
                    children: List.generate(_tabs.length, (i) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTap(i);
                            _animateTo(i, initialVelocity: _velocity.value);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: _AnimatedTabIcon(
                              index: i,
                              position: _position,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AnimatedTabIcon — color + icon interpolate with spring position
// ---------------------------------------------------------------------------

class _AnimatedTabIcon extends StatelessWidget {
  const _AnimatedTabIcon({required this.index, required this.position});

  final int index;
  final ValueListenable<double> position;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: position,
      builder: (context, _) {
        final proximity = (1.0 - (position.value - index).abs()).clamp(0.0, 1.0);
        final isActive = proximity > 0.5;
        final color = Color.lerp(AppColors.grayText, AppColors.white, proximity)!;
        final scale = 1.0 + proximity * 0.12;

        return Transform.scale(
          scale: scale,
          child: Icon(
            isActive ? _tabs[index].$2 : _tabs[index].$1,
            color: color,
            size: 22.0,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _SelectorPainter — velocity-stretched liquid pill (ported from package)
// ---------------------------------------------------------------------------

class _SelectorPainter extends CustomPainter {
  _SelectorPainter({
    required this.position,
    required this.velocity,
    required this.tabCount,
  }) : super(repaint: Listenable.merge([position, velocity]));

  final ValueListenable<double> position;
  final ValueListenable<double> velocity;
  final int tabCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (tabCount == 0) return;

    final pos = position.value;
    final vel = velocity.value;
    final tabWidth = size.width / tabCount;

    // Velocity-based stretch: faster → wider pill (max ~1.36×).
    final absVel = vel.abs().clamp(0.0, 20.0);
    final stretch = 1.0 + absVel / 55.0;

    final baseWidth = tabWidth * 0.82;
    final selectorWidth = baseWidth * stretch;
    final x = pos * tabWidth + (tabWidth - selectorWidth) / 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, 3.0, selectorWidth, size.height - 6.0),
      const Radius.circular(16.0),
    );

    // 1. Bloom glow.
    canvas.drawRRect(
      rrect.inflate(3.0),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
    );

    // 2. Fill — translucent pill.
    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.white.withValues(alpha: 0.10),
    );

    // 3. Inner highlight — faint top edge for depth.
    canvas.drawRRect(
      rrect.deflate(0.25),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.20),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ).createShader(rrect.outerRect),
    );
  }

  @override
  bool shouldRepaint(_SelectorPainter old) => tabCount != old.tabCount;
}
