/*
 ##
 ## OverDrive 2026 — home_page.dart
 ## Sports-style home with day tabs and slide-in menu.
 ##
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/top_left_menu_overlay.dart';


enum RaceStatus { finished, live, upcoming }

class RaceSession {
  const RaceSession(this.name, this.date, this.time, {this.result});
  final String name;
  final String date;
  final String time;
  final String? result;
}

class RaceWeekend {
  const RaceWeekend({
    required this.round,
    required this.country,
    required this.flag,
    required this.circuit,
    required this.sessions,
    required this.status,
    this.winner,
  });

  final int round;
  final String country;
  final String flag;
  final String circuit;
  final List<RaceSession> sessions;
  final RaceStatus status;
  final String? winner;
}

const _pastRaces = [
  RaceWeekend(
    round: 1,
    country: 'Australia',
    flag: '🇦🇺',
    circuit: 'Albert Park Circuit',
    status: RaceStatus.finished,
    winner: 'George Russell · Mercedes',
    sessions: [
      RaceSession('Qualifying', 'Sat. 15 Mar', '08:00', result: 'P1 · Verstappen'),
      RaceSession('Race', 'Sun. 16 Mar', '06:00', result: '1. Russell · +0.4s'),
    ],
  ),
];

const _thisWeek = [
  RaceWeekend(
    round: 2,
    country: 'China',
    flag: '🇨🇳',
    circuit: 'Shanghai International Circuit',
    status: RaceStatus.live,
    sessions: [
      RaceSession('Sprint Qualifying', 'Fri. 21 Mar', '08:30', result: 'P1 · Norris'),
      RaceSession('Sprint', 'Sat. 22 Mar', '04:00', result: '1. Norris'),
      RaceSession('Qualifying', 'Sat. 22 Mar', '08:00', result: 'P1 · Verstappen'),
      RaceSession('Race', 'Sun. 23 Mar', '08:00'),
    ],
  ),
];

const _upcoming = [
  RaceWeekend(
    round: 3,
    country: 'Japan',
    flag: '🇯🇵',
    circuit: 'Suzuka Circuit',
    status: RaceStatus.upcoming,
    sessions: [
      RaceSession('Qualifying', 'Sat. 5 Apr', '07:00'),
      RaceSession('Race', 'Sun. 6 Apr', '06:00'),
    ],
  ),
  RaceWeekend(
    round: 4,
    country: 'Bahrain',
    flag: '🇧🇭',
    circuit: 'Bahrain International Circuit',
    status: RaceStatus.upcoming,
    sessions: [
      RaceSession('Qualifying', 'Sat. 12 Apr', '18:00'),
      RaceSession('Race', 'Sun. 13 Apr', '18:00'),
    ],
  ),
];

enum _DayTab { yesterday, today, upcoming }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  _DayTab _activeTab = _DayTab.today;

  List<RaceWeekend> get _visibleRaces {
    switch (_activeTab) {
      case _DayTab.yesterday:
        return _pastRaces;
      case _DayTab.today:
        return _thisWeek;
      case _DayTab.upcoming:
        return _upcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF060606),
              Color(0xFF020202),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -120,
              child: _GlowBlob(color: Colors.white.withOpacity(0.06), size: 300),
            ),
            Positioned(
              top: 160,
              right: -120,
              child: _GlowBlob(color: const Color(0xFF7AB7FF).withOpacity(0.06), size: 240),
            ),
            Positioned(
              bottom: -140,
              left: -60,
              child: _GlowBlob(color: const Color(0xFFAED8FF).withOpacity(0.05), size: 280),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    Expanded(
                      child: _SchedulePanel(
                        activeTab: _activeTab,
                        onTabChanged: (tab) => setState(() => _activeTab = tab),
                        races: _visibleRaces,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const TopLeftMenuOverlay(),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel({
    required this.activeTab,
    required this.onTabChanged,
    required this.races,
  });

  final _DayTab activeTab;
  final ValueChanged<_DayTab> onTabChanged;
  final List<RaceWeekend> races;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x8AFFFFFF),
                Color(0x10FFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _DayTabButton(
                        label: 'Hier',
                        active: activeTab == _DayTab.yesterday,
                        onTap: () => onTabChanged(_DayTab.yesterday),
                      ),
                    ),
                    Expanded(
                      child: _DayTabButton(
                        label: 'Aujourd\'hui',
                        active: activeTab == _DayTab.today,
                        onTap: () => onTabChanged(_DayTab.today),
                      ),
                    ),
                    Expanded(
                      child: _DayTabButton(
                        label: 'À venir',
                        active: activeTab == _DayTab.upcoming,
                        onTap: () => onTabChanged(_DayTab.upcoming),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.8, color: Colors.white.withOpacity(0.16)),
              Expanded(
                child: races.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun événement',
                          style: AppTextStyles.body(color: Colors.white.withOpacity(0.7)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        itemCount: races.length + 1,
                        separatorBuilder: (context, index) => Divider(
                          height: 14,
                          thickness: 1,
                          color: Colors.white.withOpacity(0.10),
                        ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.flag_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Formule 1',
                                  style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: 15),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.7)),
                              ],
                            );
                          }
                          return _RaceWeekTile(
                            race: races[index - 1],
                            showWinner: activeTab == _DayTab.yesterday,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTabButton extends StatelessWidget {
  const _DayTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle(
            color: active ? Colors.white : Colors.white.withOpacity(0.52),
          ).copyWith(fontSize: 16),
        ),
      ),
    );
  }
}

class _RaceWeekTile extends StatelessWidget {
  const _RaceWeekTile({
    required this.race,
    required this.showWinner,
  });

  final RaceWeekend race;
  final bool showWinner;

  Color get _statusColor {
    switch (race.status) {
      case RaceStatus.finished:
        return Colors.white.withOpacity(0.85);
      case RaceStatus.live:
        return AppColors.red;
      case RaceStatus.upcoming:
        return AppColors.gold;
    }
  }

  String get _statusText {
    switch (race.status) {
      case RaceStatus.finished:
        return 'Terminé';
      case RaceStatus.live:
        return 'En direct';
      case RaceStatus.upcoming:
        final first = race.sessions.first;
        return '${first.date} · ${first.time}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            race.circuit,
            style: AppTextStyles.caption(color: Colors.white.withOpacity(0.42)).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${race.flag} ${race.country}',
                  style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _statusText,
                style: AppTextStyles.bodyBold(color: _statusColor).copyWith(fontSize: 13),
              ),
              const SizedBox(width: 12),
              Text(
                'RD ${race.round}',
                style: AppTextStyles.caption(color: Colors.white.withOpacity(0.75)).copyWith(fontSize: 12),
              ),
            ],
          ),
          if (showWinner) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, size: 14, color: Colors.white.withOpacity(0.72)),
                const SizedBox(width: 6),
                Text(
                  'Gagnant: ${race.winner ?? 'George Russell · Mercedes'}',
                  style: AppTextStyles.caption(color: Colors.white.withOpacity(0.82)).copyWith(fontSize: 12),
                ),
              ],
            ),
          ] else if (race.sessions.isNotEmpty) ...[
            const SizedBox(height: 9),
            ...race.sessions.take(2).map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 5, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.name,
                            style: AppTextStyles.caption(color: Colors.white.withOpacity(0.82)).copyWith(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${session.date} · ${session.time}',
                          style: AppTextStyles.caption(color: Colors.white.withOpacity(0.68)).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
