import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class StandingsWidget extends StatelessWidget {
  const StandingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<TelemetrySimulator>();

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Standings',
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
            final scale = (w / 320).clamp(0.55, 1.5);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STANDINGS',
                  style: AppTextStyles.label(color: AppColors.textMuted)
                      .copyWith(fontSize: 10 * scale),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final driver in TelemetryMockData.drivers)
                        _StandingRow(
                          driver: driver,
                          snapshot: sim.getSnapshot(driver['id'] as String),
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

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.driver,
    required this.snapshot,
    required this.scale,
  });

  final Map<String, dynamic> driver;
  final TelemetrySnapshot snapshot;
  final double scale;

  Color _teamColor(String team) => switch (team) {
        'Red Bull Racing' => const Color(0xFF3671C6),
        'Ferrari' => const Color(0xFFE8002D),
        'McLaren' => const Color(0xFFFF8000),
        _ => AppColors.gold,
      };

  @override
  Widget build(BuildContext context) {
    final tc = _teamColor(driver['team'] as String);
    final (trendIcon, trendColor) = switch (snapshot.trend) {
      'gaining' => (Icons.arrow_upward_rounded, AppColors.green),
      'losing' => (Icons.arrow_downward_rounded, AppColors.red),
      _ => (Icons.remove_rounded, AppColors.textMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: tc.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tc.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(
            'P${driver['position']}',
            style: AppTextStyles.bodyBold(color: tc)
                .copyWith(fontSize: 14 * scale),
          ),
          SizedBox(width: 10 * scale),
          Container(
            width: 4,
            height: 28 * scale,
            decoration: BoxDecoration(
              color: tc,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['name'] as String,
                  style: AppTextStyles.body(color: AppColors.textPrimary)
                      .copyWith(fontSize: 13 * scale),
                ),
                Text(
                  driver['team'] as String,
                  style: AppTextStyles.caption(color: AppColors.textMuted)
                      .copyWith(fontSize: 10 * scale),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                snapshot.gapToLeader,
                style: AppTextStyles.bodyBold(color: AppColors.textPrimary)
                    .copyWith(fontSize: 12 * scale),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, size: 11 * scale, color: trendColor),
                  SizedBox(width: 2 * scale),
                  Text(
                    '${snapshot.speed.toInt()}',
                    style: AppTextStyles.label(color: AppColors.textMuted)
                        .copyWith(fontSize: 9 * scale),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
