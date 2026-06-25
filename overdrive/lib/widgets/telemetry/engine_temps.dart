import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class EngineTemps extends StatefulWidget {
  const EngineTemps({this.initialDriverId = 'NOR', super.key});

  final String initialDriverId;

  @override
  State<EngineTemps> createState() => _EngineTempsState();
}

class _EngineTempsState extends State<EngineTemps> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  Color _modeColor(String mode) => switch (mode) {
        'Party' => AppColors.red,
        'Standard' => AppColors.gold,
        'Conservation' => AppColors.green,
        _ => AppColors.textMuted,
      };

  Color _tempColor(double temp, double min, double max) {
    final fraction = ((temp - min) / (max - min)).clamp(0.0, 1.0);
    if (fraction > 0.8) return AppColors.red;
    if (fraction > 0.55) return const Color(0xFFFF8C00);
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final modeColor = _modeColor(data.engineMode);
    final waterColor = _tempColor(data.waterTemp, 82, 108);
    final oilColor = _tempColor(data.oilTemp, 98, 132);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Engine',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: modeColor),
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
                      'ENGINE',
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
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                      vertical: 6 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: modeColor.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      data.engineMode.toUpperCase(),
                      style: AppTextStyles.bodyBold(color: modeColor)
                          .copyWith(fontSize: 13 * scale),
                    ),
                  ),
                ),
                const Spacer(),
                _TempBar(
                  label: 'H₂O',
                  temp: data.waterTemp,
                  min: 82,
                  max: 108,
                  color: waterColor,
                  scale: scale,
                ),
                SizedBox(height: 8 * scale),
                _TempBar(
                  label: 'OIL',
                  temp: data.oilTemp,
                  min: 98,
                  max: 132,
                  color: oilColor,
                  scale: scale,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  const _TempBar({
    required this.label,
    required this.temp,
    required this.min,
    required this.max,
    required this.color,
    required this.scale,
  });

  final String label;
  final double temp;
  final double min;
  final double max;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fraction = ((temp - min) / (max - min)).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 28 * scale,
          child: Text(
            label,
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 9 * scale),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: fraction),
            duration: const Duration(milliseconds: 350),
            builder: (context, f, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8 * scale,
                child: Stack(
                  children: [
                    Container(color: AppColors.surface),
                    FractionallySizedBox(
                      widthFactor: f,
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        SizedBox(
          width: 36 * scale,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: temp),
            duration: const Duration(milliseconds: 350),
            builder: (context, t, _) => Text(
              '${t.toInt()}°',
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
