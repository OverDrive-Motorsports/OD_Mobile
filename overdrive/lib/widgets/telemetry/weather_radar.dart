/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## weather_radar.dart - Animated precipitation radar map telemetry widget.
 ##
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Root widget that drives the radar pulse animation and overlays status badges.
class WeatherRadar extends StatefulWidget {
  const WeatherRadar({super.key});

  @override
  State<WeatherRadar> createState() => _WeatherRadarState();
}

class _WeatherRadarState extends State<WeatherRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<TelemetrySimulator>().getWeatherForecast();
    final firstRain = forecast.indexWhere(
      (h) => h.condition == 'rain' || h.condition == 'storm',
    );

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Radar Météo',
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return Stack(
              children: [
                // ── Full-bleed radar map ──
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => CustomPaint(
                      painter: _RadarMapPainter(pulse: _anim.value),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // ── UI overlay ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top badges
                      Row(
                        children: [
                          _Badge(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _anim,
                                  builder: (_, _) => Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.green.withValues(
                                        alpha: 0.5 + _anim.value * 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'RADAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (firstRain > 0 && mode == TelemetryMode.large) ...[
                            const SizedBox(width: 5),
                            _Badge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.water_drop_rounded,
                                    size: 8,
                                    color: Color(0xFF64B5F6),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'AVERSES ~${firstRain}H',
                                    style: const TextStyle(
                                      color: Color(0xFF90CAF9),
                                      fontSize: 7,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      // Legend (large mode only)
                      if (mode == TelemetryMode.large)
                        const _Badge(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LegendDot(
                                color: Color(0xFF00E5FF),
                                label: 'LÉGÈRE',
                              ),
                              SizedBox(width: 8),
                              _LegendDot(
                                color: Color(0xFF76FF03),
                                label: 'MODÉRÉE',
                              ),
                              SizedBox(width: 8),
                              _LegendDot(
                                color: Color(0xFFFFEE00),
                                label: 'FORTE',
                              ),
                              SizedBox(width: 8),
                              _LegendDot(
                                color: Color(0xFFFF6600),
                                label: 'INTENSE',
                              ),
                              SizedBox(width: 8),
                              _LegendDot(
                                color: Color(0xFFFF1100),
                                label: 'EXTRÊME',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Semi-transparent dark badge container ─────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xCC111111),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 6.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Radar map painter ─────────────────────────────────────────────────────────

// CustomPainter that draws range rings, terrain lines, precipitation blobs, and a circuit marker.
class _RadarMapPainter extends CustomPainter {
  const _RadarMapPainter({required this.pulse});
  final double pulse; // 0–1

  static const int _kMaxKm = 105;
  static const List<int> _kRings = [15, 30, 45, 60, 75, 90, 105];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    // Radius for the 105 km ring — fits inside the widget with 4% margin
    final maxR = math.min(size.width, size.height) * 0.46;
    final kmScale = maxR / _kMaxKm;

    // ── Terrain background ──────────────────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD0D4BE), Color(0xFFC0C4AE)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Subtle terrain feature lines (fake roads/rivers)
    _drawTerrainLines(canvas, size, center);

    // ── Precipitation blobs (drawn before rings) ────────────────────────────
    _drawPrecipitation(canvas, center, maxR, pulse);

    // ── Range rings ─────────────────────────────────────────────────────────
    final ringPaint = Paint()
      ..color = const Color(0xFF444444).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (final km in _kRings) {
      final r = km * kmScale;
      canvas.drawCircle(center, r, ringPaint);

      // Distance label — left side of each ring
      final tp = TextPainter(
        text: TextSpan(
          text: '$km km',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 6,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - r - tp.width - 2, cy + 2));
    }

    // ── Crosshairs ───────────────────────────────────────────────────────────
    final crossPaint = Paint()
      ..color = const Color(0xFF444444).withValues(alpha: 0.48)
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), crossPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), crossPaint);

    // ── Circuit marker at center ─────────────────────────────────────────────
    _drawCircuitMarker(canvas, center);
  }

  // Simple stylized terrain — a few thin gray diagonal lines to suggest roads
  void _drawTerrainLines(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFFAAAAAA).withValues(alpha: 0.40)
      ..strokeWidth = 0.6;

    final cx = center.dx;
    final cy = center.dy;

    // A few abstract road-like polylines
    canvas.drawLine(Offset(cx * 0.2, 0), Offset(cx * 1.4, size.height), paint);
    canvas.drawLine(Offset(0, cy * 0.6), Offset(size.width, cy * 1.3), paint);
    canvas.drawLine(Offset(cx * 1.7, 0), Offset(cx * 0.4, size.height), paint);
    canvas.drawLine(
      Offset(0, cy * 1.5),
      Offset(size.width * 0.7, cy * 0.3),
      paint,
    );

    // A small "water body" oval (muted blue)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx * 0.35, cy * 1.55),
        width: 28,
        height: 14,
      ),
      Paint()..color = const Color(0xFF8BBED6).withValues(alpha: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx * 1.70, cy * 0.45),
        width: 18,
        height: 10,
      ),
      Paint()..color = const Color(0xFF8BBED6).withValues(alpha: 0.40),
    );
  }

  // Layered precipitation blobs — cyan → green → yellow → orange → red
  void _drawPrecipitation(
    Canvas canvas,
    Offset center,
    double maxR,
    double pulse,
  ) {
    // Subtle scale pulse so the edges "breathe" slightly
    final p = 1.0 + (pulse - 0.5) * 0.012;

    void blob(double nx, double ny, double nr, Color color, double opacity) {
      final bx = center.dx + nx * maxR * p;
      final by = center.dy + ny * maxR * p;
      final br = nr * maxR * p;
      canvas.drawCircle(
        Offset(bx, by),
        br,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
            stops: const [0.15, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: br)),
      );
    }

    // ── Main storm — NW to N, approaching center from NW ────────────────────
    // Layer 1 — outermost light cyan (broad, diffuse)
    blob(-0.50, -0.52, 0.52, const Color(0xFF00E5FF), 0.70);
    blob(-0.18, -0.50, 0.42, const Color(0xFF00DDFF), 0.66);
    blob(-0.62, -0.18, 0.38, const Color(0xFF00D8FF), 0.64);
    blob(-0.22, -0.22, 0.32, const Color(0xFF00D0FF), 0.68);
    blob(0.08, -0.58, 0.30, const Color(0xFF00DDFF), 0.62);
    blob(-0.38, 0.10, 0.28, const Color(0xFF00C8FF), 0.58); // SW extension
    blob(0.26, -0.40, 0.24, const Color(0xFF00CCFF), 0.62);
    blob(-0.08, -0.12, 0.22, const Color(0xFF00C0FF), 0.60); // close to center

    // Layer 2 — medium cyan / blue-cyan
    blob(-0.22, -0.38, 0.34, const Color(0xFF00CCFF), 0.75);
    blob(0.12, -0.42, 0.26, const Color(0xFF00BBFF), 0.72);
    blob(-0.05, -0.25, 0.22, const Color(0xFF00AAFF), 0.70);

    // Layer 3 — green (moderate rain)
    blob(-0.14, -0.32, 0.30, const Color(0xFF44EE00), 0.78);
    blob(0.14, -0.35, 0.24, const Color(0xFF66EE00), 0.74);
    blob(0.00, -0.20, 0.20, const Color(0xFF55DD00), 0.74);
    blob(0.18, -0.28, 0.16, const Color(0xFF77EE00), 0.70);

    // Layer 4 — yellow-green (heavy)
    blob(0.10, -0.26, 0.18, const Color(0xFFCCFF00), 0.82);
    blob(0.22, -0.22, 0.14, const Color(0xFFEEFF00), 0.78);
    blob(0.00, -0.16, 0.14, const Color(0xFFDDFF00), 0.78);

    // Layer 5 — yellow (very heavy)
    blob(0.17, -0.18, 0.11, const Color(0xFFFFEE00), 0.86);
    blob(0.26, -0.14, 0.08, const Color(0xFFFFDD00), 0.82);

    // Layer 6 — orange (intense)
    blob(0.19, -0.12, 0.075, const Color(0xFFFF8800), 0.88);
    blob(0.28, -0.10, 0.055, const Color(0xFFFF6600), 0.86);

    // Layer 7 — red (extreme core)
    blob(0.21, -0.08, 0.042, const Color(0xFFFF2200), 0.92);
    blob(0.25, -0.06, 0.030, const Color(0xFFFF0000), 0.96);

    // ── Isolated cell — E/SE ─────────────────────────────────────────────────
    blob(0.66, 0.28, 0.14, const Color(0xFF00DDFF), 0.70);
    blob(0.66, 0.26, 0.09, const Color(0xFF55EE00), 0.76);
    blob(0.68, 0.23, 0.055, const Color(0xFFFFEE00), 0.84);
    blob(0.69, 0.21, 0.032, const Color(0xFFFF8800), 0.90);
    blob(0.70, 0.20, 0.016, const Color(0xFFFF2200), 0.94);

    // ── Scattered light rain — S/SE ──────────────────────────────────────────
    blob(0.06, 0.70, 0.09, const Color(0xFF00D8FF), 0.60);
    blob(-0.24, 0.74, 0.07, const Color(0xFF00D0FF), 0.55);
    blob(0.32, 0.78, 0.06, const Color(0xFF00CCFF), 0.52);
  }

  void _drawCircuitMarker(Canvas canvas, Offset center) {
    // Outer circle
    canvas.drawCircle(
      center,
      5.5,
      Paint()
        ..color = const Color(0xFF111111).withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Inner fill
    canvas.drawCircle(
      center,
      2.2,
      Paint()..color = const Color(0xFF111111).withValues(alpha: 0.80),
    );
    // Small tick marks at N/S/E/W on the circle
    final tickPaint = Paint()
      ..color = const Color(0xFF111111).withValues(alpha: 0.80)
      ..strokeWidth = 1.2;
    for (final angle in [0.0, math.pi / 2, math.pi, 3 * math.pi / 2]) {
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * 4.5,
          center.dy + math.sin(angle) * 4.5,
        ),
        Offset(
          center.dx + math.cos(angle) * 7.0,
          center.dy + math.sin(angle) * 7.0,
        ),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarMapPainter old) => old.pulse != pulse;
}
