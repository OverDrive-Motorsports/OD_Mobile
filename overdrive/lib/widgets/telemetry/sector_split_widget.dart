import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

class SectorSplitWidget extends StatefulWidget {
  const SectorSplitWidget({this.initialDriverId = 'VER', super.key});

  final String initialDriverId;

  @override
  State<SectorSplitWidget> createState() => _SectorSplitWidgetState();
}

class _SectorSplitWidgetState extends State<SectorSplitWidget> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  String _fmt(double? t) {
    if (t == null) return '—';
    final s = t.floor();
    final ms = ((t % 1) * 1000).toInt();
    return '$s.${ms.toString().padLeft(3, '0')}';
  }

  String _fmtDelta(double? actual, double best) {
    if (actual == null) return '';
    final delta = actual - best;
    final sign = delta < 0 ? '' : '+';
    return '$sign${delta.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Sector Split',
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
            final scale = (w / 160).clamp(0.6, 1.6);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SECTORS',
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Expanded(
                          child: _SectorBox(
                            label: 'S${i + 1}',
                            time: data.sectorTimes[i],
                            best: data.bestSectorTimes[i],
                            delta: _fmtDelta(
                              data.sectorTimes[i],
                              data.bestSectorTimes[i],
                            ),
                            formatted: _fmt(data.sectorTimes[i]),
                            scale: scale,
                          ),
                        ),
                        if (i < 2) SizedBox(width: 6 * scale),
                      ],
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

class _SectorBox extends StatelessWidget {
  const _SectorBox({
    required this.label,
    required this.time,
    required this.best,
    required this.delta,
    required this.formatted,
    required this.scale,
  });

  final String label;
  final double? time;
  final double best;
  final String delta;
  final String formatted;
  final double scale;

  Color get _bgColor {
    if (time == null) return AppColors.surface;
    final d = time! - best;
    if (d < -0.01) return AppColors.gold.withValues(alpha: 0.2);
    if (d < 0.05) return AppColors.green.withValues(alpha: 0.15);
    return AppColors.red.withValues(alpha: 0.15);
  }

  Color get _borderColor {
    if (time == null) return AppColors.border;
    final d = time! - best;
    if (d < -0.01) return AppColors.gold.withValues(alpha: 0.7);
    if (d < 0.05) return AppColors.green.withValues(alpha: 0.6);
    return AppColors.red.withValues(alpha: 0.6);
  }

  Color get _textColor {
    if (time == null) return AppColors.textMuted;
    final d = time! - best;
    if (d < -0.01) return AppColors.gold;
    if (d < 0.05) return AppColors.green;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 9 * scale),
          ),
          SizedBox(height: 4 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatted,
              style: AppTextStyles.bodyBold(color: _textColor)
                  .copyWith(fontSize: 12 * scale),
              textAlign: TextAlign.center,
            ),
          ),
          if (delta.isNotEmpty) ...[
            SizedBox(height: 2 * scale),
            Text(
              delta,
              style: AppTextStyles.label(color: _textColor)
                  .copyWith(fontSize: 9 * scale),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
