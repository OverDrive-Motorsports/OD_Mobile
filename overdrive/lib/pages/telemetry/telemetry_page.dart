import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/telemetry/lap_timer_widget.dart';
import '../../widgets/telemetry/rpm_bar_widget.dart';
import '../../widgets/telemetry/speed_gauge_widget.dart';
import 'grid/grid_board.dart';
import 'grid/grid_item.dart';

class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'TELEMETRIE',
          style: AppTextStyles.label(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridBoard(
              cols: 8,
              rows: 10,
              cellSize: 80,
              gap: 6,
              items: [
                GridItem(
                  id: 'speed',
                  col: 0,
                  row: 0,
                  colSpan: 2,
                  rowSpan: 2,
                  child: const SpeedGaugeWidget(),
                ),
                GridItem(
                  id: 'rpm',
                  col: 2,
                  row: 0,
                  colSpan: 4,
                  rowSpan: 1,
                  child: const RpmBarWidget(),
                ),
                GridItem(
                  id: 'lap',
                  col: 2,
                  row: 1,
                  colSpan: 2,
                  rowSpan: 2,
                  child: const LapTimerWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
