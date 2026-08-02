/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [driver_snapshot.dart] - Telemetry widget showing live driver position, speed, gear, throttle and brake inputs.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; tracks the selected driver and adapts layout to the available tile size.
class DriverSnapshot extends StatefulWidget {
  const DriverSnapshot({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<DriverSnapshot> createState() => _DriverSnapshotState();
}

class _DriverSnapshotState extends State<DriverSnapshot> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final meta = TelemetryMockData.driverById(_driverId);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Driver Snapshot',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallDriver(data: data, meta: meta, driverId: _driverId)
                  : _LargeDriver(data: data, meta: meta, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallDriver extends StatelessWidget {
  const _SmallDriver({required this.data, required this.meta, required this.driverId});
  final TelemetrySnapshot data;
  final Map<String, dynamic> meta;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DRIVER', driverId: driverId),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'P${meta['position']}',
              style: AppTextStyles.display(color: AppColors.gold).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                meta['name'] as String,
                style: AppTextStyles.body(color: AppColors.textPrimary).copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(data.gapToLeader, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.speed),
              duration: const Duration(milliseconds: 220),
              builder: (_, v, _) => Text(
                '${v.toInt()} km/h',
                style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 10),
              ),
            ),
            const SizedBox(width: 6),
            Text('G${data.gear}', style: AppTextStyles.bodyBold(color: AppColors.gold).copyWith(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeDriver extends StatelessWidget {
  const _LargeDriver({required this.data, required this.meta, required this.driverId});
  final TelemetrySnapshot data;
  final Map<String, dynamic> meta;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DRIVER', driverId: driverId),
        const SizedBox(height: 10),
        // Driver badge row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.50)),
              ),
              alignment: Alignment.center,
              child: Text(driverId, style: AppTextStyles.label(color: AppColors.gold).copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('P${meta['position']}', style: AppTextStyles.bodyBold(color: AppColors.gold).copyWith(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meta['name'] as String,
                          style: AppTextStyles.body(color: AppColors.textPrimary).copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(meta['team'] as String,
                      style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        // Speed + gear
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.speed),
              duration: const Duration(milliseconds: 220),
              builder: (_, v, _) => Text(
                '${v.toInt()}',
                style: AppTextStyles.display(color: AppColors.textPrimary).copyWith(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4),
            Text('km/h', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 11)),
            const Spacer(),
            Text('G', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 11)),
            Text('${data.gear}', style: AppTextStyles.bodyBold(color: AppColors.gold).copyWith(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        // THR / BRK bars
        _InputRow(label: 'THR', value: data.throttle, color: AppColors.green),
        const SizedBox(height: 5),
        _InputRow(label: 'BRK', value: data.brake, color: AppColors.red),
        const SizedBox(height: 6),
        Text(data.gapToLeader, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

// Renders a labelled progress bar (throttle or brake) with a live percentage readout.
class _InputRow extends StatelessWidget {
  const _InputRow({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
        ),
        Expanded(child: TelemetryBar(fraction: value, color: color, trackColor: color.withValues(alpha: 0.10))),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value),
            duration: const Duration(milliseconds: 220),
            builder: (_, v, _) => Text(
              '${(v * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(color: color).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
