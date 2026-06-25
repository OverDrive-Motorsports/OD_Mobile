import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_widget_style.dart';

class RpmBar extends StatefulWidget {
  const RpmBar({super.key});

  @override
  State<RpmBar> createState() => _RpmBarState();
}

class _RpmBarState extends State<RpmBar> {
  final math.Random _random = math.Random();
  Timer? _timer;
  int _rpm = 9400;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() {
        _rpm = (_rpm + _random.nextInt(2201) - 900).clamp(0, 18000).toInt();
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
    final ratio = _rpm / 18000;
    final isRedZone = ratio >= 0.8;

    return Container(
      decoration: telemetryDecoration(
        accentColor: isRedZone ? AppColors.red : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RPM',
                  style: AppTextStyles.label(color: AppColors.textMuted),
                ),
                const Spacer(),
                Text(
                  '$_rpm',
                  style: AppTextStyles.display(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isRedZone ? 1 : 0,
                  child: Text(
                    'RED ZONE',
                    style: AppTextStyles.label(color: AppColors.red),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        const _RpmZones(opacity: 0.22),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          alignment: Alignment.centerLeft,
                          child: const _RpmZones(opacity: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RpmZones extends StatelessWidget {
  const _RpmZones({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 40,
          child: ColoredBox(color: AppColors.green.withValues(alpha: opacity)),
        ),
        Expanded(
          flex: 40,
          child: ColoredBox(color: AppColors.gold.withValues(alpha: opacity)),
        ),
        Expanded(
          flex: 20,
          child: ColoredBox(color: AppColors.red.withValues(alpha: opacity)),
        ),
      ],
    );
  }
}
