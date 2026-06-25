import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class FuelGauge extends StatefulWidget {
  const FuelGauge({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<FuelGauge> createState() => _FuelGaugeState();
}

class _FuelGaugeState extends State<FuelGauge> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  Color _fuelColor(double fraction) {
    if (fraction < 0.2) return AppColors.red;
    if (fraction < 0.4) return const Color(0xFFFF8C00);
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final fuelFraction = (data.fuelLoad / 110).clamp(0.0, 1.0);
    final fuelColor = _fuelColor(fuelFraction);
    final lapsLeft = data.fuelPerLap > 0
        ? (data.fuelLoad / data.fuelPerLap).floor()
        : 0;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Fuel Load',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: fuelColor),
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
                      'FUEL',
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
                      tween: Tween<double>(end: data.fuelLoad),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value.toStringAsFixed(1),
                            style: AppTextStyles.display(color: fuelColor)
                                .copyWith(
                              fontSize: 36 * scale,
                              letterSpacing: -1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 4 * scale,
                              left: 3 * scale,
                            ),
                            child: Text(
                              'kg',
                              style: AppTextStyles.caption(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 12 * scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${data.fuelPerLap.toStringAsFixed(2)} kg/lap',
                      style: AppTextStyles.caption(color: AppColors.textMuted)
                          .copyWith(fontSize: 10 * scale),
                    ),
                    const Spacer(),
                    Text(
                      '~$lapsLeft laps',
                      style: AppTextStyles.label(color: fuelColor)
                          .copyWith(fontSize: 10 * scale),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: fuelFraction),
                  duration: const Duration(milliseconds: 400),
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
                              duration: const Duration(milliseconds: 300),
                              color: fuelColor,
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
