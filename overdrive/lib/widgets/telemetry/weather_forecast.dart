/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## weather_forecast.dart - Hourly weather forecast telemetry widget with rain probability display.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Root widget that selects between compact column view and the detailed row list.
class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<TelemetrySimulator>().getWeatherForecast();

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(context,
            widgetLabel: 'Météo Prévisions',
            onReset: actions?.onReset,
            onRemove: actions?.onRemove);
      },
      child: TelemetryCard(
        child: LayoutBuilder(builder: (context, constraints) {
          final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: mode == TelemetryMode.small
                ? _SmallForecast(forecast: forecast)
                : _LargeForecast(forecast: forecast),
          );
        }),
      ),
    );
  }
}

// ── Small mode ────────────────────────────────────────────────────────────────
// Horizontal scrollable columns: hour / icon / temp / rain%

class _SmallForecast extends StatelessWidget {
  const _SmallForecast({required this.forecast});
  final List<HourlyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRÉVISIONS',
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 10, letterSpacing: 0.6)),
        const SizedBox(height: 6),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: forecast.map((h) => _SmallHourColumn(h: h)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallHourColumn extends StatelessWidget {
  const _SmallHourColumn({required this.h});
  final HourlyForecast h;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(h.hour,
              style: AppTextStyles.caption(color: AppColors.textMuted)
                  .copyWith(fontSize: 8)),
          Icon(_conditionIcon(h.condition),
              size: 18, color: _conditionColor(h.condition)),
          Text('${h.tempC.toInt()}°',
              style: AppTextStyles.label(color: AppColors.textPrimary)
                  .copyWith(fontSize: 12, letterSpacing: 0)),
          Text('${(h.precipChance * 100).toInt()}%',
              style: AppTextStyles.caption(color: _precipColor(h.precipChance))
                  .copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}

// ── Large mode ────────────────────────────────────────────────────────────────
// 8-row list: hour | icon + condition | temp | wind | precip bar

class _LargeForecast extends StatelessWidget {
  const _LargeForecast({required this.forecast});
  final List<HourlyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    // Find when rain/storm first appears → "PLUIE DANS Xh"
    final firstRain = forecast.indexWhere(
        (h) => h.condition == 'rain' || h.condition == 'storm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text('PRÉVISIONS',
                style: AppTextStyles.label(color: AppColors.textMuted)
                    .copyWith(fontSize: 10, letterSpacing: 0.6)),
            const Spacer(),
            if (firstRain > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop_rounded,
                      size: 10, color: AppColors.blue),
                  const SizedBox(width: 3),
                  Text('DANS ~${firstRain}H',
                      style: AppTextStyles.label(color: AppColors.blue)
                          .copyWith(fontSize: 9, letterSpacing: 0.4)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Rows
        Expanded(
          child: Column(
            children: forecast.map((h) {
              final isLast = h == forecast.last;
              return Expanded(
                child: _LargeHourRow(h: h, showDivider: !isLast),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LargeHourRow extends StatelessWidget {
  const _LargeHourRow({required this.h, required this.showDivider});
  final HourlyForecast h;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final precipColor = _precipColor(h.precipChance);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Hour
              SizedBox(
                width: 36,
                child: Text(h.hour,
                    style: AppTextStyles.caption(color: AppColors.textMuted)
                        .copyWith(fontSize: 9, fontWeight: FontWeight.w600)),
              ),
              // Icon
              Icon(_conditionIcon(h.condition),
                  size: 16, color: _conditionColor(h.condition)),
              const SizedBox(width: 6),
              // Temp
              SizedBox(
                width: 28,
                child: Text('${h.tempC.toInt()}°',
                    style: AppTextStyles.label(color: AppColors.textPrimary)
                        .copyWith(fontSize: 11, letterSpacing: 0)),
              ),
              // Wind
              const Icon(Icons.air_rounded,
                  size: 10, color: AppColors.textMuted),
              const SizedBox(width: 2),
              SizedBox(
                width: 22,
                child: Text('${h.windKph.toInt()}',
                    style: AppTextStyles.caption(color: AppColors.textMuted)
                        .copyWith(fontSize: 8)),
              ),
              // Precip bar
              Expanded(
                child: TelemetryBar(
                  fraction: h.precipChance,
                  color: precipColor,
                  height: 3,
                  trackColor: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
              const SizedBox(width: 6),
              // Precip %
              SizedBox(
                width: 26,
                child: Text(
                  '${(h.precipChance * 100).toInt()}%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption(color: precipColor)
                      .copyWith(fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(height: 0.5, color: AppColors.divider),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Maps a weather condition string to its representative Material icon.
IconData _conditionIcon(String condition) => switch (condition) {
      'sunny' => Icons.wb_sunny_rounded,
      'partly_cloudy' => Icons.wb_cloudy_rounded,
      'cloudy' => Icons.cloud_rounded,
      'rain' => Icons.grain_rounded,
      'storm' => Icons.bolt_rounded,
      _ => Icons.cloud_rounded,
    };

Color _conditionColor(String condition) => switch (condition) {
      'sunny' => AppColors.gold,
      'partly_cloudy' => const Color(0xFFCCDDFF),
      'cloudy' => AppColors.textMuted,
      'rain' => AppColors.blue,
      'storm' => const Color(0xFFFFD700),
      _ => AppColors.textMuted,
    };

// Returns a traffic-light color (green → amber → red) based on precipitation probability.
Color _precipColor(double chance) {
  if (chance < 0.25) return AppColors.green;
  if (chance < 0.55) return const Color(0xFFF0B429);
  if (chance < 0.75) return const Color(0xFFFF8C00);
  return AppColors.red;
}
