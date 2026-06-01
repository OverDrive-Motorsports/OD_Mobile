import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'grid_item.dart';

enum _InteractionMode { none, drag, resize }

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
  });

  final GridItem item;
  final double cellSize;
  final double gap;
  final int totalCols;
  final int totalRows;
  final void Function(int col, int row) onMove;
  final void Function(int colSpan, int rowSpan) onResize;

  @override
  State<GridItemWidget> createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  static const double _resizeHandleVisualSize = 28;
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

  int _clampCol(int value, int colSpan) {
    return value.clamp(0, widget.totalCols - colSpan).toInt();
  }

  int _clampRow(int value, int rowSpan) {
    return value.clamp(0, widget.totalRows - rowSpan).toInt();
  }

  void _startDrag(DragStartDetails details) {
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

  void _updateDrag(DragUpdateDetails details) {
    if (!_isDragging) {
      return;
    }

    setState(() {
      _dragDeltaX += details.delta.dx;
      _dragDeltaY += details.delta.dy;

      final stepX = (_dragDeltaX / (cellStep * _dragSnapFactor)).round();
      final stepY = (_dragDeltaY / (cellStep * _dragSnapFactor)).round();

      _previewCol = _clampCol(_dragStartCol + stepX, widget.item.colSpan);
      _previewRow = _clampRow(_dragStartRow + stepY, widget.item.rowSpan);
    });
  }

  void _startResize(DragStartDetails details) {
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

  void _updateResize(DragUpdateDetails details) {
    if (!_isResizing) {
      return;
    }

    setState(() {
      _resizeDeltaX += details.delta.dx;
      _resizeDeltaY += details.delta.dy;

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

  void _endInteraction() {
    final mode = _interactionMode;
    final col = _previewCol ?? widget.item.col;
    final row = _previewRow ?? widget.item.row;
    final colSpan = _previewColSpan ?? widget.item.colSpan;
    final rowSpan = _previewRowSpan ?? widget.item.rowSpan;

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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isDragging || _isResizing)
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
            onPanStart: _startDrag,
            onPanUpdate: _updateDrag,
            onPanEnd: (_) => _endInteraction(),
            onPanCancel: _endInteraction,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: widget.item.child),
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: _startResize,
                    onPanUpdate: _updateResize,
                    onPanEnd: (_) => _endInteraction(),
                    onPanCancel: _endInteraction,
                    child: SizedBox(
                      width: _resizeHandleTouchSize,
                      height: _resizeHandleTouchSize,
                      child: Center(
                        child: Container(
                          width: _resizeHandleVisualSize,
                          height: _resizeHandleVisualSize,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.65),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.24),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.open_in_full,
                            size: 14,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
