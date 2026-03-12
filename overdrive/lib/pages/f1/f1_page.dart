/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## f1_page.dart - F1 event details and championship standings.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/f1_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/top_left_menu_overlay.dart';

class F1Page extends StatefulWidget {
  const F1Page({super.key});

  @override
  State<F1Page> createState() => _F1PageState();
}

class _F1PageState extends State<F1Page> {
  final F1Service _f1Service = F1Service();

  bool _isLoading = true;
  String? _errorMessage;
  List<DriverStanding> _standings = const [];

  @override
  void initState() {
    super.initState();
    _loadDriverStandings();
  }

  Future<void> _loadDriverStandings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _f1Service.getDriverStandings();
    if (!mounted) {
      return;
    }

    if (response.isSuccess) {
      setState(() {
        _standings = response.data ?? const [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _standings = const [];
      _isLoading = false;
      _errorMessage = response.error ?? 'Failed to load standings';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
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
                        const Text('🇨🇳', style: TextStyle(fontSize: 38)),
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
                              SizedBox(
                                width: 34,
                                child: Text('POS', style: AppTextStyles.label()),
                              ),
                              Expanded(
                                child: Text(
                                  'PILOTE',
                                  style: AppTextStyles.label(),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  'PTS',
                                  style: AppTextStyles.label(),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Divider(color: AppColors.glassDivider, height: 1),
                        _StandingsBody(
                          isLoading: _isLoading,
                          errorMessage: _errorMessage,
                          standings: _standings,
                          onRetry: _loadDriverStandings,
                        ),
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

class _StandingsBody extends StatelessWidget {
  const _StandingsBody({
    required this.isLoading,
    required this.errorMessage,
    required this.standings,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<DriverStanding> standings;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                onRetry();
              },
              child: Text(
                'Réessayer',
                style: AppTextStyles.captionBold(color: AppColors.gold),
              ),
            ),
          ],
        ),
      );
    }

    if (standings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Text(
          'Aucune donnée de classement.',
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        ...standings.map((d) => _DriverTile(driver: d)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SessionData {
  const _SessionData(this.name, this.date, this.time);

  final String name;
  final String date;
  final String time;
}

const List<_SessionData> _sessions = [
  _SessionData('Sprint Qualifying', 'Fri. 13 Mar', '08:30'),
  _SessionData('Sprint', 'Sat. 14 Mar', '04:00'),
  _SessionData('Qualifying', 'Sat. 14 Mar', '08:00'),
  _SessionData('Race', 'Sun. 15 Mar', '08:00'),
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
        const Divider(
          color: AppColors.glassDivider,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({required this.driver});

  final DriverStanding driver;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text('${driver.position}', style: AppTextStyles.bodyBold()),
              ),
              Expanded(
                child: Text(driver.driverName, style: AppTextStyles.bodyBold()),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  driver.pointsLabel,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold(),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.glassDivider,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
