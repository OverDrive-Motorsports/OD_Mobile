/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_next_event.dart - Next event countdown card for championship pages.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_circuit.dart';

// ---------------------------------------------------------------------------
// Glass theme
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// ChampionshipNextEventCard
// ---------------------------------------------------------------------------

/// Off-season card showing the next known event name, location, and countdown.
class ChampionshipNextEventCard extends StatelessWidget {
  const ChampionshipNextEventCard({
    super.key,
    required this.nextEvent,
    required this.now,
  });

  final ChampionshipNextEvent nextEvent;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final countdown = _EventCountdown.from(nextEvent.startsAt.difference(now));

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
                  'Prochain event'.toUpperCase(),
                  style: AppTextStyles.label(
                    color: AppColors.textSecondary,
                  ).copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: 14),
                Text(
                  nextEvent.name,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  nextEvent.location,
                  style: AppTextStyles.body(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CountdownCell(value: countdown.days, label: 'Jours'),
                    ),
                    const _CountdownDot(),
                    Expanded(
                      child: _CountdownCell(value: countdown.hours, label: 'Heures'),
                    ),
                    const _CountdownDot(),
                    Expanded(
                      child: _CountdownCell(value: countdown.minutes, label: 'Min'),
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _CountdownCell extends StatelessWidget {
  const _CountdownCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: AppTextStyles.bodyBold().copyWith(fontSize: 24)),
        const SizedBox(height: 1),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.body(
            color: AppColors.textSecondary,
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _CountdownDot extends StatelessWidget {
  const _CountdownDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: AppTextStyles.body(
          color: AppColors.white.withValues(alpha: 0.16),
        ).copyWith(fontSize: 24),
      ),
    );
  }
}

class _EventCountdown {
  const _EventCountdown({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  factory _EventCountdown.from(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    return _EventCountdown(
      days: safe.inDays,
      hours: safe.inHours.remainder(24),
      minutes: safe.inMinutes.remainder(60),
    );
  }

  final int days;
  final int hours;
  final int minutes;
}
