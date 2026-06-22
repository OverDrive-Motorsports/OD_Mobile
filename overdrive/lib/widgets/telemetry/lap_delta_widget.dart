import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class LapDeltaWidget extends StatefulWidget {
  const LapDeltaWidget({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<LapDeltaWidget> createState() => _LapDeltaWidgetState();
}

class _LapDeltaWidgetState extends State<LapDeltaWidget> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).floor();
    final ms = ((seconds % 1) * 1000).toInt();
    return '$m:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  }

  String _formatDelta(double delta) {
    final sign = delta < 0 ? '-' : '+';
    return '$sign${delta.abs().toStringAsFixed(3)}s';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final delta = data.currentLapTime - data.bestLapTime;
    final deltaColor = delta < 0 ? AppColors.green : AppColors.red;
    final lapProgress = (data.currentLapTime / data.bestLapTime).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Lap Delta',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: deltaColor),
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
                      'LAP',
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
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: data.currentLapTime),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, t, _) => Text(
                    _formatTime(t),
                    style: AppTextStyles.display(color: AppColors.textPrimary)
                        .copyWith(fontSize: 20 * scale, letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(data.bestLapTime),
                      style: AppTextStyles.caption(color: AppColors.textMuted)
                          .copyWith(fontSize: 11 * scale),
                    ),
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: delta),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, d, _) => AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.bodyBold(color: deltaColor)
                            .copyWith(fontSize: 13 * scale),
                        child: Text(_formatDelta(d)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: lapProgress),
                  duration: const Duration(milliseconds: 220),
                  builder: (context, fraction, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(color: AppColors.surface),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: deltaColor,
                            ),
                          ),
                        ],
                      ),
                    ),
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
