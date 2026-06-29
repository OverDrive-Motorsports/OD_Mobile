/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [speedometer.dart] - Telemetry widget displaying real-time vehicle speed in km/h with DRS and gear indicators.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Telemetry widget for vehicle speed; switches between compact and detailed
// layouts based on available grid cell size via TelemetryMode.
class Speedometer extends StatefulWidget {
  const Speedometer({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
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
      widgetLabel: 'Speed',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallSpeed(data: data, driverId: _driverId)
                  : _LargeSpeed(data: data, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallSpeed extends StatelessWidget {
  const _SmallSpeed({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SPEED', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.speed),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (_, v, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    v.toInt().toString(),
                    style: AppTextStyles.display(color: AppColors.textPrimary)
                        .copyWith(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -2),
                  ),
                  Text(
                    'km/h',
                    style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        TelemetryBar(
          fraction: data.speed / 340,
          color: AppColors.white.withValues(alpha: 0.60),
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeSpeed extends StatelessWidget {
  const _LargeSpeed({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SPEED', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.speed),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (_, v, _) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Fixed-width right-aligned so digits don't shift the layout
                  SizedBox(
                    width: 92,
                    child: Text(
                      v.toInt().toString(),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.display(color: AppColors.textPrimary)
                          .copyWith(fontSize: 58, fontWeight: FontWeight.bold, letterSpacing: -3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'km/h',
                    style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        // DRS + Gear row
        Row(
          children: [
            _DrsChip(active: data.drs),
            const Spacer(),
            _GearChip(gear: data.gear),
          ],
        ),
        const SizedBox(height: 8),
        // Speed vs max bar
        Row(
          children: [
            Text(
              'TOP ${data.maxSpeedLap.toInt()}',
              style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
            ),
            const Spacer(),
            Text(
              'AVG ${data.avgSpeedLap.toInt()}',
              style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(
          fraction: data.speed / 340,
          color: AppColors.white.withValues(alpha: 0.60),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DrsChip extends StatelessWidget {
  const _DrsChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.textMuted.withValues(alpha: 0.40);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.label(color: color).copyWith(fontSize: 10),
          child: const Text('DRS'),
        ),
      ],
    );
  }
}

class _GearChip extends StatelessWidget {
  const _GearChip({required this.gear});
  final int gear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'G',
          style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 10),
        ),
        const SizedBox(width: 2),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: gear.toDouble()),
          duration: const Duration(milliseconds: 120),
          builder: (_, v, _) => Text(
            v.round().toString(),
            style: AppTextStyles.bodyBold(color: AppColors.textPrimary).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
