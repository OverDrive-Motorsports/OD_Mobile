import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/telemetry/telemetry_item_actions.dart';
import 'grid_item.dart';

enum _InteractionMode { none, drag, resize }

class _CornerAccentPainter extends CustomPainter {
  const _CornerAccentPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 10.0;
    const legLen = 14.0;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Top-left corner ⌜
    final tl = Path()
      ..moveTo(legLen, 0)
      ..lineTo(radius, 0)
      ..arcToPoint(
        const Offset(0, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(0, legLen);
    canvas.drawPath(tl, paint);

    // Bottom-right corner ⌟
    final br = Path()
      ..moveTo(size.width - legLen, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - legLen);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(_CornerAccentPainter old) => old.color != color;
}

class GridItemWidget extends StatefulWidget {
  const GridItemWidget({
    super.key,
    required this.item,
    required this.cellSize,
    required this.gap,
    required this.totalCols,
    required this.totalRows,
    required this.onMove,
    required this.onResize,
    this.onRemove,
    this.onReset,
    this.onInteractionStart,
    this.onInteractionEnd,
  });

  final GridItem item;
  final double cellSize;
  final double gap;
  final int totalCols;
  final int totalRows;
  final void Function(int col, int row) onMove;
  final void Function(int colSpan, int rowSpan) onResize;
  final VoidCallback? onRemove;
  final VoidCallback? onReset;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;

  @override
  State<GridItemWidget> createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  static const double _resizeHandleTouchSize = 44;
  static const double _dragSnapFactor = 0.55;
  static const double _resizeSnapFactor = 0.5;

  _InteractionMode _interactionMode = _InteractionMode.none;

  double _dragDeltaX = 0;
  double _dragDeltaY = 0;
  double _resizeDeltaX = 0;
  double _resizeDeltaY = 0;

  int _dragStartCol = 0;
  int _dragStartRow = 0;
  int _resizeStartColSpan = 1;
  int _resizeStartRowSpan = 1;

  int? _previewCol;
  int? _previewRow;
  int? _previewColSpan;
  int? _previewRowSpan;

  double get cellStep => widget.cellSize + widget.gap;

  double get baseLeft => widget.item.col * cellStep;
  double get baseTop => widget.item.row * cellStep;
  double get baseWidth => widget.item.colSpan * cellStep - widget.gap;
  double get baseHeight => widget.item.rowSpan * cellStep - widget.gap;

  double get _maxLeft => (widget.totalCols - widget.item.colSpan) * cellStep;
  double get _maxTop => (widget.totalRows - widget.item.rowSpan) * cellStep;

  bool get _isDragging => _interactionMode == _InteractionMode.drag;
  bool get _isResizing => _interactionMode == _InteractionMode.resize;

  int _clampCol(int value, int colSpan) =>
      value.clamp(0, widget.totalCols - colSpan).toInt();

  int _clampRow(int value, int rowSpan) =>
      value.clamp(0, widget.totalRows - rowSpan).toInt();

  // ── Drag (long-press bypasses the scroll view gesture arena) ──────────────

  void _startDrag(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    widget.onInteractionStart?.call();
    setState(() {
      _interactionMode = _InteractionMode.drag;
      _dragDeltaX = 0;
      _dragDeltaY = 0;
      _dragStartCol = widget.item.col;
      _dragStartRow = widget.item.row;
      _previewCol = widget.item.col;
      _previewRow = widget.item.row;
      _previewColSpan = widget.item.colSpan;
      _previewRowSpan = widget.item.rowSpan;
    });
  }

  void _updateDrag(LongPressMoveUpdateDetails details) {
    if (!_isDragging) return;
    // localOffsetFromOrigin is cumulative from long-press start — no manual accumulation needed
    final offset = details.localOffsetFromOrigin;
    setState(() {
      _dragDeltaX = offset.dx;
      _dragDeltaY = offset.dy;
      final stepX = (_dragDeltaX / (cellStep * _dragSnapFactor)).round();
      final stepY = (_dragDeltaY / (cellStep * _dragSnapFactor)).round();
      _previewCol = _clampCol(_dragStartCol + stepX, widget.item.colSpan);
      _previewRow = _clampRow(_dragStartRow + stepY, widget.item.rowSpan);
    });
  }

  // ── Resize (long-press on bottom-right handle) ────────────────────────────

  void _startResize(LongPressStartDetails details) {
    HapticFeedback.lightImpact();
    widget.onInteractionStart?.call();
    setState(() {
      _interactionMode = _InteractionMode.resize;
      _resizeDeltaX = 0;
      _resizeDeltaY = 0;
      _resizeStartColSpan = widget.item.colSpan;
      _resizeStartRowSpan = widget.item.rowSpan;
      _previewCol = widget.item.col;
      _previewRow = widget.item.row;
      _previewColSpan = widget.item.colSpan;
      _previewRowSpan = widget.item.rowSpan;
    });
  }

  void _updateResize(LongPressMoveUpdateDetails details) {
    if (!_isResizing) return;
    final offset = details.localOffsetFromOrigin;
    setState(() {
      _resizeDeltaX = offset.dx;
      _resizeDeltaY = offset.dy;
      final stepX = (_resizeDeltaX / (cellStep * _resizeSnapFactor)).round();
      final stepY = (_resizeDeltaY / (cellStep * _resizeSnapFactor)).round();
      _previewColSpan = (_resizeStartColSpan + stepX)
          .clamp(1, widget.totalCols - widget.item.col)
          .toInt();
      _previewRowSpan = (_resizeStartRowSpan + stepY)
          .clamp(1, widget.totalRows - widget.item.row)
          .toInt();
    });
  }

  // ── Common end ────────────────────────────────────────────────────────────

  void _endInteraction() {
    final mode = _interactionMode;
    final col = _previewCol ?? widget.item.col;
    final row = _previewRow ?? widget.item.row;
    final colSpan = _previewColSpan ?? widget.item.colSpan;
    final rowSpan = _previewRowSpan ?? widget.item.rowSpan;

    widget.onInteractionEnd?.call();
    setState(() {
      _interactionMode = _InteractionMode.none;
      _dragDeltaX = 0;
      _dragDeltaY = 0;
      _resizeDeltaX = 0;
      _resizeDeltaY = 0;
      _previewCol = null;
      _previewRow = null;
      _previewColSpan = null;
      _previewRowSpan = null;
    });

    if (mode == _InteractionMode.drag) {
      widget.onMove(col, row);
      return;
    }
    if (mode == _InteractionMode.resize) {
      widget.onResize(colSpan, rowSpan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewCol = _previewCol ?? widget.item.col;
    final previewRow = _previewRow ?? widget.item.row;
    final previewColSpan = _previewColSpan ?? widget.item.colSpan;
    final previewRowSpan = _previewRowSpan ?? widget.item.rowSpan;

    final previewLeft = previewCol * cellStep;
    final previewTop = previewRow * cellStep;
    final previewWidth = previewColSpan * cellStep - widget.gap;
    final previewHeight = previewRowSpan * cellStep - widget.gap;

    final liveLeft = _isDragging
        ? (baseLeft + _dragDeltaX).clamp(0.0, _maxLeft).toDouble()
        : baseLeft;
    final liveTop = _isDragging
        ? (baseTop + _dragDeltaY).clamp(0.0, _maxTop).toDouble()
        : baseTop;

    final isActive = _isDragging || _isResizing;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isActive)
          Positioned(
            left: previewLeft,
            top: previewTop,
            width: previewWidth,
            height: previewHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          left: liveLeft,
          top: liveTop,
          width: baseWidth,
          height: baseHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: _startDrag,
            onLongPressMoveUpdate: _updateDrag,
            onLongPressEnd: (_) => _endInteraction(),
            onLongPressCancel: _endInteraction,
            child: AnimatedScale(
              scale: _isDragging ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: TelemetryItemActions(
                      onRemove: widget.onRemove,
                      onReset: widget.onReset,
                      child: widget.item.child,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CornerAccentPainter(color: AppColors.gold),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPressStart: _startResize,
                      onLongPressMoveUpdate: _updateResize,
                      onLongPressEnd: (_) => _endInteraction(),
                      onLongPressCancel: _endInteraction,
                      child: const SizedBox(
                        width: _resizeHandleTouchSize,
                        height: _resizeHandleTouchSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
