/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_circuit_weather.dart - Combined card displaying circuit metadata and current weather conditions.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_circuit.dart';

// ── Glass theme ───────────────────────────────────────────────────────────

const _kBorderColor = Color(0x26FFFFFF);

final _kCardTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.20,
  blurSigma: 28.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.05,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

// ── ChampionshipCircuitWeatherCard ────────────────────────────────────────

/// Event-weekend card showing circuit length, lap count, and weather.
class ChampionshipCircuitWeatherCard extends StatelessWidget {
  const ChampionshipCircuitWeatherCard({
    super.key,
    required this.circuit,
    required this.weather,
  });

  final ChampionshipCircuit circuit;
  final ChampionshipWeather weather;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kCardTheme,
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Circuit · Meteo'.toUpperCase(),
                  style: AppTextStyles.label(
                    color: AppColors.textSecondary,
                  ).copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _MetricColumn(
                        label: 'Longueur',
                        value: '${circuit.lengthKm.toStringAsFixed(3)} km',
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _MetricColumn(
                        label: 'Tours',
                        value: '${circuit.totalLaps}',
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _MetricColumn(
                        label: 'Meteo',
                        value: '${weather.rainChancePercent}%',
                        icon: weather.rainChancePercent > 0
                            ? Icons.cloud_rounded
                            : Icons.wb_sunny_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

// Thin vertical separator between metric columns in the circuit/weather card.
class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.white.withValues(alpha: 0.08),
    );
  }
}

// Label/value column optionally prefixed with an icon (e.g. weather icon beside rain chance).
class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 4),
          if (icon == null)
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.bodyBold(
                  color: AppColors.textMuted,
                ).copyWith(fontSize: 16, height: 1.1),
              ),
            )
          else
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    value,
                    style: AppTextStyles.bodyBold(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
