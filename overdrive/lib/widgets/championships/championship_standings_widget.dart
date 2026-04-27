/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_standings_widget.dart - Reusable championship standings card.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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

@immutable
class ChampionshipStandingsSection {
  const ChampionshipStandingsSection({
    required this.label,
    required this.entries,
    this.leadingColumnLabel = 'Nom',
    this.middleColumnLabel,
    this.trailingColumnLabel = 'PTS',
  });

  final String label;
  final String leadingColumnLabel;
  final String? middleColumnLabel;
  final String trailingColumnLabel;
  final List<ChampionshipStandingEntry> entries;
}

class ChampionshipStandingsWidget extends StatefulWidget {
  const ChampionshipStandingsWidget({
    required this.title,
    required this.sections,
    this.initialSectionIndex = 0,
    super.key,
  });

  final String title;
  final List<ChampionshipStandingsSection> sections;
  final int initialSectionIndex;

  @override
  State<ChampionshipStandingsWidget> createState() =>
      _ChampionshipStandingsWidgetState();
}

class _ChampionshipStandingsWidgetState
    extends State<ChampionshipStandingsWidget> {
  late int _selectedSectionIndex;

  @override
  void initState() {
    super.initState();
    _selectedSectionIndex = _clampIndex(widget.initialSectionIndex);
  }

  @override
  void didUpdateWidget(covariant ChampionshipStandingsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedSectionIndex = _clampIndex(_selectedSectionIndex);
  }

  int _clampIndex(int index) {
    if (widget.sections.isEmpty) {
      return 0;
    }

    return index.clamp(0, widget.sections.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentSection = widget.sections[_selectedSectionIndex];
    final shouldShowSwitch = widget.sections.length > 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
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
    );
  }
}

class _StandingsSwitch extends StatelessWidget {
  const _StandingsSwitch({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ChampionshipStandingsSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var index = 0; index < sections.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sections[index].label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyBold().copyWith(
                      fontSize: 12,
                      color: selectedIndex == index
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
            width: 32,
            child: Text(
              section.middleColumnLabel!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 13),
            ),
          ),
        SizedBox(
          width: 42,
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
            showMiddleValue: section.middleColumnLabel != null,
          ),
          if (index < section.entries.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.entry, required this.showMiddleValue});

  final ChampionshipStandingEntry entry;
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
            width: 32,
            child: Text(
              entry.middleValue ?? '-',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyBold().copyWith(fontSize: 14),
            ),
          ),
        SizedBox(
          width: 42,
          child: Text(
            entry.trailingValue,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyBold(
              color: AppColors.accent,
            ).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _EntryAvatar extends StatelessWidget {
  const _EntryAvatar({required this.entry});

  final ChampionshipStandingEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = entry.avatarLabel ?? _buildInitials(entry.title);

    return CircleAvatar(
      radius: 13,
      backgroundColor: entry.avatarColor,
      foregroundImage: entry.imageUrl != null
          ? NetworkImage(entry.imageUrl!)
          : null,
      child: Text(label, style: AppTextStyles.bodyBold().copyWith(fontSize: 8)),
    );
  }

  String _buildInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
