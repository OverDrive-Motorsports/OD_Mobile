/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [sector_split.dart] - Telemetry widget displaying per-sector lap times with colour-coded delta vs. best.
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

// Formats a sector time in seconds to "S.mmm" notation; returns "—" when null.
String _fmtSector(double? t) {
  if (t == null) return '—';
  final s = t.floor();
  final ms = ((t % 1) * 1000).toInt();
  return '$s.${ms.toString().padLeft(3, '0')}';
}

// Maps a sector time to a status colour: gold = personal best, green = near-best, red = slow.
Color _sectorColor(double? time, double best) {
  if (time == null) return AppColors.textMuted;
  final d = time - best;
  if (d < -0.01) return AppColors.gold;
  if (d < 0.08) return AppColors.green;
  return AppColors.red;
}

// ── Public widget ──────────────────────────────────────────────────────────

// Root stateful widget; holds the selected driver and delegates layout to small/large sub-widgets.
class SectorSplit extends StatefulWidget {
  const SectorSplit({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<SectorSplit> createState() => _SectorSplitState();
}

class _SectorSplitState extends State<SectorSplit> {
  late String _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  void _showMenu(BuildContext context) {
    final actions = TelemetryItemActions.maybeOf(context);
    showTelemetryWidgetMenu(
      context,
      widgetLabel: 'Sector Split',
      currentDriverId: _driverId,
      onDriverSelected: (id) => setState(() => _driverId = id),
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: mode == TelemetryMode.small
                  ? _SmallSectors(data: data, driverId: _driverId)
                  : _LargeSectors(data: data, driverId: _driverId),
            );
          },
        ),
      ),
    );
  }
}

// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallSectors extends StatelessWidget {
  const _SmallSectors({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SECTORS', driverId: driverId),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: _SectorCard(
                    label: 'S${i + 1}',
                    time: data.sectorTimes[i],
                    best: data.bestSectorTimes[i],
                    large: false,
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeSectors extends StatelessWidget {
  const _LargeSectors({required this.data, required this.driverId});
  final TelemetrySnapshot data;
  final String driverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SECTORS', driverId: driverId),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: _SectorCard(
                    label: 'S${i + 1}',
                    time: data.sectorTimes[i],
                    best: data.bestSectorTimes[i],
                    large: true,
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        // Best times row
        const SizedBox(height: 8),
        Row(
          children: [
            Text('BEST', style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
            const Spacer(),
            for (var i = 0; i < 3; i++) ...[
              SizedBox(
                width: 46,
                child: Text(
                  _fmtSector(data.bestSectorTimes[i]),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Sector card ───────────────────────────────────────────────────────────────

class _SectorCard extends StatelessWidget {
  const _SectorCard({required this.label, required this.time, required this.best, required this.large});
  final String label;
  final double? time;
  final double best;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = _sectorColor(time, best);
    final formatted = _fmtSector(time);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: time != null ? color.withValues(alpha: 0.10) : AppColors.surface.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: time != null ? color.withValues(alpha: 0.45) : AppColors.border.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.textMuted).copyWith(fontSize: 9, letterSpacing: 0.4),
          ),
          SizedBox(height: large ? 6 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatted,
              style: AppTextStyles.bodyBold(color: time != null ? color : AppColors.textMuted)
                  .copyWith(fontSize: large ? 13 : 11),
            ),
          ),
          // Delta vs best — only show when completed and large mode
          if (large && time != null) ...[
            const SizedBox(height: 2),
            Text(
              _delta(time!, best),
              style: AppTextStyles.caption(color: color.withValues(alpha: 0.80)).copyWith(fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  String _delta(double time, double best) {
    final d = time - best;
    if (d < -0.01) return 'BEST';
    final sign = d >= 0 ? '+' : '';
    return '$sign${d.toStringAsFixed(3)}';
  }
}
