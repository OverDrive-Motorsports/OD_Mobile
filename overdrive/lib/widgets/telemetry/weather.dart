/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [weather.dart] - Telemetry widget displaying track and air temperatures, wind speed, and humidity.
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

// Stateless root widget — weather data is global (not per-driver), so no driver selector is needed.
class Weather extends StatelessWidget {
  const Weather({super.key});

  @override
  Widget build(BuildContext context) {
    final cond = context.watch<TelemetrySimulator>().getTrackConditions();

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(context, widgetLabel: 'Weather',
            onReset: actions?.onReset, onRemove: actions?.onRemove);
      },
      child: TelemetryCard(
        child: LayoutBuilder(builder: (context, constraints) {
          final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
          return Padding(
            padding: const EdgeInsets.all(12),
            child: mode == TelemetryMode.small
                ? _SmallWeather(cond: cond)
                : _LargeWeather(cond: cond),
          );
        }),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallWeather extends StatelessWidget {
  const _SmallWeather({required this.cond});
  final TrackConditions cond;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'WEATHER'),
        const SizedBox(height: 6),
        // Two temperature values side by side
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TempColumn(label: 'TRK', value: cond.trackTemp, color: AppColors.red),
              Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), color: AppColors.border),
              _TempColumn(label: 'AIR', value: cond.airTemp, color: AppColors.blue),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Wind + humidity compact row
        Row(
          children: [
            Icon(Icons.air_rounded, size: 9, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${cond.windSpeed.toStringAsFixed(0)} km/h',
                style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 9)),
            const Spacer(),
            Icon(Icons.water_drop_outlined, size: 9, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${cond.humidity.toInt()}%',
                style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 9)),
          ],
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeWeather extends StatelessWidget {
  const _LargeWeather({required this.cond});
  final TrackConditions cond;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + condition tag inline
        Row(
          children: [
            Text('WEATHER',
                style: AppTextStyles.label(color: AppColors.textMuted)
                    .copyWith(fontSize: 10, letterSpacing: 0.6)),
            const Spacer(),
            Text(cond.conditions.toUpperCase(),
                style: AppTextStyles.label(color: AppColors.textMuted)
                    .copyWith(fontSize: 9, letterSpacing: 0.4)),
          ],
        ),
        const SizedBox(height: 10),
        // Track temp — most critical metric
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: cond.trackTemp),
              duration: const Duration(milliseconds: 400),
              builder: (_, v, _) => Text(
                '${v.toStringAsFixed(1)}°',
                style: AppTextStyles.display(color: AppColors.red)
                    .copyWith(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('PISTE',
                  style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Divider
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 8),
        // Secondary metrics
        _MetricRow(icon: Icons.thermostat_rounded, label: 'AIR', value: '${cond.airTemp.toStringAsFixed(1)}°C', color: AppColors.blue),
        const SizedBox(height: 6),
        _MetricRow(icon: Icons.air_rounded, label: 'VENT', value: '${cond.windSpeed.toStringAsFixed(0)} km/h', color: AppColors.textSecondary),
        const SizedBox(height: 6),
        _HumidityRow(humidity: cond.humidity),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

// Vertically stacked label + animated temperature value; used side-by-side for TRK/AIR in small mode.
class _TempColumn extends StatelessWidget {
  const _TempColumn({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: AppTextStyles.caption(color: AppColors.textMuted)
                  .copyWith(fontSize: 8, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, _) => FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${v.toStringAsFixed(1)}°',
                  style: AppTextStyles.display(color: color)
                      .copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Generic icon + label + value row for secondary weather metrics in large mode.
class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.caption(color: AppColors.textSecondary)
                .copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Renders humidity as an inline progress bar with a percentage readout; normalised over 0–100%.
class _HumidityRow extends StatelessWidget {
  const _HumidityRow({required this.humidity});
  final double humidity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.water_drop_outlined, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text('HUM.',
            style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9)),
        const SizedBox(width: 8),
        Expanded(
          child: TelemetryBar(
            fraction: humidity / 100,
            color: AppColors.blue.withValues(alpha: 0.60),
            height: 3,
            trackColor: AppColors.surface,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text('${humidity.toInt()}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption(color: AppColors.textSecondary)
                  .copyWith(fontSize: 9, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
