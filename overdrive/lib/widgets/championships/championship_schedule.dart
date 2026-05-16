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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
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
              const Divider(height: 14, color: Color(0xFF111111)),
          ],
        ],
      ),
    );
  }
}

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
        ? const Color(0xFF333333)
        : AppColors.textPrimary;
    final metaColor = isCompleted
        ? const Color(0xFF333333)
        : const Color(0xFF555555);
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

  Future<void> _openSessionToast(BuildContext context) {
    return OdModal.show<void>(
      context,
      title: session.name,
      child: const SizedBox.shrink(),
    );
  }
}

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
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Termine',
          style: AppTextStyles.body(
            color: const Color(0xFF333333),
          ).copyWith(fontSize: 11),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x10C9A84C),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x20C9A84C)),
      ),
      child: Text(
        session.status == SessionStatus.live ? 'LIVE' : 'A venir',
        style: AppTextStyles.body(
          color: const Color(0xFFC9A84C),
        ).copyWith(fontSize: 11),
      ),
    );
  }
}

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
