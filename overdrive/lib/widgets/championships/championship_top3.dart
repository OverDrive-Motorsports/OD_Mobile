/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_top3.dart - Compact top 3 card for live championship sessions.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_live_entry.dart';

/// Compact card that highlights the first three live standings entries.
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

  @override
  Widget build(BuildContext context) {
    final topEntries = entries.take(3).toList(growable: false);
    final hasLabel = label != null && label!.trim().isNotEmpty;

    return Column(
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                for (var index = 0; index < topEntries.length; index++) ...[
                  Expanded(
                    child: _Top3Cell(
                      entry: topEntries[index],
                      accentColor: accentColor,
                      rankLabel: 'P${topEntries[index].position}',
                      isLeader: index == 0,
                    ),
                  ),
                  if (index < topEntries.length - 1)
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One column of the top-3 card, with a stronger treatment for the leader.
class _Top3Cell extends StatelessWidget {
  const _Top3Cell({
    required this.entry,
    required this.accentColor,
    required this.rankLabel,
    required this.isLeader,
  });

  final ChampionshipLiveEntry entry;
  final Color accentColor;
  final String rankLabel;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isLeader
        ? AppColors.gold.withValues(alpha: 0.08)
        : AppColors.surface;
    final barColor = isLeader ? accentColor : AppColors.border;
    final nameColor = isLeader ? AppColors.textPrimary : AppColors.textMuted;
    final secondaryColor = isLeader ? accentColor : AppColors.textSecondary;

    return ColoredBox(
      color: surfaceColor,
      child: Column(
        children: [
          Container(height: 2, color: barColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rankLabel,
                  style: AppTextStyles.bodyBold(
                    color: secondaryColor,
                  ).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(
                    color: nameColor,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.gap,
                  style: AppTextStyles.body(
                    color: secondaryColor,
                  ).copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
