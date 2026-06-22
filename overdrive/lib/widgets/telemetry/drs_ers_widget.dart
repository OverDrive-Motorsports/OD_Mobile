import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class DrsErsWidget extends StatefulWidget {
  const DrsErsWidget({this.initialDriverId = 'NOR', super.key});

  final String initialDriverId;

  @override
  State<DrsErsWidget> createState() => _DrsErsWidgetState();
}

class _DrsErsWidgetState extends State<DrsErsWidget> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  Color _ersColor(String mode) => switch (mode) {
        'Deploy' => const Color(0xFFA855F7),
        'Harvest' => AppColors.blue,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final drsColor = data.drs ? AppColors.green : AppColors.textMuted;
    final ersBarColor = _ersColor(data.ersMode);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'DRS & ERS',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(
          accentColor: data.drs ? AppColors.green : AppColors.gold,
        ),
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
                      'DRS / ERS',
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
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 7 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: drsColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: drsColor.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 7 * scale,
                          height: 7 * scale,
                          decoration: BoxDecoration(
                            color: drsColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 7 * scale),
                        Text(
                          data.drs ? 'DRS OPEN' : 'DRS CLOSED',
                          style: AppTextStyles.bodyBold(color: drsColor)
                              .copyWith(fontSize: 12 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.label(color: ersBarColor)
                          .copyWith(fontSize: 10 * scale),
                      child: Text(data.ersMode.toUpperCase()),
                    ),
                    const Spacer(),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.caption(color: ersBarColor).copyWith(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                      child: Text('${(data.ersLevel * 100).toInt()}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: data.ersLevel),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, fraction, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8 * scale,
                      child: Stack(
                        children: [
                          Container(
                            color: ersBarColor.withValues(alpha: 0.15),
                          ),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: ersBarColor,
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
