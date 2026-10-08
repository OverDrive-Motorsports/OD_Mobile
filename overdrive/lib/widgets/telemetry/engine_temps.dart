/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [engine_temps.dart] - Telemetry widget monitoring water, oil, hydraulic, ERS, and turbo-boost temperatures.
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

// Maps engine mode name to an accent colour (Party = red, Standard = gold, Conservation = green).
Color _modeColor(String mode) => switch (mode) {
  'Party' => AppColors.red,
  'Standard' => AppColors.gold,
  'Conservation' => AppColors.green,
  _ => AppColors.textMuted,
};

// Normalises a temperature within [min, max] and returns red above 82%, orange above 60%, neutral otherwise.
// Each sensor has a different operating range, so callers must supply the appropriate min/max bounds.
Color _tempColor(double temp, double min, double max) {
  final f = ((temp - min) / (max - min)).clamp(0.0, 1.0);
  if (f > 0.82) return AppColors.red;
  if (f > 0.60) return const Color(0xFFFF8C00);
  return AppColors.white.withValues(alpha: 0.60);
}

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; resolves mode colour once and passes it down to avoid repeated switch evaluation.
class EngineTemps extends StatefulWidget {
  const EngineTemps({this.initialDriverId = 'NOR', super.key});
  final String initialDriverId;

  @override
  State<EngineTemps> createState() => _EngineTempsState();
}

class _EngineTempsState extends State<EngineTemps> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final mc = _modeColor(data.engineMode);

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Engine',
          currentDriverId: _driverId,
          onDriverSelected: (id) => setState(() => _driverId = id),
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
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
                  ? _SmallEngine(data: data, driverId: _driverId, mc: mc)
                  : _LargeEngine(data: data, driverId: _driverId, mc: mc),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallEngine extends StatelessWidget {
  const _SmallEngine({
    required this.data,
    required this.driverId,
    required this.mc,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color mc;

  @override
  Widget build(BuildContext context) {
    final wc = _tempColor(data.waterTemp, 82, 108);
    final oc = _tempColor(data.oilTemp, 98, 132);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: ENGINE · [dot] MODE  |  DRIVER
        Row(
          children: [
            Text(
              'ENGINE',
              style: AppTextStyles.label(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 10, letterSpacing: 0.6),
            ),
            const SizedBox(width: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mc),
            ),
            const Spacer(),
            Text(
              driverId,
              style: AppTextStyles.label(
                color: AppColors.gold,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
        const Spacer(),
        _EngineRow(
          label: 'H₂O',
          value: data.waterTemp,
          min: 82,
          max: 108,
          color: wc,
        ),
        const SizedBox(height: 6),
        _EngineRow(
          label: 'OIL',
          value: data.oilTemp,
          min: 98,
          max: 132,
          color: oc,
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeEngine extends StatelessWidget {
  const _LargeEngine({
    required this.data,
    required this.driverId,
    required this.mc,
  });
  final TelemetrySnapshot data;
  final String driverId;
  final Color mc;

  @override
  Widget build(BuildContext context) {
    final wc = _tempColor(data.waterTemp, 82, 108);
    final oc = _tempColor(data.oilTemp, 98, 132);
    final hc = _tempColor(data.hydraulicTemp, 38, 62);
    final kc = _tempColor(data.mgukTemp, 55, 115);
    final ec = _tempColor(data.esTemp, 20, 55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with mode inline
        Row(
          children: [
            Text(
              'ENGINE',
              style: AppTextStyles.label(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 10, letterSpacing: 0.6),
            ),
            const SizedBox(width: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mc),
            ),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles.label(color: mc).copyWith(fontSize: 9),
              child: Text(data.engineMode.toUpperCase()),
            ),
            const Spacer(),
            Text(
              driverId,
              style: AppTextStyles.label(
                color: AppColors.gold,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Cooling circuit
        const _SectionLabel('REFROIDISSEMENT'),
        const SizedBox(height: 5),
        _EngineRow(
          label: 'H₂O',
          value: data.waterTemp,
          min: 82,
          max: 108,
          color: wc,
          barHeight: 4,
        ),
        const SizedBox(height: 5),
        _EngineRow(
          label: 'OIL',
          value: data.oilTemp,
          min: 98,
          max: 132,
          color: oc,
          barHeight: 4,
        ),
        const SizedBox(height: 5),
        _EngineRow(
          label: 'HYD',
          value: data.hydraulicTemp,
          min: 38,
          max: 62,
          color: hc,
          barHeight: 4,
        ),
        const SizedBox(height: 8),
        // ERS / electrical
        const _SectionLabel('ERS'),
        const SizedBox(height: 5),
        _EngineRow(
          label: 'MGU-K',
          value: data.mgukTemp,
          min: 55,
          max: 115,
          color: kc,
          barHeight: 4,
        ),
        const SizedBox(height: 5),
        _EngineRow(
          label: 'ES',
          value: data.esTemp,
          min: 20,
          max: 55,
          color: ec,
          barHeight: 4,
        ),
        const SizedBox(height: 8),
        // Turbo
        const _SectionLabel('TURBO'),
        const SizedBox(height: 5),
        _BoostRow(boost: data.turboBoost),
      ],
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

// Small all-caps category label used to group sensor rows (e.g. "REFROIDISSEMENT", "ERS", "TURBO").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption(
        color: AppColors.textMuted,
      ).copyWith(fontSize: 8, letterSpacing: 0.8),
    );
  }
}

// Generic sensor row: label + coloured progress bar (fraction derived from caller-supplied min/max) + live °C value.
class _EngineRow extends StatelessWidget {
  const _EngineRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    this.barHeight = 3.5,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 9),
          ),
        ),
        Expanded(
          child: TelemetryBar(
            fraction: fraction,
            color: color,
            height: barHeight,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, _) => Text(
              '${v.toInt()}°',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(
                color: color,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// Displays turbo boost as a fraction (0–1); colour escalates to orange above 75% and red above 90%.
class _BoostRow extends StatelessWidget {
  const _BoostRow({required this.boost});
  final double boost;

  @override
  Widget build(BuildContext context) {
    final color = boost > 0.90
        ? AppColors.red
        : boost > 0.75
        ? const Color(0xFFFF8C00)
        : AppColors.white.withValues(alpha: 0.60);

    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            'BOOST',
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 9),
          ),
        ),
        Expanded(
          child: TelemetryBar(fraction: boost, color: color, height: 3.5),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: boost),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, _) => Text(
              '${(v * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(
                color: color,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
