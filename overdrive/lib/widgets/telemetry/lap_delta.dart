/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [lap_delta.dart] - Telemetry widget displaying current lap time, best lap, and delta against the driver's personal best.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Formats a raw seconds value into M:SS.mmm — used for both current and best lap displays.
String _fmtTime(double seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).floor();
  final ms = ((seconds % 1) * 1000).toInt();
  return '$m:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
}

class LapDelta extends StatefulWidget {
  const LapDelta({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<LapDelta> createState() => _LapDeltaState();
}

class _LapDeltaState extends State<LapDelta> {
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
      widgetLabel: 'Lap Delta',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final delta = data.currentLapTime - data.bestLapTime;
    final deltaColor = delta < 0 ? AppColors.green : AppColors.red;
    final lapProgress = (data.currentLapTime / data.bestLapTime).clamp(
      0.0,
      1.0,
    );

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
                  ? _SmallLap(
                      data: data,
                      driverId: _driverId,
                      delta: delta,
                      deltaColor: deltaColor,
                      lapProgress: lapProgress,
                    )
                  : _LargeLap(
                      data: data,
                      driverId: _driverId,
                      delta: delta,
                      deltaColor: deltaColor,
                      lapProgress: lapProgress,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallLap extends StatelessWidget {
  const _SmallLap({
    required this.data,
    required this.driverId,
    required this.delta,
    required this.deltaColor,
    required this.lapProgress,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final double delta;
  final Color deltaColor;
  final double lapProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'LAP', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.currentLapTime),
              duration: const Duration(milliseconds: 200),
              builder: (_, t, _) => Text(
                _fmtTime(t),
                style: AppTextStyles.display(color: AppColors.textPrimary)
                    .copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text(
              _fmtTime(data.bestLapTime),
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 9),
            ),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: delta),
              duration: const Duration(milliseconds: 250),
              builder: (_, d, _) {
                final s = d >= 0 ? '+' : '';
                return Text(
                  '$s${d.toStringAsFixed(3)}s',
                  style: AppTextStyles.caption(
                    color: deltaColor,
                  ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(fraction: lapProgress, color: deltaColor),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeLap extends StatelessWidget {
  const _LargeLap({
    required this.data,
    required this.driverId,
    required this.delta,
    required this.deltaColor,
    required this.lapProgress,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final double delta;
  final Color deltaColor;
  final double lapProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'LAP', driverId: driverId),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current lap time — large
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: data.currentLapTime),
                duration: const Duration(milliseconds: 200),
                builder: (_, t, _) => Text(
                  _fmtTime(t),
                  style: AppTextStyles.display(color: AppColors.textPrimary)
                      .copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              // Best + delta row
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEST',
                        style: AppTextStyles.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 8),
                      ),
                      Text(
                        _fmtTime(data.bestLapTime),
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELTA',
                        style: AppTextStyles.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 8),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: delta),
                        duration: const Duration(milliseconds: 250),
                        builder: (_, d, _) {
                          final s = d >= 0 ? '+' : '';
                          return Text(
                            '$s${d.toStringAsFixed(3)}s',
                            style: AppTextStyles.caption(color: deltaColor)
                                .copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'L${data.lapNumber}/${TelemetrySnapshot.totalLaps}',
                    style: AppTextStyles.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lap progress bar
        TelemetryBar(fraction: lapProgress, color: deltaColor),
      ],
    );
  }
}
