/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [pit_strategy.dart] - Telemetry widget showing the current tyre compound, age, wear, and pit-window status.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

// Returns the F1 canonical colour for each tyre compound (Soft/Medium/Hard only; others fall back to muted).
Color _compoundColor(String c) => switch (c) {
      'Soft' => AppColors.red,
      'Medium' => const Color(0xFFFFD700),
      'Hard' => AppColors.white,
      _ => AppColors.textMuted,
    };

// Colours the tyre-age fraction against a 50-lap maximum: red above 70%, orange above 45%, green otherwise.
Color _ageColor(double fraction) {
  if (fraction > 0.70) return AppColors.red;
  if (fraction > 0.45) return const Color(0xFFFF8C00);
  return AppColors.green;
}

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; normalises tyre age against 50 laps and pre-computes colours before delegating layout.
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

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final cc = _compoundColor(data.tyreCompound);
    const maxAge = 50.0;
    final ageFraction = (data.tyreAge / maxAge).clamp(0.0, 1.0);
    final ac = _ageColor(ageFraction);

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
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallPit(data: data, driverId: _driverId, cc: cc, ageFraction: ageFraction, ac: ac)
                  : _LargePit(data: data, driverId: _driverId, cc: cc, ageFraction: ageFraction, ac: ac),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallPit extends StatelessWidget {
  const _SmallPit({required this.data, required this.driverId, required this.cc, required this.ageFraction, required this.ac});
  final TelemetrySnapshot data;
  final String driverId;
  final Color cc;
  final double ageFraction;
  final Color ac;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PIT', driverId: driverId),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Big compound letter
            Text(
              data.tyreCompound[0],
              style: AppTextStyles.display(color: cc).copyWith(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.tyreCompound, style: AppTextStyles.body(color: cc).copyWith(fontSize: 11)),
                  Text('${data.tyreAge} laps', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
                ],
              ),
            ),
            // Pit window dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.pitWindowOpen ? AppColors.green : AppColors.textMuted.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.pitWindowOpen ? 'OPEN' : 'CLOSED',
                  style: AppTextStyles.caption(color: data.pitWindowOpen ? AppColors.green : AppColors.textMuted)
                      .copyWith(fontSize: 8),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TelemetryBar(fraction: ageFraction, color: ac, trackColor: ac.withValues(alpha: 0.10)),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargePit extends StatelessWidget {
  const _LargePit({required this.data, required this.driverId, required this.cc, required this.ageFraction, required this.ac});
  final TelemetrySnapshot data;
  final String driverId;
  final Color cc;
  final double ageFraction;
  final Color ac;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'PIT STRATEGY', driverId: driverId),
        const SizedBox(height: 12),
        // Compound row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cc.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: cc.withValues(alpha: 0.55), width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                data.tyreCompound[0],
                style: AppTextStyles.display(color: cc).copyWith(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.tyreCompound, style: AppTextStyles.bodyBold(color: cc).copyWith(fontSize: 16)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text('${data.tyreAge}', style: AppTextStyles.display(color: ac).copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('laps', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            // Pit window — small inline indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.pitWindowOpen ? AppColors.green : AppColors.textMuted.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PIT',
                      style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.pitWindowOpen ? 'OPEN' : 'CLOSED',
                  style: AppTextStyles.bodyBold(color: data.pitWindowOpen ? AppColors.green : AppColors.textMuted)
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        // Tyre wear label
        Row(
          children: [
            Text('USURE', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
            const Spacer(),
            Text('${(ageFraction * 100).toInt()}%', style: AppTextStyles.caption(color: ac).copyWith(fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(fraction: ageFraction, color: ac, height: 5, trackColor: ac.withValues(alpha: 0.10)),
      ],
    );
  }
}
