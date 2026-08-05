/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_detail_page.dart - Replay visualization page: a trimmed copy of ChampionshipPage
 ## (no live race state, no championship switcher, no library button) with TV and Telemetrie access.
 ##
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../services/championship/championship_standing.dart';
import '../../services/replay/replay_item.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/championships/championship_circuit_weather.dart';
import '../../widgets/championships/championship_standings.dart' as standings_ui;

/// Pre-race info for a single replay, with quick access to TV and telemetry.
class ReplayDetailPage extends StatelessWidget {
  const ReplayDetailPage({super.key, required this.replay});

  final ReplayItem replay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _ReplayBackground(id: replay.championshipId)),
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
                          child: _PageHero(replay: replay),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: AppButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  ..._buildSections(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the visible content blocks in the order used by the page.
  List<Widget> _buildSections(BuildContext context) {
    final blocks = <Widget>[
      ChampionshipCircuitWeatherCard(circuit: replay.circuit, weather: replay.weather),
      _Section(
        label: 'Acces',
        child: _ReplayActionButtons(replay: replay),
      ),
      if (replay.standings.isNotEmpty) _StandingsBlock(tables: replay.standings),
    ];

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
}

/// Hero block containing the race headline and its meta line.
class _PageHero extends StatelessWidget {
  const _PageHero({required this.replay});

  final ReplayItem replay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          replay.raceName,
          style: AppTextStyles.bodyBold().copyWith(
            fontSize: 24,
            height: 1.05,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${replay.circuit.name} · ${replay.circuit.location}',
                style: AppTextStyles.body(
                  color: AppColors.textSecondary,
                ).copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Small labeled section wrapper, matching the championship page sections.
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

/// Vertical spacer between sections.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 18);
  }
}

/// TV and Telemetrie quick actions, matching the championship page's live action buttons.
class _ReplayActionButtons extends StatelessWidget {
  const _ReplayActionButtons({required this.replay});

  final ReplayItem replay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            icon: Icons.live_tv_outlined,
            label: 'TV',
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

// ── Standings — copied from ChampionshipPage's season-standings rendering ──

/// Adapts season standings tables to the reusable standings widget, grouped by
/// category (e.g. Hypercar / LMP2 / GT3) exactly like the championship page.
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

/// View data for one standings card rendered on the replay detail page.
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

// ── Background gradient — copied from ChampionshipPage's per-championship bloom ──

/// Full-screen gradient background keyed to the replay's championship identity.
class _ReplayBackground extends StatelessWidget {
  const _ReplayBackground({required this.id});

  final String id;

  static const _kStops3 = [0.0, 0.28, 0.62];
  static const _kStops2 = [0.0, 0.55];

  static LinearGradient _gradientFor(String id) => switch (id) {
    'formula_1' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x42E80000),
        Color(0x12FFFFFF),
        Color(0x00000000),
      ],
      stops: _kStops3,
    ),
    'wec' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x421B52D4),
        Color(0x12FFFFFF),
        Color(0x00000000),
      ],
      stops: _kStops3,
    ),
    'motogp' => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x52CC0000),
        Color(0x00000000),
      ],
      stops: _kStops2,
    ),
    _ => const LinearGradient(
      colors: [Color(0x00000000), Color(0x00000000)],
    ),
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
