import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class DriverSnapshot extends StatefulWidget {
  const DriverSnapshot({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<DriverSnapshot> createState() => _DriverSnapshotState();
}

class _DriverSnapshotState extends State<DriverSnapshot> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final driverMeta = TelemetryMockData.driverById(_driverId);
    final tc = teamColor(driverMeta['team'] as String);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Driver Snapshot',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: Container(
        decoration: telemetryDecoration(accentColor: tc),
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final scale = (w / 320).clamp(0.55, 1.5);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52 * scale,
                  height: 52 * scale,
                  decoration: BoxDecoration(
                    color: tc.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: tc.withValues(alpha: 0.8), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _driverId,
                    style: AppTextStyles.display(color: AppColors.white)
                        .copyWith(fontSize: 13 * scale),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            'P${driverMeta['position']}',
                            style: AppTextStyles.display(color: tc)
                                .copyWith(fontSize: 16 * scale),
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Text(
                              driverMeta['name'] as String,
                              style: AppTextStyles.bodyBold(
                                color: AppColors.textPrimary,
                              ).copyWith(fontSize: 13 * scale),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      Row(
                        children: [
                          _MiniBar(
                            label: 'THR',
                            value: data.throttle,
                            color: AppColors.green,
                            scale: scale,
                          ),
                          SizedBox(width: 8 * scale),
                          _MiniBar(
                            label: 'BRK',
                            value: data.brake,
                            color: AppColors.red,
                            scale: scale,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12 * scale),
                SizedBox(
                  height: h,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: data.speed),
                          duration: const Duration(milliseconds: 250),
                          builder: (context, v, _) => Text(
                            '${v.toInt()} km/h',
                            style: AppTextStyles.bodyBold(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 14 * scale),
                          ),
                        ),
                        Text(
                          'G${data.gear}',
                          style: AppTextStyles.display(color: AppColors.gold)
                              .copyWith(fontSize: 18 * scale),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          data.gapToLeader,
                          style: AppTextStyles.caption(
                            color: AppColors.textMuted,
                          ).copyWith(fontSize: 10 * scale),
                        ),
                      ],
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

class _MiniBar extends StatelessWidget {
  const _MiniBar({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label(color: AppColors.textMuted)
              .copyWith(fontSize: 8 * scale),
        ),
        const SizedBox(height: 2),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value),
          duration: const Duration(milliseconds: 220),
          builder: (context, fraction, _) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: 46 * scale,
              height: 5 * scale,
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
      ],
    );
  }
}
