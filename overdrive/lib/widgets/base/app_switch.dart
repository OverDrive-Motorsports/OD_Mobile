/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_switch.dart - Custom liquid-glass toggle switch for OverDrive surfaces.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_theme.dart';

// ── Layout constants ──────────────────────────────────────────────────────

const double _kTrackW = 52.0;
const double _kTrackH = 30.0;
const double _kThumbSize = 22.0;
const double _kThumbPad = 4.0;
const double _kThumbTravel = _kTrackW - _kThumbSize - _kThumbPad * 2; // 22 px

// ── Glass theme ───────────────────────────────────────────────────────────

const _kEdgeColor = Color(0x22FFFFFF);

final _kTrackTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.10,
  blurSigma: 20.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.03,
  edgeLightColor: _kEdgeColor,
  edgeShadowColor: _kEdgeColor,
);

// ── Spring ────────────────────────────────────────────────────────────────

const _kSpring = SpringDescription(mass: 0.8, stiffness: 280.0, damping: 20.0);

// ── AppSwitch ─────────────────────────────────────────────────────────────

/// Liquid-glass toggle switch, optionally paired with a label row.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final toggle = _SwitchTrack(value: value, onChanged: onChanged);

    if (label == null) {
      return SizedBox(
        height: 44,
        child: Align(child: toggle),
      );
    }

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label!,
              style: AppTextStyles.body().copyWith(fontSize: 15),
            ),
          ),
          toggle,
        ],
      ),
    );
  }
}

// ── _SwitchTrack ──────────────────────────────────────────────────────────

class _SwitchTrack extends StatefulWidget {
  const _SwitchTrack({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_SwitchTrack> createState() => _SwitchTrackState();
}

class _SwitchTrackState extends State<_SwitchTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final ValueNotifier<double> _pos;
  late final ValueNotifier<double> _vel;
  double _lastValue = 0.0;

  @override
  void initState() {
    super.initState();
    final initial = widget.value ? 1.0 : 0.0;
    _lastValue = initial;
    _pos = ValueNotifier(initial);
    _vel = ValueNotifier(0.0);
    _ctrl = AnimationController.unbounded(vsync: this, value: initial)
      ..addListener(_onFrame);
  }

  void _onFrame() {
    _vel.value = _ctrl.value - _lastValue;
    _lastValue = _ctrl.value;
    _pos.value = _ctrl.value;
  }

  @override
  void didUpdateWidget(covariant _SwitchTrack old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _animateTo(widget.value ? 1.0 : 0.0);
    }
  }

  void _animateTo(double target) {
    final sim = SpringSimulation(
      _kSpring,
      _ctrl.value,
      target,
      _vel.value * 60,
    );
    _ctrl.animateWith(sim);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onFrame);
    _ctrl.dispose();
    _pos.dispose();
    _vel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: CupertinoLiquidGlass(
          theme: _kTrackTheme,
          borderRadius: BorderRadius.circular(999),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: _kTrackW,
              height: _kTrackH,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  return Stack(
                    children: [
                      // ── "On" color overlay ───────────────────────────
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(
                              alpha: (_pos.value * 0.55).clamp(0.0, 0.55),
                            ),
                          ),
                        ),
                      ),

                      // ── Thumb ────────────────────────────────────────
                      CustomPaint(
                        size: const Size(_kTrackW, _kTrackH),
                        painter: _ThumbPainter(
                          position: _pos.value,
                          velocity: _vel.value,
                          isOn: widget.value,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _ThumbPainter ─────────────────────────────────────────────────────────

class _ThumbPainter extends CustomPainter {
  const _ThumbPainter({
    required this.position,
    required this.velocity,
    required this.isOn,
  });

  final double position;
  final double velocity;
  final bool isOn;

  @override
  void paint(Canvas canvas, Size size) {
    final normPos = position.clamp(0.0, 1.0);
    final absVel = velocity.abs();

    // Stretch in direction of travel (caps at 1.45x width)
    final stretch = (1.0 + absVel * 32.0).clamp(1.0, 1.45);
    final thumbW = _kThumbSize * stretch;
    final thumbH = _kThumbSize;

    // Shift left when stretching so the leading edge leads
    final centerX = _kThumbPad + normPos * _kThumbTravel + _kThumbSize / 2;
    final stretchOffset = velocity > 0
        ? (thumbW - _kThumbSize) / 2
        : -(thumbW - _kThumbSize) / 2;
    final thumbLeft = centerX - thumbW / 2 + stretchOffset;
    final thumbTop = (size.height - thumbH) / 2;

    final rect = Rect.fromLTWH(thumbLeft, thumbTop, thumbW, thumbH);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(999));

    // Shadow
    canvas.drawShadow(
      Path()..addRRect(rRect),
      const Color(0xFF000000),
      isOn ? 4.0 : 2.5,
      true,
    );

    // Thumb fill — slightly warmer white when on
    final thumbColor = Color.lerp(
      const Color(0xFFEEEEEE),
      const Color(0xFFFFFFFF),
      normPos,
    )!;
    canvas.drawRRect(rRect, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(covariant _ThumbPainter old) =>
      old.position != position ||
      old.velocity != velocity ||
      old.isOn != isOn;
}
