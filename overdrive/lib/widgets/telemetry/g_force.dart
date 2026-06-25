import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

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
      _trail.add(Offset(snap.gLat, snap.gLon));
      if (_trail.length > 6) _trail.removeAt(0);
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
      child: Container(
        decoration: telemetryDecoration(accentColor: AppColors.blue),
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final scale = (w / 160).clamp(0.6, 1.6);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'G-FORCE',
                      style: AppTextStyles.label(color: AppColors.textMuted)
                          .copyWith(fontSize: 10 * scale),
                    ),
                    const Spacer(),
                    Text(
                      _driverId,
                      style: AppTextStyles.label(color: AppColors.gold)
                          .copyWith(fontSize: 10 * scale),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _GForcePainter(trail: List<Offset>.from(_trail)),
                    child: const SizedBox.expand(),
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

class _GForcePainter extends CustomPainter {
  const _GForcePainter({required this.trail});

  final List<Offset> trail;

  static const double _maxLat = 4.0;
  static const double _maxLon = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.surface);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (final factor in [0.5, 0.25]) {
      canvas.drawCircle(
        center,
        radius * factor,
        Paint()
          ..color = AppColors.divider
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    final axisPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.8;
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

    void drawLabel(String text, Offset pos) {
      final span = TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    drawLabel('Acc.', Offset(center.dx, center.dy - radius - 8));
    drawLabel('Fr.', Offset(center.dx, center.dy + radius + 8));
    drawLabel('G', Offset(center.dx - radius - 10, center.dy));
    drawLabel('D', Offset(center.dx + radius + 10, center.dy));

    if (trail.isEmpty) return;

    Offset toScreen(Offset g) => Offset(
          center.dx + (g.dx / _maxLat) * radius,
          center.dy - (g.dy / _maxLon) * radius,
        );

    for (var i = 0; i < trail.length - 1; i++) {
      final opacity = (i + 1) / trail.length * 0.55;
      canvas.drawCircle(
        toScreen(trail[i]),
        3,
        Paint()..color = AppColors.blue.withValues(alpha: opacity),
      );
    }

    final current = toScreen(trail.last);
    canvas.drawCircle(current, 5, Paint()..color = AppColors.blue);
    canvas.drawCircle(
      current,
      5,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _GForcePainter old) => old.trail != trail;
}
