/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [damage.dart] - Telemetry widget showing aerodynamic and mechanical damage levels across six car components.
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

// Colour-codes a damage fraction: red above 50%, orange above 20%, gold above 5%, green otherwise.
Color _damageColor(double d) {
  if (d > 0.50) return AppColors.red;
  if (d > 0.20) return const Color(0xFFFF8C00);
  if (d > 0.05) return AppColors.gold;
  return AppColors.green;
}

// Damage level label
String _damageLabel(double d) {
  if (d > 0.50) return 'CRITIQUE';
  if (d > 0.20) return 'ÉLEVÉ';
  if (d > 0.05) return 'MINEUR';
  return 'OK';
}

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; tracks the selected driver and drives the small dot-grid or large bar-chart layout.
class Damage extends StatefulWidget {
  const Damage({this.initialDriverId = 'LEC', super.key});
  final String initialDriverId;

  @override
  State<Damage> createState() => _DamageState();
}

class _DamageState extends State<Damage> {
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
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Damage',
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
                  ? _SmallDamage(data: data, driverId: _driverId)
                  : _LargeDamage(data: data, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small — dot grid overview ─────────────────────────────────────────────────

class _SmallDamage extends StatelessWidget {
  const _SmallDamage({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    // Most severe damage drives the overall status
    final maxDamage = [
      data.frontWingDamage,
      data.rearWingDamage,
      data.floorDamage,
      data.gearboxDamage,
      data.suspensionDamage,
      data.engineDamage,
    ].reduce((a, b) => a > b ? a : b);
    final overallColor = _damageColor(maxDamage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DÉGÂTS', driverId: driverId),
        const Spacer(),
        // 2-column dot grid
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DotRow(label: 'AV', value: data.frontWingDamage),
                  const SizedBox(height: 5),
                  _DotRow(label: 'SOL', value: data.floorDamage),
                  const SizedBox(height: 5),
                  _DotRow(label: 'SUS', value: data.suspensionDamage),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DotRow(label: 'AR', value: data.rearWingDamage),
                  const SizedBox(height: 5),
                  _DotRow(label: 'BT', value: data.gearboxDamage),
                  const SizedBox(height: 5),
                  _DotRow(label: 'ENG', value: data.engineDamage),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Overall status
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: overallColor,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _damageLabel(maxDamage),
              style: AppTextStyles.caption(
                color: overallColor,
              ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Large — full bars ─────────────────────────────────────────────────────────

class _LargeDamage extends StatelessWidget {
  const _LargeDamage({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'DÉGÂTS', driverId: driverId),
        const SizedBox(height: 8),
        const _SectionLabel('AÉRODYNAMIQUE'),
        const SizedBox(height: 5),
        _DamageBar(label: 'AILE AV', value: data.frontWingDamage),
        const SizedBox(height: 5),
        _DamageBar(label: 'AILE AR', value: data.rearWingDamage),
        const SizedBox(height: 5),
        _DamageBar(label: 'PLANCHER', value: data.floorDamage),
        const SizedBox(height: 8),
        const _SectionLabel('MÉCANIQUE'),
        const SizedBox(height: 5),
        _DamageBar(label: 'BOÎTE', value: data.gearboxDamage),
        const SizedBox(height: 5),
        _DamageBar(label: 'SUSPENS.', value: data.suspensionDamage),
        const SizedBox(height: 5),
        _DamageBar(label: 'MOTEUR', value: data.engineDamage),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

// Small all-caps category label used to group damage bars (e.g. "AÉRODYNAMIQUE", "MÉCANIQUE").
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

// Compact dot + label for small mode
class _DotRow extends StatelessWidget {
  const _DotRow({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = _damageColor(value);
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 9),
        ),
        const Spacer(),
        Text(
          '${(value * 100).toInt()}%',
          style: AppTextStyles.caption(
            color: color,
          ).copyWith(fontSize: 8, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// Full-width bar row for large mode: fixed-width label + coloured bar + percentage readout.
class _DamageBar extends StatelessWidget {
  const _DamageBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = _damageColor(value);
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 9),
          ),
        ),
        Expanded(
          child: TelemetryBar(
            fraction: value,
            color: color,
            height: 4,
            trackColor: color.withValues(alpha: 0.10),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption(
              color: color,
            ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
