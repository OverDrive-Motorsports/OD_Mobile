/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [g_force.dart] - Telemetry widget rendering a live G-force scatter plot with a fading trail on a circular canvas.
 ##
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── GForce widget — maintains an 8-point trail and drives the custom painter ──

// Subscribes directly to TelemetrySimulator via a ChangeNotifier listener instead
// of context.watch so that driver switches can flush the trail without a rebuild cycle.
class GForce extends StatefulWidget {
  const GForce({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<GForce> createState() => _GForceState();
}

class _GForceState extends State<GForce> {
  late String _driverId;
  TelemetrySimulator? _simulator;
  final List<Offset> _trail = [];
  double _gLat = 0;
  double _gLon = 0;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sim = Provider.of<TelemetrySimulator>(context, listen: false);
    if (sim != _simulator) {
      _simulator?.removeListener(_onTick);
      _simulator = sim;
      _simulator!.addListener(_onTick);
    }
  }

  void _onTick() {
    if (!mounted) return;
    final snap = _simulator!.getSnapshot(_driverId);
    setState(() {
      _gLat = snap.gLat;
      _gLon = snap.gLon;
      _trail.add(Offset(snap.gLat, snap.gLon));
      if (_trail.length > 8) _trail.removeAt(0);
    });
  }

  void _changeDriver(String id) {
    setState(() {
      _driverId = id;
      _trail.clear();
    });
  }

  @override
  void dispose() {
    _simulator?.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'G-Force',
          currentDriverId: _driverId,
          onDriverSelected: _changeDriver,
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
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TelemetryHeader(label: 'G-FORCE', driverId: _driverId),
                  Expanded(
                    child: CustomPaint(
                      painter: _GForcePainter(trail: List<Offset>.from(_trail)),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  if (mode == TelemetryMode.large) ...[
                    const SizedBox(height: 6),
                    _GNumericRow(gLat: _gLat, gLon: _gLon),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Numeric G readout (large mode only) ───────────────────────────────────────

class _GNumericRow extends StatelessWidget {
  const _GNumericRow({required this.gLat, required this.gLon});
  final double gLat;
  final double gLon;

  @override
  Widget build(BuildContext context) {
    final latDir = gLat >= 0 ? '→' : '←';
    final lonDir = gLon <= 0 ? '▲' : '▼';
    final latColor = gLat.abs() > 2.5 ? AppColors.red : AppColors.textSecondary;
    final lonColor = gLon.abs() > 3.0 ? AppColors.red : AppColors.textSecondary;

    return Row(
      children: [
        _GValue(
          label: 'LAT',
          value: '$latDir ${gLat.abs().toStringAsFixed(1)}G',
          color: latColor,
        ),
        const Spacer(),
        _GValue(
          label: 'LON',
          value: '$lonDir ${gLon.abs().toStringAsFixed(1)}G',
          color: lonColor,
        ),
      ],
    );
  }
}

class _GValue extends StatelessWidget {
  const _GValue({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 9),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: AppTextStyles.caption(
            color: color,
          ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _GForcePainter extends CustomPainter {
  const _GForcePainter({required this.trail});
  final List<Offset> trail;

  static const double _maxLat = 4.0;
  static const double _maxLon = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Background disc
    canvas.drawCircle(center, radius, Paint()..color = AppColors.surface);

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Inner reference rings at 25% and 50%
    for (final f in [0.50, 0.25]) {
      canvas.drawCircle(
        center,
        radius * f,
        Paint()
          ..color = AppColors.border.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // Axis lines
    final axisPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.30)
      ..strokeWidth = 0.6;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axisPaint,
    );

    // Corner labels
    void label(String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    label('ACC', Offset(center.dx, center.dy - radius - 9));
    label('FR', Offset(center.dx, center.dy + radius + 9));
    label('G', Offset(center.dx - radius - 9, center.dy));
    label('D', Offset(center.dx + radius + 9, center.dy));

    if (trail.isEmpty) return;

    Offset toScreen(Offset g) => Offset(
      center.dx + (g.dx / _maxLat) * radius,
      center.dy - (g.dy / _maxLon) * radius,
    );

    // Trail dots with fade
    for (var i = 0; i < trail.length - 1; i++) {
      final opacity = (i + 1) / trail.length * 0.40;
      canvas.drawCircle(
        toScreen(trail[i]),
        2.5,
        Paint()..color = AppColors.white.withValues(alpha: opacity),
      );
    }

    // Current position dot
    final current = toScreen(trail.last);
    canvas.drawCircle(
      current,
      5,
      Paint()..color = AppColors.white.withValues(alpha: 0.90),
    );
    canvas.drawCircle(
      current,
      5,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _GForcePainter old) => old.trail != trail;
}
