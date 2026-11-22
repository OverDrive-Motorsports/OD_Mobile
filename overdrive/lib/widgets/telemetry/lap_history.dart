/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## lap_history.dart - Scrollable multi-driver lap-time gap chart telemetry widget.
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

// Root widget displaying driver lap-gap history in a small static or large scrollable chart.
class LapHistory extends StatefulWidget {
  const LapHistory({super.key});

  @override
  State<LapHistory> createState() => _LapHistoryState();
}

class _LapHistoryState extends State<LapHistory> {
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
          widgetLabel: 'Lap History',
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
              for (final id in ['VER', 'LEC', 'NOR']) id: sim.getLapHistory(id),
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
                        ? _StaticChart(histories: histories, lastN: 10)
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
  final Map<String, List<LapData>> histories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'HIST. TOURS',
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
          'L57',
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
  final Map<String, List<LapData>> histories;
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
      painter: _ChartPainter(histories: trimmed, showAllLaps: false),
      child: const SizedBox.expand(),
    );
  }
}

// ── Large: scrollable full chart ──────────────────────────────────────────────

class _ScrollableChart extends StatefulWidget {
  const _ScrollableChart({required this.histories, required this.scroll});
  final Map<String, List<LapData>> histories;
  final ScrollController scroll;

  @override
  State<_ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<_ScrollableChart> {
  @override
  void initState() {
    super.initState();
    // Auto-scroll to end after first frame
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
          painter: _ChartPainter(
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

// CustomPainter that draws per-driver gap-to-leader lines with glow and grid overlay.
class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.histories, required this.showAllLaps});
  final Map<String, List<LapData>> histories;
  final bool showAllLaps;

  static const double _maxGap = 8.0; // seconds — Y axis top bound

  @override
  void paint(Canvas canvas, Size size) {
    final maxLap = showAllLaps
        ? TelemetrySnapshot.totalLaps
        : histories.values.fold<int>(
            1,
            (m, laps) => math.max(m, laps.isEmpty ? 1 : laps.last.lap),
          );

    double xOf(int lap) => size.width * (lap - 1) / math.max(maxLap - 1, 1);
    double yOf(double gap) => size.height * (gap / _maxGap).clamp(0.0, 1.0);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.40)
      ..strokeWidth = 0.5;

    for (final gapVal in [0.0, 2.0, 4.0, 6.0]) {
      final y = yOf(gapVal);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      if (gapVal > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '+${gapVal.toInt()}s',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 6),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(2, y - tp.height - 1));
      }
    }

    // Lap lines every 5 laps
    for (var lap = 5; lap <= maxLap; lap += 5) {
      final x = xOf(lap);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
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
      path.moveTo(xOf(laps.first.lap), yOf(laps.first.gap));
      for (final lap in laps.skip(1)) {
        path.lineTo(xOf(lap.lap), yOf(lap.gap));
      }

      // Subtle glow
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

      // Last point dot
      final last = laps.last;
      canvas.drawCircle(
        Offset(xOf(last.lap), yOf(last.gap)),
        3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.histories != histories || old.showAllLaps != showAllLaps;
}
