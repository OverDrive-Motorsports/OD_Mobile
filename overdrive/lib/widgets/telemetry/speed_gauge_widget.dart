import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_widget_style.dart';

class SpeedGaugeWidget extends StatefulWidget {
  const SpeedGaugeWidget({super.key});

  @override
  State<SpeedGaugeWidget> createState() => _SpeedGaugeWidgetState();
}

class _SpeedGaugeWidgetState extends State<SpeedGaugeWidget> {
  final math.Random _random = math.Random();
  Timer? _timer;
  int _speed = 186;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _speed = (_speed + _random.nextInt(31) - 15).clamp(0, 320).toInt();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: telemetryDecoration(),
      padding: const EdgeInsets.all(14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Text(
              'SPEED',
              style: AppTextStyles.label(color: AppColors.textMuted),
            ),
          ),
          Positioned.fill(
            top: 18,
            child: CustomPaint(
              painter: _SpeedGaugePainter(
                value: _speed / 320,
                backgroundColor: AppColors.surface,
                valueColor: AppColors.gold,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_speed',
                style: AppTextStyles.display(color: AppColors.textPrimary),
              ),
              Text(
                'km/h',
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedGaugePainter extends CustomPainter {
  const _SpeedGaugePainter({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
  });

  final double value;
  final Color backgroundColor;
  final Color valueColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final strokeWidth = math.max(7.0, radius * 0.12);
    final startAngle = -150 * math.pi / 180;
    final totalSweep = 300 * math.pi / 180;
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, startAngle, totalSweep, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, totalSweep * value, false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.valueColor != valueColor;
  }
}
