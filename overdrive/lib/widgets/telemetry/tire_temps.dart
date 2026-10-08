/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [tire_temps.dart] - Telemetry widget displaying per-tyre temperature, pressure, wear, and compound information.
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

// Colour-codes a tyre temperature: red above 115 °C (overheating), orange 100–115 °C, green 80–100 °C, blue below 80 °C (cold).
Color _tireColor(double t) {
  if (t > 115) return AppColors.red;
  if (t > 100) return const Color(0xFFFF8C00);
  if (t >= 80) return AppColors.green;
  return AppColors.blue;
}

// Colour-codes wear fraction: red above 70%, orange above 45%, green otherwise.
Color _wearColor(double w) {
  if (w > 0.70) return AppColors.red;
  if (w > 0.45) return const Color(0xFFFF8C00);
  return AppColors.green;
}

// Returns the single-character abbreviation used in the compound badge (e.g. "Soft" → "S").
String _compoundLetter(String c) => switch (c) {
  'Soft' => 'S',
  'Medium' => 'M',
  'Hard' => 'H',
  'Inter' => 'I',
  'Wet' => 'W',
  _ => c.isNotEmpty ? c[0] : '?',
};

// Returns the canonical F1 compound colour (red = soft, yellow = medium, white = hard, etc.).
Color _compoundColor(String c) => switch (c) {
  'Soft' => AppColors.red,
  'Medium' => const Color(0xFFFFD700),
  'Hard' => AppColors.white,
  'Inter' => AppColors.green,
  'Wet' => AppColors.blue,
  _ => AppColors.textMuted,
};

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; holds the selected driver and switches between compact and detailed tyre layouts.
class TireTemps extends StatefulWidget {
  const TireTemps({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<TireTemps> createState() => _TireTempsState();
}

class _TireTempsState extends State<TireTemps> {
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
          widgetLabel: 'Tyre Temps',
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
                  ? _SmallTires(data: data, driverId: _driverId)
                  : _LargeTires(data: data, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small — temp grid only ────────────────────────────────────────────────────

class _SmallTires extends StatelessWidget {
  const _SmallTires({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    final temps = data.tyreTemp;
    final wear = data.tyreWear;
    final cc = _compoundColor(data.tyreCompound);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with compound tag
        Row(
          children: [
            Text(
              'TYRES',
              style: AppTextStyles.label(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 10, letterSpacing: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              _compoundLetter(data.tyreCompound),
              style: AppTextStyles.label(
                color: cc,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
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
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _SmallTireCell(
                        pos: 'FL',
                        temp: temps['fl'] ?? 90,
                        wear: wear['fl'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _SmallTireCell(
                        pos: 'FR',
                        temp: temps['fr'] ?? 90,
                        wear: wear['fr'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _SmallTireCell(
                        pos: 'RL',
                        temp: temps['rl'] ?? 90,
                        wear: wear['rl'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _SmallTireCell(
                        pos: 'RR',
                        temp: temps['rr'] ?? 90,
                        wear: wear['rr'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Large — full info per tyre ────────────────────────────────────────────────

class _LargeTires extends StatelessWidget {
  const _LargeTires({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    final temps = data.tyreTemp;
    final pressure = data.tyrePressure;
    final wear = data.tyreWear;
    final cc = _compoundColor(data.tyreCompound);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with compound + age
        Row(
          children: [
            Text(
              'TYRES',
              style: AppTextStyles.label(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 10, letterSpacing: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              _compoundLetter(data.tyreCompound),
              style: AppTextStyles.label(
                color: cc,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 3),
            Text(
              '${data.tyreAge} laps',
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 8),
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
        const SizedBox(height: 7),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _LargeTireCard(
                        pos: 'FL',
                        temp: temps['fl'] ?? 90,
                        pressure: pressure['fl'] ?? 23,
                        wear: wear['fl'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _LargeTireCard(
                        pos: 'FR',
                        temp: temps['fr'] ?? 90,
                        pressure: pressure['fr'] ?? 23,
                        wear: wear['fr'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _LargeTireCard(
                        pos: 'RL',
                        temp: temps['rl'] ?? 90,
                        pressure: pressure['rl'] ?? 22,
                        wear: wear['rl'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _LargeTireCard(
                        pos: 'RR',
                        temp: temps['rr'] ?? 90,
                        pressure: pressure['rr'] ?? 22,
                        wear: wear['rr'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tire cell — small mode ────────────────────────────────────────────────────

class _SmallTireCell extends StatelessWidget {
  const _SmallTireCell({
    required this.pos,
    required this.temp,
    required this.wear,
  });
  final String pos;
  final double temp;
  final double wear;

  @override
  Widget build(BuildContext context) {
    final tc = _tireColor(temp);
    final wc = _wearColor(wear);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: tc.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tc.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pos,
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 8),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: temp),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, _) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${v.toInt()}°',
                style: AppTextStyles.bodyBold(color: tc).copyWith(fontSize: 15),
              ),
            ),
          ),
          TelemetryBar(
            fraction: wear,
            color: wc,
            height: 2.5,
            trackColor: wc.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

// ── Tire card — large mode ────────────────────────────────────────────────────

class _LargeTireCard extends StatelessWidget {
  const _LargeTireCard({
    required this.pos,
    required this.temp,
    required this.pressure,
    required this.wear,
  });
  final String pos;
  final double temp;
  final double pressure;
  final double wear;

  @override
  Widget build(BuildContext context) {
    final tc = _tireColor(temp);
    final wc = _wearColor(wear);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: tc.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: tc.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position label
          Text(
            pos,
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 8),
          ),
          const Spacer(),
          // Temperature — primary
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: temp),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, _) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${v.toInt()}°',
                style: AppTextStyles.display(
                  color: tc,
                ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Pressure
          Text(
            '${pressure.toStringAsFixed(1)} PSI',
            style: AppTextStyles.caption(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 8),
          ),
          const SizedBox(height: 5),
          // Wear bar + %
          Row(
            children: [
              Expanded(
                child: TelemetryBar(
                  fraction: wear,
                  color: wc,
                  height: 3,
                  trackColor: wc.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 26,
                child: Text(
                  '${(wear * 100).toInt()}%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption(
                    color: wc,
                  ).copyWith(fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
