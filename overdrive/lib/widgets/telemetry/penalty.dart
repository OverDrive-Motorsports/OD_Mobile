/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [penalty.dart] - Telemetry widget displaying time penalties, track-limit warnings, and blue-flag status.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; tracks the selected driver and updates the penalty display reactively.
class Penalty extends StatefulWidget {
  const Penalty({this.initialDriverId = 'LEC', super.key});
  final String initialDriverId;

  @override
  State<Penalty> createState() => _PenaltyState();
}

class _PenaltyState extends State<Penalty> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(context, widgetLabel: 'Penalties',
            currentDriverId: _driverId,
            onDriverSelected: (id) => setState(() => _driverId = id),
            onReset: actions?.onReset, onRemove: actions?.onRemove);
      },
      child: TelemetryCard(
        child: LayoutBuilder(builder: (context, constraints) {
          final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
          return Padding(
            padding: const EdgeInsets.all(12),
            child: mode == TelemetryMode.small
                ? _SmallPenalty(data: data, driverId: _driverId)
                : _LargePenalty(data: data, driverId: _driverId),
          );
        }),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallPenalty extends StatelessWidget {
  const _SmallPenalty({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    final hasPenalty = data.penaltySeconds > 0;
    final penaltyColor = hasPenalty ? AppColors.red : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PÉNALITÉS', driverId: driverId),
        const Spacer(),
        // Time penalty — big number
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles.display(color: penaltyColor)
                  .copyWith(fontSize: 34, fontWeight: FontWeight.bold),
              child: Text(hasPenalty ? '+${data.penaltySeconds}' : '—'),
            ),
            if (hasPenalty) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('s',
                    style: AppTextStyles.body(color: penaltyColor).copyWith(fontSize: 14)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Track limit warnings dots
        _WarningDots(warnings: data.trackLimitWarnings, max: 3),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargePenalty extends StatelessWidget {
  const _LargePenalty({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    final hasPenalty = data.penaltySeconds > 0;
    final penaltyColor = hasPenalty ? AppColors.red : AppColors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PÉNALITÉS', driverId: driverId),
        const SizedBox(height: 10),
        // Time penalty block
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEMPS',
                    style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: AppTextStyles.display(color: penaltyColor)
                          .copyWith(fontSize: 38, fontWeight: FontWeight.bold),
                      child: Text(hasPenalty ? '+${data.penaltySeconds}' : 'OK'),
                    ),
                    if (hasPenalty) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('s',
                            style: AppTextStyles.body(color: penaltyColor).copyWith(fontSize: 16)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Blue flag
            _FlagIndicator(
              label: 'BLEU',
              active: data.blueFlagWarning,
              color: AppColors.blue,
            ),
          ],
        ),
        const Spacer(),
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 8),
        // Track limits
        Row(
          children: [
            Text('LIMITES PISTE',
                style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
            const Spacer(),
            _WarningDots(warnings: data.trackLimitWarnings, max: 3),
            const SizedBox(width: 5),
            Text('${data.trackLimitWarnings}/3',
                style: AppTextStyles.caption(
                  color: data.trackLimitWarnings >= 3 ? AppColors.red
                      : data.trackLimitWarnings >= 2 ? const Color(0xFFFF8C00)
                      : AppColors.textMuted,
                ).copyWith(fontSize: 9, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        if (data.trackLimitWarnings >= 2)
          Text(
            data.trackLimitWarnings >= 3
                ? '⚠ Pénalité automatique imminente'
                : '⚠ Prochain avertissement = pénalité',
            style: AppTextStyles.caption(color: const Color(0xFFFF8C00))
                .copyWith(fontSize: 8),
          ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

// Renders up to `max` coloured dots representing track-limit warnings; colour escalates at 2 and 3 warnings.
class _WarningDots extends StatelessWidget {
  const _WarningDots({required this.warnings, required this.max});
  final int warnings;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final active = i < warnings;
        final color = warnings >= 3 ? AppColors.red
            : warnings >= 2 ? const Color(0xFFFF8C00)
            : AppColors.gold;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : AppColors.surface.withValues(alpha: 0.80),
            border: Border.all(color: active ? color.withValues(alpha: 0.50) : AppColors.border),
          ),
        );
      }),
    );
  }
}

// Animated flag badge; pulses with full colour when active and fades to muted when inactive.
class _FlagIndicator extends StatelessWidget {
  const _FlagIndicator({required this.label, required this.active, required this.color});
  final String label;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.20) : AppColors.surface.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.70) : AppColors.border,
            ),
          ),
          child: Icon(
            Icons.flag_rounded,
            size: 14,
            color: active ? color : AppColors.textMuted.withValues(alpha: 0.40),
          ),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: AppTextStyles.caption(color: active ? color : AppColors.textMuted)
                .copyWith(fontSize: 7)),
      ],
    );
  }
}
