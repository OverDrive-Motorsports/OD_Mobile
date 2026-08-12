/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [gear_rpm.dart] - Telemetry widget showing current gear and RPM bar with a coloured redline zone.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── RPM thresholds — redline at 13 500; absolute max at 15 000 rpm ──────────

const int _kRpmRedline = 13500;
const int _kRpmMax = 15000;

Color _rpmColor(int rpm) {
  if (rpm >= _kRpmRedline) return AppColors.red;
  if (rpm >= 11000) return const Color(0xFFFF8C00);
  return AppColors.white.withValues(alpha: 0.60);
}

class GearRpm extends StatefulWidget {
  const GearRpm({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<GearRpm> createState() => _GearRpmState();
}

class _GearRpmState extends State<GearRpm> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  void _showMenu(BuildContext context) {
    final actions = TelemetryItemActions.maybeOf(context);
    showTelemetryWidgetMenu(
      context,
      widgetLabel: 'Gear & RPM',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final rpmColor = _rpmColor(data.rpm);

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallGear(
                      data: data,
                      driverId: _driverId,
                      rpmColor: rpmColor,
                    )
                  : _LargeGear(
                      data: data,
                      driverId: _driverId,
                      rpmColor: rpmColor,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallGear extends StatelessWidget {
  const _SmallGear({
    required this.data,
    required this.driverId,
    required this.rpmColor,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color rpmColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'GEAR', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.gear.toDouble()),
              duration: const Duration(milliseconds: 120),
              builder: (_, v, _) => Text(
                v.round().toString(),
                style: AppTextStyles.display(color: AppColors.textPrimary)
                    .copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -3,
                    ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text(
              'RPM',
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 9),
            ),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.caption(
                color: rpmColor,
              ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
              child: Text('${(data.rpm / 1000).toStringAsFixed(1)}k'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(fraction: data.rpm / _kRpmMax, color: rpmColor),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeGear extends StatelessWidget {
  const _LargeGear({
    required this.data,
    required this.driverId,
    required this.rpmColor,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color rpmColor;

  @override
  Widget build(BuildContext context) {
    final rpmFraction = data.rpm / _kRpmMax;
    final redlineFraction = _kRpmRedline / _kRpmMax;
    final isRedline = data.rpm >= _kRpmRedline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'GEAR', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.gear.toDouble()),
              duration: const Duration(milliseconds: 120),
              builder: (_, v, _) => Text(
                v.round().toString(),
                style: AppTextStyles.display(color: AppColors.textPrimary)
                    .copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -4,
                    ),
              ),
            ),
          ),
        ),
        // RPM label row
        Row(
          children: [
            Text(
              'RPM',
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 9),
            ),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.caption(
                color: rpmColor,
              ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
              child: Text('${data.rpm}  /  $_kRpmRedline'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // RPM bar with redline indicator
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: rpmFraction.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          builder: (_, f, _) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: AppColors.surface),
                  // Redline zone
                  FractionallySizedBox(
                    widthFactor: 1.0 - redlineFraction,
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: AppColors.red.withValues(alpha: 0.15),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: f,
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      color: rpmColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isRedline) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'REDLINE',
                style: AppTextStyles.label(
                  color: AppColors.red,
                ).copyWith(fontSize: 9, letterSpacing: 0.8),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
