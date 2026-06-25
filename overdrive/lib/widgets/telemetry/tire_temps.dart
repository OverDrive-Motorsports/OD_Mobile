import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class TireTemps extends StatefulWidget {
  const TireTemps({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<TireTemps> createState() => _TireTempsState();
}

class _TireTempsState extends State<TireTemps> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final temps = data.tyreTemp;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Tyre Temps',
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
            final scale = (w / 320).clamp(0.5, 1.4);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TYRES',
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
                  child: GridView.count(
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.0,
                    crossAxisSpacing: 6 * scale,
                    mainAxisSpacing: 6 * scale,
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    children: [
                      _TireBox(
                        label: 'FL',
                        temp: temps['fl'] ?? 90,
                        scale: scale,
                      ),
                      _TireBox(
                        label: 'FR',
                        temp: temps['fr'] ?? 90,
                        scale: scale,
                      ),
                      _TireBox(
                        label: 'RL',
                        temp: temps['rl'] ?? 90,
                        scale: scale,
                      ),
                      _TireBox(
                        label: 'RR',
                        temp: temps['rr'] ?? 90,
                        scale: scale,
                      ),
                    ],
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

class _TireBox extends StatelessWidget {
  const _TireBox({
    required this.label,
    required this.temp,
    required this.scale,
  });

  final String label;
  final double temp;
  final double scale;

  static Color _tempColor(double t) {
    if (t > 115) return AppColors.red;
    if (t > 100) return const Color(0xFFFF8C00);
    if (t >= 80) return AppColors.green;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final color = _tempColor(temp);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 9 * scale),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: temp),
            duration: const Duration(milliseconds: 400),
            builder: (context, t, _) => Text(
              '${t.toInt()}°',
              style: AppTextStyles.bodyBold(color: color)
                  .copyWith(fontSize: 14 * scale),
            ),
          ),
        ],
      ),
    );
  }
}
