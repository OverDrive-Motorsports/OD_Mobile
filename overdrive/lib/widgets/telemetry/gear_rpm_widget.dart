import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class GearRpmWidget extends StatefulWidget {
  const GearRpmWidget({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<GearRpmWidget> createState() => _GearRpmWidgetState();
}

class _GearRpmWidgetState extends State<GearRpmWidget> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  Color _rpmColor(double fraction) {
    if (fraction >= 0.85) return AppColors.red;
    if (fraction >= 0.65) return AppColors.gold;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final rpmFraction = (data.rpm / 15000).clamp(0.0, 1.0);
    final rpmColor = _rpmColor(rpmFraction);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Gear & RPM',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(
          accentColor: rpmFraction >= 0.85 ? AppColors.red : null,
        ),
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final scale = (w / 160).clamp(0.6, 1.6);
            final gearSize = 68.0 * scale;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GEAR',
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
                      tween: Tween<double>(end: data.gear.toDouble()),
                      duration: const Duration(milliseconds: 150),
                      builder: (context, value, _) => Text(
                        value.round().toString(),
                        style: AppTextStyles.display(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: gearSize, letterSpacing: -2),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'RPM',
                      style: AppTextStyles.label(color: AppColors.textMuted)
                          .copyWith(fontSize: 10 * scale),
                    ),
                    const Spacer(),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.label(color: rpmColor)
                          .copyWith(fontSize: 10 * scale),
                      child: Text('${data.rpm}'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: rpmFraction),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, fraction, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      child: Stack(
                        children: [
                          Container(color: AppColors.surface),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: rpmColor,
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
