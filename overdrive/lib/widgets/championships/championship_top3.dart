/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_top3.dart - Live timing podium card showing top-3 drivers with gap, tyre compound, and team colour.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_live_entry.dart';

// ── Constants ─────────────────────────────────────────────────────────────

// Gap reference: bar is 0 % at +10 s and 100 % at 0 s (leader).
const double _kMaxGapSeconds = 10.0;

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

// ── ChampionshipTop3 ──────────────────────────────────────────────────────

/// Live timing card — three rows with gradient delta bars mapping gap to leader linearly (0 s = 100%, 10 s = 0%); bar colour from [ChampionshipLiveEntry.teamColor].
class ChampionshipTop3 extends StatelessWidget {
  const ChampionshipTop3({
    super.key,
    required this.entries,
    required this.accentColor,
    this.label,
  }) : assert(
         entries.length >= 3,
         'ChampionshipTop3 requires at least 3 entries.',
       );

  final List<ChampionshipLiveEntry> entries;
  final Color accentColor;
  final String? label;

  // Parses gap strings like "+3.4s", "3.4", "+3.4" → seconds as double.
  static double _parseGapSeconds(String gap) {
    final cleaned = gap.replaceAll(RegExp(r'[+s\s]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // fill ∈ [0, 1]: 0 s → 1.0, _kMaxGapSeconds → 0.0.
  static double _fillFraction(String gap) {
    final secs = _parseGapSeconds(gap);
    return (1.0 - secs / _kMaxGapSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final top = entries.take(3).toList(growable: false);
    final hasLabel = label != null && label!.trim().isNotEmpty;

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel) ...[
            Text(
              label!.toUpperCase(),
              style: AppTextStyles.label(
                color: AppColors.textSecondary,
              ).copyWith(letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
          ],
          CupertinoLiquidGlass(
            theme: _kCardTheme,
            borderRadius: BorderRadius.circular(22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    _DeltaRow(
                      entry: top[i],
                      rank: i + 1,
                      fillFraction: i == 0 ? 1.0 : _fillFraction(top[i].gap),
                      barColor: top[i].teamColor ?? accentColor,
                    ),
                    if (i < 2)
                      Container(
                        height: 0.5,
                        color: AppColors.white.withValues(alpha: 0.08),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _DeltaRow ─────────────────────────────────────────────────────────────

// One podium row with a gradient bar whose width maps the driver's gap to the leader.
class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.entry,
    required this.rank,
    required this.fillFraction,
    required this.barColor,
  });

  final ChampionshipLiveEntry entry;
  final int rank;
  final double fillFraction;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final isLeader = rank == 1;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final barWidth = constraints.maxWidth * fillFraction;

        return SizedBox(
          height: 62,
          child: Stack(
            children: [
              // ── Delta gradient bar ───────────────────────────────────
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: barWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withValues(alpha: 0.0),
                        barColor.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Row content ──────────────────────────────────────────
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Position — gold for P1 only
                      SizedBox(
                        width: 30,
                        child: Text(
                          'P$rank',
                          style: AppTextStyles.bodyBold(
                            color: isLeader
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ).copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Driver name + team
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyBold(
                                color: AppColors.textPrimary,
                              ).copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // Gap + lap
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLeader ? 'Leader' : entry.gap,
                            style: AppTextStyles.bodyBold(
                              color: isLeader ? barColor : AppColors.textSecondary,
                            ).copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tour ${entry.lap}',
                            style: AppTextStyles.body(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
