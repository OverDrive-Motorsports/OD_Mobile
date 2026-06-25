import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class Weather extends StatelessWidget {
  const Weather({super.key});

  @override
  Widget build(BuildContext context) {
    final conditions = context.watch<TelemetrySimulator>().getTrackConditions();
    final isDamp = conditions.conditions == 'Damp';
    final condColor = isDamp ? AppColors.blue : AppColors.gold;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Weather',
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: condColor),
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
                      'WEATHER',
                      style: AppTextStyles.label(color: AppColors.textMuted)
                          .copyWith(fontSize: 10 * scale),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 2 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: condColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: condColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        conditions.conditions.toUpperCase(),
                        style: AppTextStyles.label(color: condColor)
                            .copyWith(fontSize: 9 * scale),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _WeatherStat(
                      icon: Icons.thermostat_rounded,
                      label: 'Track',
                      value:
                          '${conditions.trackTemp.toStringAsFixed(1)}°C',
                      color: AppColors.red,
                      scale: scale,
                    ),
                    SizedBox(width: 10 * scale),
                    _WeatherStat(
                      icon: Icons.air_rounded,
                      label: 'Air',
                      value: '${conditions.airTemp.toStringAsFixed(1)}°C',
                      color: AppColors.blue,
                      scale: scale,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _WeatherStat(
                      icon: Icons.water_drop_outlined,
                      label: 'Humid.',
                      value: '${conditions.humidity.toInt()}%',
                      color: AppColors.textSecondary,
                      scale: scale,
                    ),
                    SizedBox(width: 10 * scale),
                    _WeatherStat(
                      icon: Icons.wind_power_rounded,
                      label: 'Wind',
                      value:
                          '${conditions.windSpeed.toStringAsFixed(1)} km/h',
                      color: AppColors.textSecondary,
                      scale: scale,
                    ),
                  ],
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

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 13 * scale, color: color),
          SizedBox(width: 4 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label(color: AppColors.textMuted)
                      .copyWith(fontSize: 8 * scale),
                ),
                Text(
                  value,
                  style: AppTextStyles.body(color: AppColors.textPrimary)
                      .copyWith(fontSize: 12 * scale),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
