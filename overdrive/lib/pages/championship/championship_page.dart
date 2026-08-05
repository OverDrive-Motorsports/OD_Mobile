/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_page.dart - Adaptive championship page rendering live timing, event-weekend, or off-season layouts from ChampionshipData.
 ##
 */

import 'dart:math' as math;

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../pages/replay/replay_page.dart';
import '../../services/championship/championship_data.dart';
import '../../services/championship/championship_enums.dart';
import '../../services/championship/championship_live_entry.dart';
import '../../services/championship/championship_mock_data.dart';
import '../../services/championship/championship_standing.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/base/menu_overlay.dart';
import '../../widgets/championships/championship_circuit_weather.dart';
import '../../widgets/championships/championship_next_event.dart';
import '../../widgets/championships/championship_schedule.dart';
import '../../widgets/championships/championship_standings.dart'
    as standings_ui;
import '../../widgets/championships/championship_top3.dart';

const List<MenuOverlayItem> _championshipMenuItems = [
  MenuOverlayItem(label: 'Formule 1', icon: Icons.sports_motorsports_outlined),
  MenuOverlayItem(label: 'WEC', icon: Icons.directions_car_outlined),
  MenuOverlayItem(label: 'MotoGP', icon: Icons.two_wheeler_outlined),
];

/// Adaptive championship screen rendered from a single data payload.
class ChampionshipPage extends StatefulWidget {
  const ChampionshipPage({super.key, required this.data});

  final ChampionshipData data;

  @override
  State<ChampionshipPage> createState() => _ChampionshipPageState();
}

class _ChampionshipPageState extends State<ChampionshipPage> {
  late ChampionshipData _selectedData;

  @override
  void initState() {
    super.initState();
    _selectedData = widget.data;
  }

  int get _selectedMenuIndex =>
      championshipMocks.indexWhere((d) => d.id == _selectedData.id);

  void _onChampionshipSelected(int index) {
    setState(() => _selectedData = championshipMocks[index]);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final headline = _resolveHeadline(_selectedData);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _ChampionshipBackground(
                key: ValueKey(_selectedData.id),
                id: _selectedData.id,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 44),
                          child: _PageHero(
                            data: _selectedData,
                            headline: headline,
                            now: now,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: MenuOverlayButton(
                            items: _championshipMenuItems,
                            selectedIndex: _selectedMenuIndex.clamp(
                              0,
                              _championshipMenuItems.length - 1,
                            ),
                            onSelected: _onChampionshipSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  ..._buildSections(context, now),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the visible content blocks in the order used by the page.
  List<Widget> _buildSections(BuildContext context, DateTime now) {
    final data = _selectedData;
    final blocks = <Widget>[];
    final primaryBlock = _buildPrimaryBlock(now);
    if (primaryBlock != null) {
      blocks.add(primaryBlock);
    }

    final schedule = data.schedule;
    if (schedule != null && schedule.isNotEmpty) {
      blocks.add(ChampionshipSchedule(sessions: schedule, now: now));
    }

    if (data.state == ChampionshipState.liveSession) {
      final liveGroups = data.liveGroups ?? const <ChampionshipLiveGroup>[];
      if (liveGroups.isNotEmpty) {
        blocks.add(
          _LiveStandingsBlock(
            groups: liveGroups,
            title: _buildLiveStandingsTitle(data),
          ),
        );
      }
    } else if (data.standings.isNotEmpty) {
      blocks.add(_StandingsBlock(tables: data.standings));
    }

    blocks.add(
      _Section(
        label: 'Replays',
        child: AppButton(
          label: data.replays.label,
          icon: Icons.play_arrow_rounded,
          fullWidth: true,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReplayPage()),
            );
          },
        ),
      ),
    );

    return [
      for (var index = 0; index < blocks.length; index++) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: blocks[index],
        ),
        if (index < blocks.length - 1) const _SectionDivider(),
      ],
    ];
  }

  /// Resolves the state-specific leading card shown below the hero.
  Widget? _buildPrimaryBlock(DateTime now) {
    final data = _selectedData;
    final liveGroups = data.liveGroups;
    if (liveGroups != null && liveGroups.isNotEmpty) {
      return _LiveOverviewCard(
        groups: liveGroups,
        accentColor: data.accentColor,
      );
    }

    if (data.circuit != null && data.weather != null) {
      return ChampionshipCircuitWeatherCard(
        circuit: data.circuit!,
        weather: data.weather!,
      );
    }

    if (data.nextEvent != null) {
      return ChampionshipNextEventCard(nextEvent: data.nextEvent!, now: now);
    }

    return null;
  }
}

/// Hero block containing the championship headline and metadata line.
class _PageHero extends StatelessWidget {
  const _PageHero({
    required this.data,
    required this.headline,
    required this.now,
  });

  final ChampionshipData data;
  final String headline;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isLive = data.state == ChampionshipState.liveSession;
    final currentLap = _resolveCurrentLap(data.liveGroups);
    final totalLaps = data.circuit?.totalLaps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLive)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  headline,
                  style: AppTextStyles.bodyBold().copyWith(
                    fontSize: 24,
                    height: 1.05,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (currentLap != null && totalLaps != null) ...[
                const SizedBox(width: 10),
                Text(
                  'Tour $currentLap / $totalLaps',
                  style: AppTextStyles.body(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 18),
                ),
              ],
            ],
          )
        else
          Text(
            headline,
            style: AppTextStyles.bodyBold().copyWith(
              fontSize: 24,
              height: 1.05,
              color: AppColors.textPrimary,
            ),
          ),
        const SizedBox(height: 10),
        _HeroSubtitle(data: data, now: now),
      ],
    );
  }
}

/// Secondary hero line adapted to live, event-weekend, or off-season state.
class _HeroSubtitle extends StatelessWidget {
  const _HeroSubtitle({required this.data, required this.now});

  final ChampionshipData data;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (data.state) {
      ChampionshipState.liveSession => (
        Icons.location_on_outlined,
        _buildLiveMetaLine(data),
      ),
      ChampionshipState.eventWeekend => (
        Icons.location_on_outlined,
        _buildEventMetaLine(data),
      ),
      ChampionshipState.offSeason => (
        Icons.calendar_today_outlined,
        _buildOffSeasonMetaLine(data, now),
      ),
    };

    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// Small labeled section wrapper used by the championship content blocks.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              color: AppColors.textSecondary,
            ).copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Vertical spacer between championship sections.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 18);
  }
}

// ── Liquid glass theme — "Moyen+ — blanc, haut" ──────────────────────────

const _kLiveCardEdgeColor = Color(0x38FFFFFF);

final _kLiveCardTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.20,
  blurSigma: 26.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.12,
  vibrancyIntensity: 0.05,
  edgeLightColor: _kLiveCardEdgeColor,
  edgeShadowColor: _kLiveCardEdgeColor,
);

/// Live-session overview with top-three groups and quick action buttons.
class _LiveOverviewCard extends StatelessWidget {
  const _LiveOverviewCard({required this.groups, required this.accentColor});

  final List<ChampionshipLiveGroup> groups;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kLiveCardTheme,
        borderRadius: BorderRadius.circular(26),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct'.toUpperCase(),
                  style: AppTextStyles.label(
                    color: AppColors.textSecondary,
                  ).copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: 14),
                for (var index = 0; index < groups.length; index++) ...[
                  ChampionshipTop3(
                    entries: groups[index].entries,
                    accentColor: accentColor,
                    label: groups.length > 1 ? groups[index].label : null,
                  ),
                  if (index < groups.length - 1) const SizedBox(height: 14),
                ],
                const SizedBox(height: 16),
                _LiveActionButtons(accentColor: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of quick actions shown on live championship pages.
class _LiveActionButtons extends StatelessWidget {
  const _LiveActionButtons({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            icon: Icons.live_tv_outlined,
            label: 'TV Live',
            onPressed: () => context.push('/tv'),
            fullWidth: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            icon: Icons.insights_outlined,
            label: 'Telemetrie',
            onPressed: () => context.push('/telemetry'),
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

/// Adapts season standings tables to the reusable standings widget.
class _StandingsBlock extends StatelessWidget {
  const _StandingsBlock({required this.tables});

  final List<ChampionshipStandingTable> tables;

  @override
  Widget build(BuildContext context) {
    final cards = _buildStandingCards(tables);

    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          standings_ui.ChampionshipStandings(
            title: cards[index].title,
            sections: cards[index].sections,
          ),
          if (index < cards.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// Adapts live timing groups to the reusable standings widget.
class _LiveStandingsBlock extends StatelessWidget {
  const _LiveStandingsBlock({required this.groups, required this.title});

  final List<ChampionshipLiveGroup> groups;
  final String title;

  @override
  Widget build(BuildContext context) {
    return standings_ui.ChampionshipStandings(
      title: title,
      sections: [
        for (final group in groups) _buildLiveStandingSection(group, groups),
      ],
    );
  }
}

/// Resolves the hero headline from explicit copy or championship state.
String _resolveHeadline(ChampionshipData data) {
  if (data.headline != null && data.headline!.trim().isNotEmpty) {
    return data.headline!;
  }

  return switch (data.state) {
    ChampionshipState.liveSession => 'Course',
    ChampionshipState.eventWeekend => data.circuit?.name ?? data.name,
    ChampionshipState.offSeason => data.name,
  };
}

/// Builds the live metadata line shown under the hero headline.
String _buildLiveMetaLine(ChampionshipData data) {
  final parts = <String>[];
  if (data.circuit != null) {
    parts.add(data.circuit!.name);
  }
  if (data.weather != null) {
    parts.add('${data.weather!.trackTempC}°C');
    parts.add(data.weather!.condition);
  }
  return parts.join(' · ');
}

/// Builds the event-weekend metadata line shown under the hero headline.
String _buildEventMetaLine(ChampionshipData data) {
  final parts = <String>[];
  if (data.circuit != null) {
    parts.add(data.circuit!.name);
    parts.add(data.circuit!.location);
  }
  return parts.join(' · ');
}

/// Builds the off-season metadata line shown under the hero headline.
String _buildOffSeasonMetaLine(ChampionshipData data, DateTime now) {
  final nextEvent = data.nextEvent;
  if (nextEvent == null) {
    return 'Inter-saison';
  }

  final duration = nextEvent.startsAt.difference(now);
  final days = math.max(duration.inDays, 0);
  return 'Prochain event dans $days jours';
}

/// Builds the title used for live timing standings.
String _buildLiveStandingsTitle(ChampionshipData data) {
  final currentLap = _resolveCurrentLap(data.liveGroups);
  final totalLaps = data.circuit?.totalLaps;

  if (currentLap != null && totalLaps != null) {
    return 'Tour $currentLap / $totalLaps';
  }

  if (currentLap != null) {
    return 'Tour $currentLap';
  }

  return 'Classement';
}

/// Finds the highest lap currently present in live timing groups.
int? _resolveCurrentLap(List<ChampionshipLiveGroup>? groups) {
  if (groups == null || groups.isEmpty) {
    return null;
  }

  var maxLap = 0;
  for (final group in groups) {
    for (final entry in group.entries) {
      maxLap = math.max(maxLap, entry.lap);
    }
  }

  return maxLap == 0 ? null : maxLap;
}

/// Groups raw standings tables into cards understood by the UI layer.
List<_StandingCardData> _buildStandingCards(
  List<ChampionshipStandingTable> tables,
) {
  final groupedTables = <String, List<ChampionshipStandingTable>>{};

  for (final table in tables) {
    final parts = _parseStandingLabel(table.label);
    final key = parts.category ?? '';
    groupedTables
        .putIfAbsent(key, () => <ChampionshipStandingTable>[])
        .add(table);
  }

  if (groupedTables.length <= 1) {
    return <_StandingCardData>[
      _StandingCardData(
        title: 'Classement',
        sections: [for (final table in tables) _buildStandingSection(table)],
      ),
    ];
  }

  return [
    for (final entry in groupedTables.entries)
      _StandingCardData(
        title: entry.key.isEmpty ? 'Classement' : entry.key,
        sections: [
          for (final table in entry.value) _buildStandingSection(table),
        ],
      ),
  ];
}

/// Converts one season standings table into a reusable standings section.
standings_ui.ChampionshipStandingsSection _buildStandingSection(
  ChampionshipStandingTable table,
) {
  final parts = _parseStandingLabel(table.label);

  return standings_ui.ChampionshipStandingsSection(
    label: parts.sectionLabel,
    entries: [
      for (final entry in table.entries)
        standings_ui.ChampionshipStandingEntry(
          position: entry.position,
          title: entry.name,
          subtitle: entry.teamName,
          trailingValue: '${entry.points}',
        ),
    ],
  );
}

/// Splits a standing label into its section and optional category parts.
_StandingLabelParts _parseStandingLabel(String label) {
  final segments = label.split('—').map((segment) => segment.trim()).toList();

  if (segments.length >= 2) {
    return _StandingLabelParts(
      sectionLabel: segments.first,
      category: segments.sublist(1).join(' — ').trim(),
    );
  }

  return _StandingLabelParts(sectionLabel: label.trim());
}

/// Converts one live timing group into a reusable standings section.
standings_ui.ChampionshipStandingsSection _buildLiveStandingSection(
  ChampionshipLiveGroup group,
  List<ChampionshipLiveGroup> groups,
) {
  final resolvedLabel = group.label.trim().isNotEmpty
      ? group.label
      : groups.length > 1
      ? 'Groupe'
      : 'Direct';

  return standings_ui.ChampionshipStandingsSection(
    label: resolvedLabel,
    leadingColumnLabel: 'Pilote',
    middleColumnLabel: 'TR',
    trailingColumnLabel: 'GAP',
    middleColumnWidth: 34,
    trailingColumnWidth: 54,
    entries: [
      for (final entry in group.entries)
        standings_ui.ChampionshipStandingEntry(
          position: entry.position,
          title: entry.name,
          subtitle: entry.teamName,
          middleValue: '${entry.lap}',
          trailingValue: entry.gap,
        ),
    ],
  );
}

/// View data for one standings card rendered on the championship page.
class _StandingCardData {
  const _StandingCardData({required this.title, required this.sections});

  final String title;
  final List<standings_ui.ChampionshipStandingsSection> sections;
}

/// Parsed parts of a standings label.
class _StandingLabelParts {
  const _StandingLabelParts({required this.sectionLabel, this.category});

  final String sectionLabel;
  final String? category;
}

// ── Championship background gradient ──────────────────────────────────────

/// Full-screen gradient background keyed to the championship identity.
/// F1 → rouge/blanc bloom; WEC → bleu/blanc; MotoGP → rouge/noir.
class _ChampionshipBackground extends StatelessWidget {
  const _ChampionshipBackground({required this.id, super.key});

  final String id;

  static const _kStops3 = [0.0, 0.28, 0.62];
  static const _kStops2 = [0.0, 0.55];

  static LinearGradient _gradientFor(String id) => switch (id) {
    'formula_1' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x42E80000), // red bloom — ~26 % opacity
        Color(0x12FFFFFF), // white shimmer — ~7 %
        Color(0x00000000), // transparent → dark background shows through
      ],
      stops: _kStops3,
    ),
    'wec' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x421B52D4), // blue bloom — ~26 %
        Color(0x12FFFFFF), // white shimmer — ~7 %
        Color(0x00000000),
      ],
      stops: _kStops3,
    ),
    'motogp' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x52CC0000), // red bloom — ~32 %, deeper for the dramatic look
        Color(0x00000000),
      ],
      stops: _kStops2,
    ),
    _ => const LinearGradient(colors: [Color(0x00000000), Color(0x00000000)]),
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: _gradientFor(id),
      ),
      child: const SizedBox.expand(),
    );
  }
}
