/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_schedule.dart - Adaptive weekend schedule list.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_enums.dart';
import '../../services/championship/championship_session.dart';
import '../base/od_modal.dart';

/// Weekend program card for championship sessions.
class ChampionshipSchedule extends StatelessWidget {
  const ChampionshipSchedule({
    super.key,
    required this.sessions,
    required this.now,
    this.title = 'Programme',
  });

  final List<ChampionshipSession> sessions;
  final DateTime now;
  final String title;

  @override
  Widget build(BuildContext context) {
    final nextUpcomingIndex = sessions.indexWhere(
      (ChampionshipSession session) => session.status == SessionStatus.upcoming,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold().copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < sessions.length; index++) ...[
            _ScheduleRow(
              session: sessions[index],
              isNextUpcoming: index == nextUpcomingIndex,
              now: now,
            ),
            if (index < sessions.length - 1)
              const Divider(height: 14, color: AppColors.surface),
          ],
        ],
      ),
    );
  }
}

/// Interactive row showing one session name, timing, and status badge.
class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.session,
    required this.isNextUpcoming,
    required this.now,
  });

  final ChampionshipSession session;
  final bool isNextUpcoming;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == SessionStatus.completed;
    final titleColor = isCompleted
        ? AppColors.white.withValues(alpha: 0.20)
        : AppColors.textPrimary;
    final metaColor = isCompleted
        ? AppColors.white.withValues(alpha: 0.20)
        : AppColors.textSecondary;
    final countdown = isNextUpcoming
        ? _formatCountdown(session.scheduledAt.difference(now))
        : null;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openSessionToast(context),
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: AppTextStyles.bodyBold(
                              color: titleColor,
                            ).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _formatSessionDate(
                              session.scheduledAt,
                              countdown: countdown,
                            ),
                            style: AppTextStyles.body(
                              color: metaColor,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SessionBadge(
                      session: session,
                      isNextUpcoming: isNextUpcoming,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Opens a lightweight modal placeholder for the tapped session.
  Future<void> _openSessionToast(BuildContext context) {
    return OdModal.show<void>(
      context,
      title: session.name,
      child: const SizedBox.shrink(),
    );
  }
}

/// Badge renderer for completed, next, live, and upcoming sessions.
class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.session, required this.isNextUpcoming});

  final ChampionshipSession session;
  final bool isNextUpcoming;

  @override
  Widget build(BuildContext context) {
    if (isNextUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'PROCHAIN',
          style: AppTextStyles.bodyBold(
            color: AppColors.black,
          ).copyWith(fontSize: 11),
        ),
      );
    }

    if (session.status == SessionStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Termine',
          style: AppTextStyles.body(
            color: AppColors.white.withValues(alpha: 0.20),
          ).copyWith(fontSize: 11),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
      ),
      child: Text(
        session.status == SessionStatus.live ? 'LIVE' : 'A venir',
        style: AppTextStyles.body(color: AppColors.gold).copyWith(fontSize: 11),
      ),
    );
  }
}

/// Formats the session date with an optional countdown suffix.
String _formatSessionDate(DateTime date, {String? countdown}) {
  const weekdays = <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final weekday = weekdays[date.weekday - 1];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final base = '$weekday ${hour}h$minute';

  if (countdown == null || countdown.isEmpty) {
    return base;
  }

  return '$base · $countdown';
}

/// Formats the remaining time before the next upcoming session.
String _formatCountdown(Duration duration) {
  if (duration.isNegative) {
    return 'maintenant';
  }

  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);

  if (days > 0) {
    return 'dans ${days}j ${hours}h';
  }

  if (hours > 0) {
    return 'dans ${hours}h ${minutes}min';
  }

  return 'dans ${minutes}min';
}
