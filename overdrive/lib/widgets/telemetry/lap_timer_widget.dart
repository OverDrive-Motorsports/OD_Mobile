import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_widget_style.dart';

class LapTimerWidget extends StatefulWidget {
  const LapTimerWidget({super.key});

  @override
  State<LapTimerWidget> createState() => _LapTimerWidgetState();
}

class _LapTimerWidgetState extends State<LapTimerWidget> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration? _bestLap = const Duration(minutes: 1, seconds: 42, milliseconds: 184);

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_stopwatch.isRunning) {
        setState(() => _elapsed = _stopwatch.elapsed);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRunning() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
      _elapsed = _stopwatch.elapsed;
    });
  }

  void _recordLap() {
    setState(() {
      if (_bestLap == null || _elapsed < _bestLap!) {
        _bestLap = _elapsed;
      }
      _stopwatch
        ..reset()
        ..start();
      _elapsed = Duration.zero;
    });
  }

  String _formatLap(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = duration.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }

  String _formatDelta(Duration duration) {
    final millis = duration.inMilliseconds.abs();
    final seconds = millis ~/ 1000;
    final remainder = (millis % 1000).toString().padLeft(3, '0');
    final prefix = duration.isNegative ? '-' : '+';
    return '$prefix$seconds.$remainder s';
  }

  @override
  Widget build(BuildContext context) {
    final bestLap = _bestLap;
    final delta = bestLap == null ? Duration.zero : _elapsed - bestLap;
    final deltaColor = delta.isNegative ? AppColors.green : AppColors.red;

    return Container(
      decoration: telemetryDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAP TIME', style: AppTextStyles.label(color: AppColors.textMuted)),
          const Spacer(),
          Text(
            _formatLap(_elapsed),
            style: AppTextStyles.display(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'BEST ${bestLap == null ? '--:--.---' : _formatLap(bestLap)}',
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                _formatDelta(delta),
                style: AppTextStyles.bodyBold(color: deltaColor),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleRunning,
                  child: Text(
                    _stopwatch.isRunning ? 'PAUSE' : 'PLAY',
                    style: AppTextStyles.label(color: AppColors.black),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _recordLap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Text(
                  'TOUR',
                  style: AppTextStyles.label(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
