/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_replay_btn.dart - Replay CTA card for championship pages.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_circuit.dart';

class ChampionshipReplayBtn extends StatelessWidget {
  const ChampionshipReplayBtn({
    super.key,
    required this.replays,
    required this.onTap,
  });

  final ChampionshipReplays replays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF666666),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bibliotheque de replays',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      replays.label,
                      style: AppTextStyles.body(
                        color: const Color(0xFF555555),
                      ).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF333333),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
