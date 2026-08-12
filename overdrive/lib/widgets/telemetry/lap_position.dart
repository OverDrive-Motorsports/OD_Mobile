/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_position.dart - Scrollable multi-driver race-position history chart telemetry widget.
 ##
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Brand colors assigned to each tracked driver for consistent line rendering.
const _kDriverColors = {
  'VER': Color(0xFF3671C6),
  'LEC': Color(0xFFE8002D),
  'NOR': Color(0xFFFF8000),
};

// Root widget showing each driver's track position per lap in small or full scrollable mode.
class LapPosition extends StatefulWidget {
  const LapPosition({super.key});

  @override
  State<LapPosition> createState() => _LapPositionState();
}

class _LapPositionState extends State<LapPosition> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<TelemetrySimulator>();

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(
          context,
          widgetLabel: 'Lap Positions',
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
            final histories = {
              for (final id in ['VER', 'LEC', 'NOR'])
                id: sim.getPositionHistory(id),
            };

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(histories: histories),
                  const SizedBox(height: 8),
                  Expanded(
                    child: mode == TelemetryMode.small
                        ? _StaticChart(histories: histories, lastN: 12)
                        : _ScrollableChart(
                            histories: histories,
                            scroll: _scroll,
                          ),
                  ),
                  const SizedBox(height: 4),
                  _AxisLabel(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.histories});
  final Map<String, List<PositionData>> histories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'POSITIONS',
          style: AppTextStyles.label(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 10, letterSpacing: 0.6),
        ),
        const Spacer(),
        for (final entry in _kDriverColors.entries) ...[
          const SizedBox(width: 8),
          Container(width: 8, height: 2, color: entry.value),
          const SizedBox(width: 3),
          Text(
            entry.key,
            style: AppTextStyles.caption(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 8, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

// ── Axis hint ─────────────────────────────────────────────────────────────────

class _AxisLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'L1',
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 7),
        ),
        const Spacer(),
        Text(
          '← DÉFILER →',
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 7, letterSpacing: 0.5),
        ),
        const Spacer(),
        Text(
          'L${TelemetrySnapshot.totalLaps}',
          style: AppTextStyles.caption(
            color: AppColors.textMuted,
          ).copyWith(fontSize: 7),
        ),
      ],
    );
  }
}

// ── Small: static last-N chart ────────────────────────────────────────────────

class _StaticChart extends StatelessWidget {
  const _StaticChart({required this.histories, required this.lastN});
  final Map<String, List<PositionData>> histories;
  final int lastN;

  @override
  Widget build(BuildContext context) {
    final trimmed = {
      for (final e in histories.entries)
        e.key: e.value.length > lastN
            ? e.value.sublist(e.value.length - lastN)
            : e.value,
    };
    return CustomPaint(
      painter: _PositionPainter(histories: trimmed, showAllLaps: false),
      child: const SizedBox.expand(),
    );
  }
}

// ── Large: scrollable full chart ──────────────────────────────────────────────

class _ScrollableChart extends StatefulWidget {
  const _ScrollableChart({required this.histories, required this.scroll});
  final Map<String, List<PositionData>> histories;
  final ScrollController scroll;

  @override
  State<_ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<_ScrollableChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scroll.hasClients) {
        widget.scroll.jumpTo(widget.scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const pixPerLap = 14.0;
    final totalLaps = TelemetrySnapshot.totalLaps;
    final chartWidth = totalLaps * pixPerLap;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: widget.scroll,
      child: SizedBox(
        width: chartWidth,
        child: CustomPaint(
          painter: _PositionPainter(
            histories: widget.histories,
            showAllLaps: true,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ── Chart painter ─────────────────────────────────────────────────────────────

// CustomPainter that draws per-driver position step-lines with labels and grid overlay.
class _PositionPainter extends CustomPainter {
  const _PositionPainter({required this.histories, required this.showAllLaps});
  final Map<String, List<PositionData>> histories;
  final bool showAllLaps;

  static const int _positions = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final maxLap = showAllLaps
        ? TelemetrySnapshot.totalLaps
        : histories.values.fold<int>(
            1,
            (m, laps) => math.max(m, laps.isEmpty ? 1 : laps.last.lap),
          );

    // xOf: map lap number to x coordinate
    double xOf(int lap) => size.width * (lap - 1) / math.max(maxLap - 1, 1);
    // yOf: map position 1-3 to y coordinate (1=top, 3=bottom)
    double yOf(int pos) => size.height * (pos - 1) / (_positions - 1);

    // Position grid lines (P1 / P2 / P3)
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.40)
      ..strokeWidth = 0.5;

    for (var pos = 1; pos <= _positions; pos++) {
      final y = yOf(pos);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // P label on left
      final tp = TextPainter(
        text: TextSpan(
          text: 'P$pos',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 6),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - tp.height - 1));
    }

    // Lap markers every 5 laps
    final lapGridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.25)
      ..strokeWidth = 0.5;
    for (var lap = 5; lap <= maxLap; lap += 5) {
      final x = xOf(lap);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lapGridPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: 'L$lap',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 6),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, size.height - tp.height - 1));
    }

    // Driver lines
    for (final entry in histories.entries) {
      final laps = entry.value;
      if (laps.isEmpty) continue;
      final color = _kDriverColors[entry.key] ?? AppColors.textMuted;

      final path = Path();
      path.moveTo(xOf(laps.first.lap), yOf(laps.first.position));
      for (final lap in laps.skip(1)) {
        path.lineTo(xOf(lap.lap), yOf(lap.position));
      }

      // Glow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      // Main line
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.90)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Dot at last position
      final last = laps.last;
      canvas.drawCircle(
        Offset(xOf(last.lap), yOf(last.position)),
        3,
        Paint()..color = color,
      );

      // Driver label near last dot
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final lastX = xOf(last.lap);
      final lastY = yOf(last.position);
      tp.paint(canvas, Offset(lastX + 5, lastY - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PositionPainter old) =>
      old.histories != histories || old.showAllLaps != showAllLaps;
}
