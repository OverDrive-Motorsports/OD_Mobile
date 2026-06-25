import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

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

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Speedometer',
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
            final scale = (w / 320).clamp(0.55, 1.6);
            final bigSize = 52.0 * scale;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SPEED',
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
                Expanded(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: data.speed),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value.toInt().toString(),
                            style: AppTextStyles.display(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontSize: bigSize,
                              letterSpacing: -1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 6 * scale,
                              left: 4 * scale,
                            ),
                            child: Text(
                              'km/h',
                              style: AppTextStyles.caption(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 13 * scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: data.speed / 340),
                  duration: const Duration(milliseconds: 260),
                  builder: (context, fraction, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(color: AppColors.surface),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            alignment: Alignment.centerLeft,
                            child: Container(color: AppColors.gold),
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
