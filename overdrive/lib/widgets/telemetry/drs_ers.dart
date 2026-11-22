/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [drs_ers.dart] - Telemetry widget showing DRS activation state and ERS charge level with mode-aware colour coding.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Maps ERS operating mode to its accent colour: gold for Deploy, blue for Harvest, muted otherwise.
Color _ersColor(String mode) => switch (mode) {
  'Deploy' => AppColors.gold,
  'Harvest' => const Color(0xFF60A5FA),
  _ => AppColors.textMuted,
};

class DrsErs extends StatefulWidget {
  const DrsErs({this.initialDriverId = 'NOR', super.key});
  final String initialDriverId;

  @override
  State<DrsErs> createState() => _DrsErsState();
}

class _DrsErsState extends State<DrsErs> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  void _showMenu(BuildContext context) {
    final actions = TelemetryItemActions.maybeOf(context);
    showTelemetryWidgetMenu(
      context,
      widgetLabel: 'DRS & ERS',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final drsColor = data.drs
        ? AppColors.green
        : AppColors.textMuted.withValues(alpha: 0.45);
    final ersColor = _ersColor(data.ersMode);

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallDrs(
                      data: data,
                      driverId: _driverId,
                      drsColor: drsColor,
                      ersColor: ersColor,
                    )
                  : _LargeDrs(
                      data: data,
                      driverId: _driverId,
                      drsColor: drsColor,
                      ersColor: ersColor,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallDrs extends StatelessWidget {
  const _SmallDrs({
    required this.data,
    required this.driverId,
    required this.drsColor,
    required this.ersColor,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color drsColor;
  final Color ersColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DRS / ERS', driverId: driverId),
        const SizedBox(height: 8),
        // DRS badge — full width, stable
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: drsColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: drsColor.withValues(alpha: 0.50)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: drsColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                data.drs ? 'DRS OPEN' : 'DRS CLOSED',
                style: AppTextStyles.label(
                  color: drsColor,
                ).copyWith(fontSize: 11, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
        const Spacer(),
        // ERS bar
        Row(
          children: [
            Text(
              data.ersMode.toUpperCase(),
              style: AppTextStyles.caption(
                color: ersColor,
              ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            SizedBox(
              width: 36,
              child: Text(
                '${(data.ersLevel * 100).toInt()}%',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption(
                  color: ersColor,
                ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(
          fraction: data.ersLevel,
          color: ersColor,
          trackColor: ersColor.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeDrs extends StatelessWidget {
  const _LargeDrs({
    required this.data,
    required this.driverId,
    required this.drsColor,
    required this.ersColor,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color drsColor;
  final Color ersColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DRS / ERS', driverId: driverId),
        const SizedBox(height: 10),
        // DRS badge — large
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: drsColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: drsColor.withValues(alpha: 0.50)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: drsColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.drs ? 'DRS OPEN' : 'DRS CLOSED',
                style: AppTextStyles.bodyBold(
                  color: drsColor,
                ).copyWith(fontSize: 15, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const Spacer(),
        // ERS block
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ERS',
                    style: AppTextStyles.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.ersMode.toUpperCase(),
                    style: AppTextStyles.caption(
                      color: ersColor,
                    ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(data.ersLevel * 100).toInt()}%',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyBold(
                        color: ersColor,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TelemetryBar(
                fraction: data.ersLevel,
                color: ersColor,
                height: 5,
                trackColor: ersColor.withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
