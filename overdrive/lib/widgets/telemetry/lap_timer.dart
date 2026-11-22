/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_timer.dart - Interactive lap stopwatch widget with best-lap delta tracking.
 ##
 */

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../base/app_button.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Stateful lap timer that tracks elapsed time and compares against the best recorded lap.
class LapTimer extends StatefulWidget {
  const LapTimer({super.key});

  @override
  State<LapTimer> createState() => _LapTimerState();
}

class _LapTimerState extends State<LapTimer> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration? _bestLap = const Duration(
    minutes: 1,
    seconds: 42,
    milliseconds: 184,
  );

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_stopwatch.isRunning) setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRunning() {
    setState(() {
      _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start();
      _elapsed = _stopwatch.elapsed;
    });
  }

  void _recordLap() {
    setState(() {
      if (_bestLap == null || _elapsed < _bestLap!) _bestLap = _elapsed;
      _stopwatch
        ..reset()
        ..start();
      _elapsed = Duration.zero;
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$m:$s.$ms';
  }

  String _fmtDelta(Duration d) {
    final ms = d.inMilliseconds.abs();
    final s = ms ~/ 1000;
    final r = (ms % 1000).toString().padLeft(3, '0');
    return '${d.isNegative ? '-' : '+'}$s.$r s';
  }

  @override
  Widget build(BuildContext context) {
    final best = _bestLap;
    final delta = best == null ? Duration.zero : _elapsed - best;
    final deltaColor = delta.isNegative ? AppColors.green : AppColors.red;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Lap Timer',
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
              child: mode == TelemetryMode.small
                  ? _SmallTimer(
                      elapsed: _elapsed,
                      best: best,
                      delta: delta,
                      deltaColor: deltaColor,
                      fmt: _fmt,
                    )
                  : _LargeTimer(
                      elapsed: _elapsed,
                      best: best,
                      delta: delta,
                      deltaColor: deltaColor,
                      fmt: _fmt,
                      fmtDelta: _fmtDelta,
                      isRunning: _stopwatch.isRunning,
                      onToggle: _toggleRunning,
                      onLap: _recordLap,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

// Compact layout showing only the current elapsed time and best-lap reference.
class _SmallTimer extends StatelessWidget {
  const _SmallTimer({
    required this.elapsed,
    required this.best,
    required this.delta,
    required this.deltaColor,
    required this.fmt,
  });
  final Duration elapsed;
  final Duration? best;
  final Duration delta;
  final Color deltaColor;
  final String Function(Duration) fmt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TelemetryHeader(label: 'LAP TIMER'),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            fmt(elapsed),
            style: AppTextStyles.display(
              color: AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              best == null ? 'BEST --:--.---' : 'BEST ${fmt(best!)}',
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 9),
            ),
            const Spacer(),
            Text(
              best == null
                  ? ''
                  : (delta.isNegative
                        ? fmt(delta).replaceFirst('-', '-')
                        : '+${fmt(delta).substring(fmt(delta).indexOf(':') + 1)}'),
              style: AppTextStyles.caption(
                color: deltaColor,
              ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

// Full layout adding a delta progress bar and start/pause and lap action buttons.
class _LargeTimer extends StatelessWidget {
  const _LargeTimer({
    required this.elapsed,
    required this.best,
    required this.delta,
    required this.deltaColor,
    required this.fmt,
    required this.fmtDelta,
    required this.isRunning,
    required this.onToggle,
    required this.onLap,
  });
  final Duration elapsed;
  final Duration? best;
  final Duration delta;
  final Color deltaColor;
  final String Function(Duration) fmt;
  final String Function(Duration) fmtDelta;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onLap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TelemetryHeader(label: 'LAP TIMER'),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            fmt(elapsed),
            style: AppTextStyles.display(
              color: AppColors.textPrimary,
            ).copyWith(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
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
                  best == null ? '--:--.---' : fmt(best!),
                  style: AppTextStyles.caption(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Spacer(),
            if (best != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Δ',
                    style: AppTextStyles.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 8),
                  ),
                  Text(
                    fmtDelta(delta),
                    style: AppTextStyles.bodyBold(
                      color: deltaColor,
                    ).copyWith(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        const Spacer(),
        TelemetryBar(
          fraction: best == null
              ? 0
              : (elapsed.inMilliseconds / best!.inMilliseconds).clamp(0, 1.5) /
                    1.5,
          color: deltaColor,
          trackColor: deltaColor.withValues(alpha: 0.10),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: isRunning ? 'PAUSE' : 'PLAY',
                onPressed: onToggle,
                fullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            AppButton(label: 'LAP', onPressed: onLap),
          ],
        ),
      ],
    );
  }
}
