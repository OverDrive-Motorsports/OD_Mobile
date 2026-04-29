/*
##
## OverDrive 2026
## All Technical rights reserved
##
## session_schedule_block.dart - Reusable race session schedule widget.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum SessionType { practice, qualifying, sprint, race }

enum SessionStatus { upcoming, live, completed }

class SessionRow extends StatelessWidget {
  const SessionRow({
    required this.sessionName,
    required this.dateTime,
    required this.type,
    this.status = SessionStatus.upcoming,
    this.countdownLabel,
    this.subtitle,
    super.key,
  });

  final String sessionName;
  final DateTime dateTime;
  final SessionType type;
  final SessionStatus status;
  final String? countdownLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatSessionDate(dateTime);
    final timeLabel = _formatSessionTime(dateTime);
    final showCountdown =
        status == SessionStatus.upcoming &&
        countdownLabel != null &&
        countdownLabel!.trim().isNotEmpty;
    final isCompleted = status == SessionStatus.completed;
    final isLive = status == SessionStatus.live;
    final primaryTextColor =
        isCompleted
            ? Colors.white.withValues(alpha: 0.72)
            : AppColors.textPrimary;
    final secondaryTextColor =
        isCompleted
            ? Colors.white.withValues(alpha: 0.44)
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          sessionName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(
                            color: primaryTextColor,
                          ).copyWith(fontSize: 15),
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: _LiveBadge(),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        color: secondaryTextColor,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                  if (showCountdown) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        countdownLabel!,
                        style:
                            AppTextStyles.bodyBold(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontSize: 9,
                              fontFamily: 'Courier',
                              fontFamilyFallback: const [
                                'Menlo',
                                'Monaco',
                                'Courier New',
                              ],
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateLabel,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold(
                    color: primaryTextColor,
                  ).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  timeLabel,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body(
                    color: secondaryTextColor,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SessionScheduleBlock extends StatelessWidget {
  const SessionScheduleBlock({
    required this.sessions,
    this.title = 'Programme',
    super.key,
  });

  final List<SessionRow> sessions;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyBold().copyWith(fontSize: 17),
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < sessions.length; index++) ...[
              if (index == 0)
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              sessions[index],
              if (index < sessions.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: 0.72,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 0.08,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD0B06A).withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD0B06A).withValues(
                    alpha: _glowAnimation.value,
                  ),
                  blurRadius: 7,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0B06A).withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'EN COURS',
                  style: AppTextStyles.bodyBold(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatSessionDate(DateTime date) {
  const weekdays = <String>[
    'Lun.',
    'Mar.',
    'Mer.',
    'Jeu.',
    'Ven.',
    'Sam.',
    'Dim.',
  ];
  const months = <String>[
    'jan.',
    'fev.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'aout',
    'sept.',
    'oct.',
    'nov.',
    'dec.',
  ];

  return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
}

String _formatSessionTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}
