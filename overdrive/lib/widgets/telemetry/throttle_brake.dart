/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [throttle_brake.dart] - Telemetry widget displaying throttle and brake pedal inputs as animated percentage bars.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Throttle and brake are mutually exclusive in the simulator; the widget
// renders both channels simultaneously to highlight partial overlap states.
class ThrottleBrake extends StatefulWidget {
  const ThrottleBrake({this.initialDriverId = 'LEC', super.key});
  final String initialDriverId;

  @override
  State<ThrottleBrake> createState() => _ThrottleBrakeState();
}

class _ThrottleBrakeState extends State<ThrottleBrake> {
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
      widgetLabel: 'Throttle / Brake',
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
                  ? _SmallPedals(data: data, driverId: _driverId)
                  : _LargePedals(data: data, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallPedals extends StatelessWidget {
  const _SmallPedals({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PEDALS', driverId: driverId),
        const Spacer(),
        _PedalRow(label: 'THR', value: data.throttle, color: AppColors.green, barHeight: 8),
        const SizedBox(height: 10),
        _PedalRow(label: 'BRK', value: data.brake, color: AppColors.red, barHeight: 8),
        const Spacer(),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargePedals extends StatelessWidget {
  const _LargePedals({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PEDALS', driverId: driverId),
        const Spacer(),
        _PedalBlock(label: 'THROTTLE', value: data.throttle, color: AppColors.green),
        const SizedBox(height: 16),
        _PedalBlock(label: 'BRAKE', value: data.brake, color: AppColors.red),
        const Spacer(),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Compact single-line pedal: label | bar | value
class _PedalRow extends StatelessWidget {
  const _PedalRow({required this.label, required this.value, required this.color, required this.barHeight});
  final String label;
  final double value;
  final Color color;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
        ),
        Expanded(
          child: TelemetryBar(
            fraction: value,
            color: color,
            height: barHeight,
            trackColor: color.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value * 100),
            duration: const Duration(milliseconds: 220),
            builder: (_, v, _) => Text(
              '${v.toInt()}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(color: color).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width pedal block with label + percentage above a tall bar
class _PedalBlock extends StatelessWidget {
  const _PedalBlock({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9, letterSpacing: 0.5)),
            const Spacer(),
            SizedBox(
              width: 52,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: value * 100),
                duration: const Duration(milliseconds: 220),
                builder: (_, v, _) => Text(
                  '${v.toInt()}%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold(color: color).copyWith(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TelemetryBar(
          fraction: value,
          color: color,
          height: 12,
          trackColor: color.withValues(alpha: 0.10),
          radius: 3,
        ),
      ],
    );
  }
}
