import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class ThrottleBrakeWidget extends StatefulWidget {
  const ThrottleBrakeWidget({this.initialDriverId = 'LEC', super.key});

  final String initialDriverId;

  @override
  State<ThrottleBrakeWidget> createState() => _ThrottleBrakeWidgetState();
}

class _ThrottleBrakeWidgetState extends State<ThrottleBrakeWidget> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Throttle / Brake',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(),
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
                      'PEDALS',
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
                _PedalBar(
                  label: 'THR',
                  value: data.throttle,
                  color: AppColors.green,
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _PedalBar(
                  label: 'BRK',
                  value: data.brake,
                  color: AppColors.red,
                  scale: scale,
                ),
                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PedalBar extends StatelessWidget {
  const _PedalBar({
    required this.label,
    required this.value,
    required this.color,
    required this.scale,
  });

  final String label;
  final double value;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32 * scale,
          child: Text(
            label,
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 9.5 * scale),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            builder: (context, fraction, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 16 * scale,
                child: Stack(
                  children: [
                    Container(color: color.withValues(alpha: 0.15)),
                    FractionallySizedBox(
                      widthFactor: fraction.clamp(0.0, 1.0),
                      alignment: Alignment.centerLeft,
                      child: Container(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        SizedBox(
          width: 32 * scale,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value * 100),
            duration: const Duration(milliseconds: 220),
            builder: (context, pct, _) => Text(
              '${pct.toInt()}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(color: color).copyWith(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
