/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_standings.dart - Standings table widget rendering driver or team points entries.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_theme.dart';

// ── Glass themes ──────────────────────────────────────────────────────────

const _kBorderColor = Color(0x26FFFFFF);

final _kCardTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.20,
  blurSigma: 28.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.05,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kSwitchTrackTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.12,
  blurSigma: 14.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.06,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

// ── Data models ───────────────────────────────────────────────────────────

/// A single row item used in a standings section.
@immutable
class ChampionshipStandingEntry {
  const ChampionshipStandingEntry({
    required this.position,
    required this.title,
    required this.trailingValue,
    this.subtitle,
    this.middleValue,
    this.imageUrl,
    this.avatarLabel,
    this.avatarColor = AppColors.surface,
  });

  final int position;
  final String title;
  final String trailingValue;
  final String? subtitle;
  final String? middleValue;
  final String? imageUrl;
  final String? avatarLabel;
  final Color avatarColor;
}

/// A group of standings entries with column labels.
@immutable
class ChampionshipStandingsSection {
  const ChampionshipStandingsSection({
    required this.label,
    required this.entries,
    this.leadingColumnLabel = 'Nom',
    this.middleColumnLabel,
    this.trailingColumnLabel = 'PTS',
    this.middleColumnWidth = 32,
    this.trailingColumnWidth = 42,
  });

  final String label;
  final String leadingColumnLabel;
  final String? middleColumnLabel;
  final String trailingColumnLabel;
  final double middleColumnWidth;
  final double trailingColumnWidth;
  final List<ChampionshipStandingEntry> entries;
}

// ── ChampionshipStandings ─────────────────────────────────────────────────

/// A standings card that can switch between multiple sections.
class ChampionshipStandings extends StatefulWidget {
  const ChampionshipStandings({
    required this.title,
    required this.sections,
    this.initialSectionIndex = 0,
    super.key,
  });

  final String title;
  final List<ChampionshipStandingsSection> sections;
  final int initialSectionIndex;

  @override
  State<ChampionshipStandings> createState() => _ChampionshipStandingsState();
}

class _ChampionshipStandingsState extends State<ChampionshipStandings> {
  late int _selectedSectionIndex;

  @override
  void initState() {
    super.initState();
    _selectedSectionIndex = _clampIndex(widget.initialSectionIndex);
  }

  @override
  void didUpdateWidget(covariant ChampionshipStandings oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedSectionIndex = _clampIndex(_selectedSectionIndex);
  }

  int _clampIndex(int index) {
    if (widget.sections.isEmpty) return 0;
    return index.clamp(0, widget.sections.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty) return const SizedBox.shrink();

    final currentSection = widget.sections[_selectedSectionIndex];
    final shouldShowSwitch = widget.sections.length > 1;

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kCardTheme,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyBold().copyWith(fontSize: 19),
              ),
              const SizedBox(height: 16),
              if (shouldShowSwitch) ...[
                _StandingsSwitch(
                  sections: widget.sections,
                  selectedIndex: _selectedSectionIndex,
                  onSelected: (index) {
                    setState(() => _selectedSectionIndex = index);
                  },
                ),
                const SizedBox(height: 16),
              ],
              _StandingsHeader(section: currentSection),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: _StandingsList(
                  key: ValueKey<String>(currentSection.label),
                  section: currentSection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _StandingsSwitch — spring-physics liquid pill selector ────────────────

// Spring-physics pill selector that switches between standings sections (e.g. Drivers / Teams).
class _StandingsSwitch extends StatefulWidget {
  const _StandingsSwitch({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ChampionshipStandingsSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_StandingsSwitch> createState() => _StandingsSwitchState();
}

class _StandingsSwitchState extends State<_StandingsSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final ValueNotifier<double> _position;
  late final ValueNotifier<double> _velocity;

  // Same spring constants as the navbar pill.
  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 320.0,
    damping: 22.0,
  );

  int get _tabCount => widget.sections.length;

  @override
  void initState() {
    super.initState();
    final initial = widget.selectedIndex.toDouble();
    _position = ValueNotifier(initial);
    _velocity = ValueNotifier(0.0);
    _ctrl = AnimationController.unbounded(vsync: this, value: initial)
      ..addListener(() {
        _position.value = _ctrl.value;
        _velocity.value = _ctrl.velocity;
      });
  }

  @override
  void didUpdateWidget(_StandingsSwitch old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _ctrl.animateWith(SpringSimulation(
        _spring,
        _position.value,
        widget.selectedIndex.toDouble(),
        _velocity.value,
      ));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _position.dispose();
    _velocity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: CupertinoLiquidGlass(
        theme: _kSwitchTrackTheme,
        borderRadius: BorderRadius.circular(999),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth;
            return Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _SwitchPillPainter(
                      position: _position,
                      velocity: _velocity,
                      tabCount: _tabCount,
                    ),
                    size: Size(contentWidth, 34),
                  ),
                ),
                Row(
                  children: List.generate(_tabCount, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: _SwitchLabel(
                            index: index,
                            label: widget.sections[index].label,
                            position: _position,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── _SwitchLabel — label that fades white as its tab becomes active ────────

// Section tab label that interpolates from secondary to white as its tab becomes active.
class _SwitchLabel extends StatelessWidget {
  const _SwitchLabel({
    required this.index,
    required this.label,
    required this.position,
  });

  final int index;
  final String label;
  final ValueListenable<double> position;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: position,
      builder: (context, _) {
        final proximity =
            (1.0 - (position.value - index).abs()).clamp(0.0, 1.0);
        final color =
            Color.lerp(AppColors.textSecondary, AppColors.white, proximity)!;
        return Text(
          label,
          style:
              AppTextStyles.bodyBold().copyWith(fontSize: 12, color: color),
        );
      },
    );
  }
}

// ── _SwitchPillPainter — velocity-stretched pill (same logic as navbar) ───

// Velocity-stretched pill painter — same elastic logic as the navbar _SelectorPainter.
class _SwitchPillPainter extends CustomPainter {
  _SwitchPillPainter({
    required this.position,
    required this.velocity,
    required this.tabCount,
  }) : super(repaint: Listenable.merge([position, velocity]));

  final ValueListenable<double> position;
  final ValueListenable<double> velocity;
  final int tabCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (tabCount == 0) return;

    final pos = position.value;
    final vel = velocity.value;
    final tabWidth = size.width / tabCount;

    // Velocity-based stretch: faster → wider pill (max ~1.36×).
    final absVel = vel.abs().clamp(0.0, 20.0);
    final stretch = 1.0 + absVel / 55.0;

    final baseWidth = tabWidth * 0.88;
    final selectorWidth = baseWidth * stretch;
    final x = pos * tabWidth + (tabWidth - selectorWidth) / 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, 2.0, selectorWidth, size.height - 4.0),
      const Radius.circular(999.0),
    );

    // Translucent fill.
    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.white.withValues(alpha: 0.18),
    );

    // Inner top-edge highlight for depth.
    canvas.drawRRect(
      rrect.deflate(0.25),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.25),
            AppColors.white.withValues(alpha: 0.05),
          ],
        ).createShader(rrect.outerRect),
    );
  }

  @override
  bool shouldRepaint(_SwitchPillPainter old) => tabCount != old.tabCount;
}

// ── _StandingsHeader ──────────────────────────────────────────────────────

// Column-label row (position, name, optional middle, points) aligned with the entry rows below.
class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader({required this.section});

  final ChampionshipStandingsSection section;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            section.leadingColumnLabel,
            style: AppTextStyles.body(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 13),
          ),
        ),
        if (section.middleColumnLabel != null)
          SizedBox(
            width: section.middleColumnWidth,
            child: Text(
              section.middleColumnLabel!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 13),
            ),
          ),
        SizedBox(
          width: section.trailingColumnWidth,
          child: Text(
            section.trailingColumnLabel,
            textAlign: TextAlign.right,
            style: AppTextStyles.body(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ── _StandingsList ────────────────────────────────────────────────────────

// Vertical list of _StandingRow widgets for the active section, keyed for AnimatedSwitcher.
class _StandingsList extends StatelessWidget {
  const _StandingsList({required this.section, super.key});

  final ChampionshipStandingsSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        for (var index = 0; index < section.entries.length; index++) ...[
          _StandingRow(
            entry: section.entries[index],
            section: section,
            showMiddleValue: section.middleColumnLabel != null,
          ),
          if (index < section.entries.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ── _StandingRow ──────────────────────────────────────────────────────────

// Single standings row: position number, avatar, name/subtitle, optional middle value, and points.
class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.entry,
    required this.section,
    required this.showMiddleValue,
  });

  final ChampionshipStandingEntry entry;
  final ChampionshipStandingsSection section;
  final bool showMiddleValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '${entry.position}',
            style: AppTextStyles.bodyBold().copyWith(fontSize: 14),
          ),
        ),
        _EntryAvatar(entry: entry),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyBold().copyWith(fontSize: 16),
              ),
              if (entry.subtitle != null && entry.subtitle!.trim().isNotEmpty)
                Text(
                  entry.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 12),
                ),
            ],
          ),
        ),
        if (showMiddleValue)
          SizedBox(
            width: section.middleColumnWidth,
            child: Text(
              entry.middleValue ?? '-',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyBold().copyWith(fontSize: 14),
            ),
          ),
        SizedBox(
          width: section.trailingColumnWidth,
          child: Text(
            entry.trailingValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyBold(
              color: AppColors.gold,
            ).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ── _EntryAvatar ──────────────────────────────────────────────────────────

// Circular avatar that shows a network image when available, falling back to two-letter initials.
class _EntryAvatar extends StatelessWidget {
  const _EntryAvatar({required this.entry});

  final ChampionshipStandingEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = entry.avatarLabel ?? _buildInitials(entry.title);

    return CircleAvatar(
      radius: 13,
      backgroundColor: entry.avatarColor,
      foregroundImage:
          entry.imageUrl != null ? NetworkImage(entry.imageUrl!) : null,
      child:
          Text(label, style: AppTextStyles.bodyBold().copyWith(fontSize: 8)),
    );
  }

  String _buildInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
