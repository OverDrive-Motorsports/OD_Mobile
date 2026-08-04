/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [race_standings.dart] - Telemetry widget listing race positions, gaps to leader, and position trends for all drivers.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

// Returns a hardcoded team colour for the three main constructors; all others fall back to gold.
Color _teamColor(String team) => switch (team) {
  'Red Bull Racing' => const Color(0xFF3671C6),
  'Ferrari' => const Color(0xFFE8002D),
  'McLaren' => const Color(0xFFFF8000),
  _ => AppColors.gold,
};

// ── Public widget ──────────────────────────────────────────────────────────

// Stateless root widget — standings are global data, so no per-driver selector is required.
class RaceStandings extends StatelessWidget {
  const RaceStandings({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<TelemetrySimulator>();

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Standings',
          onReset: actions?.onReset,
          onRemove: actions?.onRemove,
        );
      },
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallStandings(sim: sim)
                  : _LargeStandings(
                      sim: sim,
                      availableHeight: constraints.maxHeight,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallStandings extends StatelessWidget {
  const _SmallStandings({required this.sim});
  final TelemetrySimulator sim;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'STANDINGS'),
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final driver in TelemetryMockData.drivers)
                _DriverRowCompact(
                  driver: driver,
                  snapshot: sim.getSnapshot(driver['id'] as String),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Large — scales with height ─────────────────────────────────────────────────

// Calculates how many full driver rows (≈ 62 px each) fit in the available height and renders only those.
class _LargeStandings extends StatelessWidget {
  const _LargeStandings({required this.sim, required this.availableHeight});
  final TelemetrySimulator sim;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    // How many rows fit? Each full row is ~56px + 6px gap; header ~20px
    final usable = availableHeight - 32;
    final rowsVisible = (usable / 62).floor().clamp(
      1,
      TelemetryMockData.drivers.length,
    );
    final drivers = TelemetryMockData.drivers.take(rowsVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'STANDINGS'),
        const SizedBox(height: 8),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < drivers.length; i++) ...[
                if (i > 0) const SizedBox(height: 5),
                Expanded(
                  child: _DriverRowFull(
                    driver: drivers[i],
                    snapshot: sim.getSnapshot(drivers[i]['id'] as String),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Compact row (small mode + large mode base) ────────────────────────────────

class _DriverRowCompact extends StatelessWidget {
  const _DriverRowCompact({required this.driver, required this.snapshot});
  final Map<String, dynamic> driver;
  final TelemetrySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final tc = _teamColor(driver['team'] as String);

    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: tc,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'P${driver['position']}',
          style: AppTextStyles.label(
            color: tc,
          ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 6),
        Text(
          driver['id'] as String,
          style: AppTextStyles.label(
            color: AppColors.textPrimary,
          ).copyWith(fontSize: 10),
        ),
        const Spacer(),
        Text(
          snapshot.gapToLeader,
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 9),
        ),
      ],
    );
  }
}

// ── Full row (large mode) ──────────────────────────────────────────────────────

// Expanded driver row with team-coloured left border, trend arrow, and gap readout.
class _DriverRowFull extends StatelessWidget {
  const _DriverRowFull({required this.driver, required this.snapshot});
  final Map<String, dynamic> driver;
  final TelemetrySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final tc = _teamColor(driver['team'] as String);
    final (trendIcon, trendColor) = switch (snapshot.trend) {
      'gaining' => (Icons.arrow_upward_rounded, AppColors.green),
      'losing' => (Icons.arrow_downward_rounded, AppColors.red),
      _ => (Icons.remove_rounded, AppColors.textMuted),
    };

    return Container(
      decoration: BoxDecoration(
        color: tc.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: tc, width: 2.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          // Position
          Text(
            'P${driver['position']}',
            style: AppTextStyles.bodyBold(color: tc).copyWith(fontSize: 15),
          ),
          const SizedBox(width: 10),
          // Name + team
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  driver['id'] as String,
                  style: AppTextStyles.bodyBold(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 11),
                ),
                Text(
                  driver['team'] as String,
                  style: AppTextStyles.caption(
                    color: AppColors.textMuted,
                  ).copyWith(fontSize: 8),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Trend icon
          Icon(trendIcon, size: 11, color: trendColor),
          const SizedBox(width: 6),
          // Gap
          SizedBox(
            width: 44,
            child: Text(
              snapshot.gapToLeader,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyBold(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
