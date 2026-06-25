import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class PitStrategy extends StatefulWidget {
  const PitStrategy({this.initialDriverId = 'LEC', super.key});

  final String initialDriverId;

  @override
  State<PitStrategy> createState() => _PitStrategyState();
}

class _PitStrategyState extends State<PitStrategy> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  Color _compoundColor(String compound) => switch (compound) {
        'Soft' => AppColors.red,
        'Medium' => const Color(0xFFFFD700),
        'Hard' => AppColors.white,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final compoundColor = _compoundColor(data.tyreCompound);
    final accentColor = data.pitWindowOpen ? AppColors.green : AppColors.gold;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Pit Strategy',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: accentColor),
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
                      'PIT STRATEGY',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44 * scale,
                      height: 44 * scale,
                      decoration: BoxDecoration(
                        color: compoundColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: compoundColor.withValues(alpha: 0.8),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data.tyreCompound[0],
                        style: AppTextStyles.display(color: compoundColor)
                            .copyWith(fontSize: 20 * scale),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.tyreCompound,
                            style: AppTextStyles.bodyBold(
                              color: compoundColor,
                            ).copyWith(fontSize: 13 * scale),
                          ),
                          Text(
                            '${data.tyreAge} laps',
                            style: AppTextStyles.caption(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 11 * scale),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        data.pitWindowOpen
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        size: 13 * scale,
                        color: accentColor,
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        data.pitWindowOpen ? 'WINDOW OPEN' : 'NO PIT',
                        style: AppTextStyles.label(color: accentColor)
                            .copyWith(fontSize: 10 * scale),
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
