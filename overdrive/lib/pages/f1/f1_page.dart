/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## f1_page.dart - F1 event details and championship standings.
 ##
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/top_left_menu_overlay.dart';
import '../../widgets/glass_card.dart';

class F1Page extends StatefulWidget {
  const F1Page({super.key});

  @override
  State<F1Page> createState() => _F1PageState();
}

class _F1PageState extends State<F1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(height: 64),
                ),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text('🇨🇳', style: const TextStyle(fontSize: 38)),
                    const SizedBox(height: 10),
                    Text('China', style: AppTextStyles.heading()),
                    const SizedBox(height: 4),
                    Text(
                      'Shanghai International Circuit',
                      style: AppTextStyles.caption(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.glassDivider, height: 1),
                    ..._sessions.map((s) => _SessionTile(session: s)),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text('Standings', style: AppTextStyles.sectionTitle()),
                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const SizedBox(width: 22),
                          Expanded(
                            child: Text(
                              'DRIVER',
                              style: AppTextStyles.label(),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('W', style: AppTextStyles.label(), textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text('PTS', style: AppTextStyles.label(), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: AppColors.glassDivider, height: 1),

                    ..._drivers.map((d) => _DriverTile(driver: d)),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          const TopLeftMenuOverlay(),
        ],
      ),
    );
  }
}


class _SessionData {
  const _SessionData(this.name, this.date, this.time);
  final String name, date, time;
}

class _DriverData {
  const _DriverData(this.pos, this.name, this.team, this.flag, this.teamColor, this.wins, this.pts);
  final int pos, wins, pts;
  final String name, team, flag;
  final Color teamColor;
}

const List<_SessionData> _sessions = [
  _SessionData('Sprint Qualifying', 'Fri. 13 Mar', '08:30'),
  _SessionData('Sprint',            'Sat. 14 Mar', '04:00'),
  _SessionData('Qualifying',        'Sat. 14 Mar', '08:00'),
  _SessionData('Race',              'Sun. 15 Mar', '08:00'),
];

const List<_DriverData> _drivers = [
  _DriverData(1,  'G. Russell',    'Mercedes',     '🇬🇧', AppColors.teamMercedes, 2, 44),
  _DriverData(2,  'K. Antonelli',  'Mercedes',     '🇮🇹', AppColors.teamMercedes, 0, 27),
  _DriverData(3,  'C. Leclerc',    'Ferrari',      '🇲🇨', AppColors.teamFerrari,  1, 36),
  _DriverData(4,  'L. Hamilton',   'Ferrari',      '🇬🇧', AppColors.teamFerrari,  0, 30),
  _DriverData(5,  'M. Verstappen', 'Red Bull',     '🇳🇱', AppColors.teamRedBull,  1, 29),
  _DriverData(6,  'L. Lawson',     'Red Bull',     '🇳🇿', AppColors.teamRedBull,  0, 24),
  _DriverData(7,  'L. Norris',     'McLaren',      '🇬🇧', AppColors.teamMcLaren,  0, 21),
  _DriverData(8,  'O. Piastri',    'McLaren',      '🇦🇺', AppColors.teamMcLaren,  0, 18),
  _DriverData(9,  'F. Alonso',     'Aston Martin', '🇪🇸', AppColors.teamAston,    0, 16),
  _DriverData(10, 'L. Stroll',     'Aston Martin', '🇨🇦', AppColors.teamAston,    0, 12),
  _DriverData(11, 'A. Albon',      'Williams',     '🇹🇭', AppColors.teamWilliams, 0, 10),
  _DriverData(12, 'C. Sainz',      'Williams',     '🇪🇸', AppColors.teamWilliams, 0,  8),
  _DriverData(13, 'P. Gasly',      'Alpine',       '🇫🇷', Color(0xFF0090FF),      0,  6),
  _DriverData(14, 'J. Doohan',     'Alpine',       '🇦🇺', Color(0xFF0090FF),      0,  5),
  _DriverData(15, 'Y. Tsunoda',    'RB',           '🇯🇵', Color(0xFF3554D1),      0,  4),
  _DriverData(16, 'I. Hadjar',     'RB',           '🇫🇷', Color(0xFF3554D1),      0,  3),
  _DriverData(17, 'E. Ocon',       'Haas',         '🇫🇷', Color(0xFFB6BABD),      0,  2),
  _DriverData(18, 'O. Bearman',    'Haas',         '🇬🇧', Color(0xFFB6BABD),      0,  2),
  _DriverData(19, 'N. Hulkenberg', 'Sauber',       '🇩🇪', AppColors.teamSauber,   0,  1),
  _DriverData(20, 'G. Bortoleto',  'Sauber',       '🇧🇷', AppColors.teamSauber,   0,  0),
];


class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final _SessionData session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(session.name, style: AppTextStyles.body())),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(session.date, style: AppTextStyles.caption()),
                  Text(session.time, style: AppTextStyles.caption()),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.glassDivider, height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({required this.driver});
  final _DriverData driver;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text('${driver.pos}', style: AppTextStyles.bodyBold()),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: driver.teamColor.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: driver.teamColor.withOpacity(0.55), width: 1.5),
                ),
                child: Center(child: Text(driver.flag, style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: AppTextStyles.bodyBold()),
                    Text(driver.team, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              SizedBox(
                width: 32,
                child: Text('${driver.wins}', textAlign: TextAlign.center, style: AppTextStyles.bodyBold()),
              ),
              SizedBox(
                width: 44,
                child: Text('${driver.pts}', textAlign: TextAlign.right, style: AppTextStyles.bodyBold()),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.glassDivider, height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
