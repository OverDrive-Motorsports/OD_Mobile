/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [fuel_gauge.dart] - Telemetry widget showing current fuel load, estimated laps remaining, and per-lap consumption delta.
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

// Returns red below 20% fuel, orange below 40%, neutral white otherwise.
Color _fuelColor(double fraction) {
  if (fraction < 0.20) return AppColors.red;
  if (fraction < 0.40) return const Color(0xFFFF8C00);
  return AppColors.white.withValues(alpha: 0.60);
}

// Colours the per-lap delta: red if consuming more than target (> +0.08 kg), green if saving, neutral otherwise.
Color _deltaColor(double delta) {
  if (delta > 0.08) return AppColors.red;
  if (delta < -0.08) return AppColors.green;
  return AppColors.textSecondary;
}

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; normalises fuel load against the 110 kg tank capacity and delegates rendering.
class FuelGauge extends StatefulWidget {
  const FuelGauge({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<FuelGauge> createState() => _FuelGaugeState();
}

class _FuelGaugeState extends State<FuelGauge> {
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
      widgetLabel: 'Fuel Load',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final fuelFraction = (data.fuelLoad / 110).clamp(0.0, 1.0);
    final fuelColor = _fuelColor(fuelFraction);

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallFuel(data: data, driverId: _driverId, fuelFraction: fuelFraction, fuelColor: fuelColor)
                  : _LargeFuel(data: data, driverId: _driverId, fuelFraction: fuelFraction, fuelColor: fuelColor),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallFuel extends StatelessWidget {
  const _SmallFuel({required this.data, required this.driverId, required this.fuelFraction, required this.fuelColor});
  final TelemetrySnapshot data;
  final String driverId;
  final double fuelFraction;
  final Color fuelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'FUEL', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: data.fuelLoad),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (_, v, _) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    v.toStringAsFixed(1),
                    style: AppTextStyles.display(color: fuelColor)
                        .copyWith(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(width: 4),
                  Text('kg', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text(
              '~${data.lapsRemaining} tours',
              style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(fraction: fuelFraction, color: fuelColor),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeFuel extends StatelessWidget {
  const _LargeFuel({required this.data, required this.driverId, required this.fuelFraction, required this.fuelColor});
  final TelemetrySnapshot data;
  final String driverId;
  final double fuelFraction;
  final Color fuelColor;

  @override
  Widget build(BuildContext context) {
    final delta = data.fuelDeltaPerLap;
    final dColor = _deltaColor(delta);
    final sign = delta >= 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'FUEL', driverId: driverId),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fuel value
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: data.fuelLoad),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                builder: (_, v, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          v.toStringAsFixed(1),
                          style: AppTextStyles.display(color: fuelColor)
                              .copyWith(fontSize: 46, fontWeight: FontWeight.bold, letterSpacing: -2),
                        ),
                        const SizedBox(width: 4),
                        Text('kg', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 12)),
                      ],
                    ),
                    Text(
                      '~${data.lapsRemaining} tours',
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Consumption row
        Row(
          children: [
            _Stat(label: 'ACT', value: '${data.fuelPerLap.toStringAsFixed(2)} kg/t'),
            const SizedBox(width: 10),
            _Stat(label: 'TGT', value: '${data.fuelTargetPerLap.toStringAsFixed(2)} kg/t'),
            const Spacer(),
            Text(
              'Δ $sign${delta.toStringAsFixed(2)}',
              style: AppTextStyles.caption(color: dColor).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Segmented bar
        _SegmentedBar(fraction: fuelFraction, color: fuelColor),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

// Two-line label/value pair used for actual and target consumption in the large layout.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
        Text(value, style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// 10-segment animated bar that lights up segments proportionally to the fuel fraction.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: fraction.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (_, f, _) {
        const n = 10;
        final filled = (f * n).round();
        return Row(
          children: List.generate(n, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < n - 1 ? 2.0 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 5,
                  color: i < filled ? color : AppColors.surface,
                ),
              ),
            ),
          )),
        );
      },
    );
  }
}
