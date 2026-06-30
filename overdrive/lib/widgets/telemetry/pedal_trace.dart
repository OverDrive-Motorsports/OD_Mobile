/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## pedal_trace.dart - Real-time throttle and brake trace chart telemetry widget.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';

// Each sample is (throttle 0–1, brake 0–1) captured at 200 ms intervals.
typedef _Sample = ({double throttle, double brake});

const int _kBufferSize = 80; // 16 seconds of history

// Widget that subscribes to simulator ticks and maintains a rolling sample buffer for painting.
class PedalTrace extends StatefulWidget {
  const PedalTrace({this.initialDriverId = 'VER', super.key});
  final String initialDriverId;

  @override
  State<PedalTrace> createState() => _PedalTraceState();
}

class _PedalTraceState extends State<PedalTrace> {
  late String _driverId;
  TelemetrySimulator? _sim;
  final List<_Sample> _buffer = [];

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sim = Provider.of<TelemetrySimulator>(context, listen: false);
    if (sim != _sim) {
      _sim?.removeListener(_onTick);
      _sim = sim;
      _sim!.addListener(_onTick);
    }
  }

  void _onTick() {
    if (!mounted) return;
    final snap = _sim!.getSnapshot(_driverId);
    setState(() {
      _buffer.add((throttle: snap.throttle, brake: snap.brake));
      if (_buffer.length > _kBufferSize) _buffer.removeAt(0);
    });
  }

  void _changeDriver(String id) {
    setState(() {
      _driverId = id;
      _buffer.clear();
    });
  }

  @override
  void dispose() {
    _sim?.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _buffer.isEmpty ? null : _buffer.last;

    return GestureDetector(
      onTap: () {
        final actions = TelemetryItemActions.maybeOf(context);
        showTelemetryWidgetMenu(context, widgetLabel: 'Pedal Trace',
            currentDriverId: _driverId,
            onDriverSelected: _changeDriver,
            onReset: actions?.onReset, onRemove: actions?.onRemove);
      },
      child: TelemetryCard(
        child: LayoutBuilder(builder: (context, constraints) {
          final mode = telemetryMode(constraints.maxWidth, constraints.maxHeight);
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TraceHeader(driverId: _driverId, last: last),
                const SizedBox(height: 8),
                Expanded(
                  child: CustomPaint(
                    painter: _TracePainter(buffer: List<_Sample>.from(_buffer)),
                    child: const SizedBox.expand(),
                  ),
                ),
                if (mode == TelemetryMode.large) ...[
                  const SizedBox(height: 6),
                  _NumericRow(last: last),
                ],
                const SizedBox(height: 2),
                _TimeAxis(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _TraceHeader extends StatelessWidget {
  const _TraceHeader({required this.driverId, required this.last});
  final String driverId;
  final _Sample? last;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('PÉDALE',
            style: AppTextStyles.label(color: AppColors.textMuted)
                .copyWith(fontSize: 10, letterSpacing: 0.6)),
        const SizedBox(width: 10),
        _LegendDot(color: AppColors.green, label: 'ACC'),
        const SizedBox(width: 8),
        _LegendDot(color: AppColors.red, label: 'FR'),
        const Spacer(),
        Text(driverId,
            style: AppTextStyles.label(color: AppColors.gold).copyWith(fontSize: 10)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
      ],
    );
  }
}

// ── Numeric row (large mode) ──────────────────────────────────────────────────

class _NumericRow extends StatelessWidget {
  const _NumericRow({required this.last});
  final _Sample? last;

  @override
  Widget build(BuildContext context) {
    final thr = last?.throttle ?? 0;
    final brk = last?.brake ?? 0;

    return Row(
      children: [
        _NumericVal(label: 'ACCÉL', value: thr, color: AppColors.green),
        const Spacer(),
        _NumericVal(label: 'FREIN', value: brk, color: AppColors.red, alignRight: true),
      ],
    );
  }
}

class _NumericVal extends StatelessWidget {
  const _NumericVal({required this.label, required this.value, required this.color, this.alignRight = false});
  final String label;
  final double value;
  final Color color;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignRight) ...[
          Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
          const SizedBox(width: 5),
        ],
        Text('${(value * 100).toInt()}%',
            style: AppTextStyles.bodyBold(color: color).copyWith(fontSize: 12)),
        if (alignRight) ...[
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 8)),
        ],
      ],
    );
  }
}

// ── Time axis hint ────────────────────────────────────────────────────────────

class _TimeAxis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('−16s',
            style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 7)),
        const Spacer(),
        Text('NOW',
            style: AppTextStyles.caption(color: AppColors.textMuted)
                .copyWith(fontSize: 7, letterSpacing: 0.5)),
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

// CustomPainter that renders filled area traces and stroke lines for throttle (green) and brake (red).
class _TracePainter extends CustomPainter {
  const _TracePainter({required this.buffer});
  final List<_Sample> buffer;

  @override
  void paint(Canvas canvas, Size size) {
    if (buffer.isEmpty) return;

    final n = buffer.length;

    double xOf(int i) => size.width * i / (_kBufferSize - 1);
    double yOf(double v) => size.height * (1 - v.clamp(0.0, 1.0));

    // Background grid
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    for (final frac in [0.25, 0.50, 0.75]) {
      final y = size.height * (1 - frac);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Offset so newest sample is at the right edge
    final offset = _kBufferSize - n;

    // Build paths with area fills
    final thrPath = Path();
    final brkPath = Path();
    final baseLine = size.height;

    thrPath.moveTo(xOf(offset), baseLine);
    for (var i = 0; i < n; i++) {
      thrPath.lineTo(xOf(offset + i), yOf(buffer[i].throttle));
    }
    thrPath.lineTo(xOf(offset + n - 1), baseLine);
    thrPath.close();

    brkPath.moveTo(xOf(offset), baseLine);
    for (var i = 0; i < n; i++) {
      brkPath.lineTo(xOf(offset + i), yOf(buffer[i].brake));
    }
    brkPath.lineTo(xOf(offset + n - 1), baseLine);
    brkPath.close();

    // Draw fills
    canvas.drawPath(thrPath, Paint()..color = AppColors.green.withValues(alpha: 0.18));
    canvas.drawPath(brkPath, Paint()..color = AppColors.red.withValues(alpha: 0.18));

    // Build line paths (no fill)
    final thrLine = Path();
    final brkLine = Path();
    thrLine.moveTo(xOf(offset), yOf(buffer.first.throttle));
    brkLine.moveTo(xOf(offset), yOf(buffer.first.brake));
    for (var i = 1; i < n; i++) {
      thrLine.lineTo(xOf(offset + i), yOf(buffer[i].throttle));
      brkLine.lineTo(xOf(offset + i), yOf(buffer[i].brake));
    }

    final thrPaint = Paint()
      ..color = AppColors.green.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    final brkPaint = Paint()
      ..color = AppColors.red.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(thrLine, thrPaint);
    canvas.drawPath(brkLine, brkPaint);

    // Current-value dots at right edge
    final lastX = xOf(offset + n - 1);
    canvas.drawCircle(
      Offset(lastX, yOf(buffer.last.throttle)),
      3,
      Paint()..color = AppColors.green,
    );
    canvas.drawCircle(
      Offset(lastX, yOf(buffer.last.brake)),
      3,
      Paint()..color = AppColors.red,
    );
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => old.buffer != buffer;
}
