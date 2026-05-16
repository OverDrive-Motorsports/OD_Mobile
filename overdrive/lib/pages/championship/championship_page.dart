/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_page.dart - Adaptive championship screen rendered from mock data.
##
*/

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../pages/replay/replay_page.dart';
import '../../services/championship/championship_circuit.dart';
import '../../services/championship/championship_data.dart';
import '../../services/championship/championship_enums.dart';
import '../../services/championship/championship_live_entry.dart';
import '../../services/championship/championship_standing.dart';
import '../../widgets/championships/championship_replay_btn.dart';
import '../../widgets/championships/championship_schedule.dart';
import '../../widgets/championships/championship_standings_widget.dart'
    as standings_ui;
import '../../widgets/championships/championship_top3.dart';
import '../../widgets/menu_overlay.dart';

const Color _pageBackground = Color(0xFF0A0A0A);
const Color _cardBackground = Color(0xFF111111);
const Color _cardBorder = Color(0xFF1E1E1E);
const Color _mutedLabel = Color(0xFF555555);
const Color _mutedText = Color(0xFF666666);

class ChampionshipPage extends StatelessWidget {
  const ChampionshipPage({super.key, required this.data});

  final ChampionshipData data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final headline = _resolveHeadline(data);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: ColoredBox(
        color: _pageBackground,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 86, 0, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _PageHero(
                        data: data,
                        headline: headline,
                        now: now,
                      ),
                    ),
                    const SizedBox(height: 34),
                    ..._buildSections(context, now),
                  ],
                ),
              ),
            ),
            const MenuOverlay(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, DateTime now) {
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
        child: ChampionshipReplayBtn(
          replays: data.replays,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReplayPage(title: data.replays.label),
              ),
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

  Widget? _buildPrimaryBlock(DateTime now) {
    final liveGroups = data.liveGroups;
    if (liveGroups != null && liveGroups.isNotEmpty) {
      return _LiveOverviewCard(
        groups: liveGroups,
        accentColor: data.accentColor,
      );
    }

    if (data.circuit != null && data.weather != null) {
      return _CircuitWeatherCard(circuit: data.circuit, weather: data.weather);
    }

    if (data.nextEvent != null) {
      return _NextEventCard(nextEvent: data.nextEvent!, now: now);
    }

    return null;
  }
}

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
                    color: _mutedLabel,
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
        Icon(icon, color: const Color(0xFF878787), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(
              color: const Color(0xFF878787),
            ).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

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
              color: _mutedLabel,
            ).copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 18);
  }
}

class _LiveOverviewCard extends StatelessWidget {
  const _LiveOverviewCard({required this.groups, required this.accentColor});

  final List<ChampionshipLiveGroup> groups;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Direct'.toUpperCase(),
            style: AppTextStyles.label(
              color: _mutedLabel,
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
    );
  }
}

class _NextEventCard extends StatelessWidget {
  const _NextEventCard({required this.nextEvent, required this.now});

  final ChampionshipNextEvent nextEvent;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final countdown = _EventCountdown.from(nextEvent.startsAt.difference(now));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochain event'.toUpperCase(),
            style: AppTextStyles.label(
              color: _mutedLabel,
            ).copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 14),
          Text(
            nextEvent.name,
            style: AppTextStyles.bodyBold().copyWith(fontSize: 19),
          ),
          const SizedBox(height: 4),
          Text(
            nextEvent.location,
            style: AppTextStyles.body(
              color: _mutedLabel,
            ).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CountdownCell(value: countdown.days, label: 'Jours'),
              ),
              const _CountdownDot(),
              Expanded(
                child: _CountdownCell(value: countdown.hours, label: 'Heures'),
              ),
              const _CountdownDot(),
              Expanded(
                child: _CountdownCell(value: countdown.minutes, label: 'Min'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownCell extends StatelessWidget {
  const _CountdownCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: AppTextStyles.bodyBold().copyWith(fontSize: 24)),
        const SizedBox(height: 1),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.body(color: _mutedLabel).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _CountdownDot extends StatelessWidget {
  const _CountdownDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: AppTextStyles.body(
          color: const Color(0xFF2A2A2A),
        ).copyWith(fontSize: 24),
      ),
    );
  }
}

class _CircuitWeatherCard extends StatelessWidget {
  const _CircuitWeatherCard({required this.circuit, required this.weather});

  final ChampionshipCircuit? circuit;
  final ChampionshipWeather? weather;

  @override
  Widget build(BuildContext context) {
    if (circuit == null || weather == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Circuit · Meteo'.toUpperCase(),
            style: AppTextStyles.label(
              color: _mutedLabel,
            ).copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _MetricColumn(
                  label: 'Longueur',
                  value: '${circuit!.lengthKm.toStringAsFixed(3)} km',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _MetricColumn(
                  label: 'Tours',
                  value: '${circuit!.totalLaps}',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _MetricColumn(
                  label: 'Meteo',
                  value: '${weather!.rainChancePercent}%',
                  icon: weather!.rainChancePercent > 0
                      ? Icons.cloud_rounded
                      : Icons.wb_sunny_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: _cardBorder);
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body(
              color: _mutedLabel,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 4),
          if (icon == null)
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.bodyBold(
                  color: const Color(0xFFD3D3D3),
                ).copyWith(fontSize: 16, height: 1.1),
              ),
            )
          else
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: const Color(0xFFD3D3D3)),
                  const SizedBox(width: 3),
                  Text(
                    value,
                    style: AppTextStyles.bodyBold(
                      color: const Color(0xFFD3D3D3),
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StandingsBlock extends StatelessWidget {
  const _StandingsBlock({required this.tables});

  final List<ChampionshipStandingTable> tables;

  @override
  Widget build(BuildContext context) {
    final cards = _buildStandingCards(tables);

    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          standings_ui.ChampionshipStandingsWidget(
            title: cards[index].title,
            sections: cards[index].sections,
          ),
          if (index < cards.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _LiveActionButtons extends StatelessWidget {
  const _LiveActionButtons({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LiveActionButton(
            icon: Icons.live_tv_outlined,
            label: 'TV Live',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.tv),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LiveActionButton(
            icon: Icons.insights_outlined,
            label: 'Telemetrie',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.telemetry),
          ),
        ),
      ],
    );
  }
}

class _LiveActionButton extends StatelessWidget {
  const _LiveActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF222222)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _mutedText, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body(
                  color: _mutedText,
                ).copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveStandingsBlock extends StatelessWidget {
  const _LiveStandingsBlock({required this.groups, required this.title});

  final List<ChampionshipLiveGroup> groups;
  final String title;

  @override
  Widget build(BuildContext context) {
    return standings_ui.ChampionshipStandingsWidget(
      title: title,
      sections: [
        for (final group in groups) _buildLiveStandingSection(group, groups),
      ],
    );
  }
}

class _EventCountdown {
  const _EventCountdown({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  factory _EventCountdown.from(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    return _EventCountdown(
      days: safe.inDays,
      hours: safe.inHours.remainder(24),
      minutes: safe.inMinutes.remainder(60),
    );
  }

  final int days;
  final int hours;
  final int minutes;
}

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

String _buildEventMetaLine(ChampionshipData data) {
  final parts = <String>[];
  if (data.circuit != null) {
    parts.add(data.circuit!.name);
    parts.add(data.circuit!.location);
  }
  return parts.join(' · ');
}

String _buildOffSeasonMetaLine(ChampionshipData data, DateTime now) {
  final nextEvent = data.nextEvent;
  if (nextEvent == null) {
    return 'Inter-saison';
  }

  final duration = nextEvent.startsAt.difference(now);
  final days = math.max(duration.inDays, 0);
  return 'Prochain event dans $days jours';
}

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

class _StandingCardData {
  const _StandingCardData({required this.title, required this.sections});

  final String title;
  final List<standings_ui.ChampionshipStandingsSection> sections;
}

class _StandingLabelParts {
  const _StandingLabelParts({required this.sectionLabel, this.category});

  final String sectionLabel;
  final String? category;
}
