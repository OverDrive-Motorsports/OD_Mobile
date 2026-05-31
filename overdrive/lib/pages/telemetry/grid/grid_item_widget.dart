import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'grid_item.dart';

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
  double _dragDeltaX = 0;
  double _dragDeltaY = 0;
  double _resizeDeltaX = 0;
  double _resizeDeltaY = 0;
  int? _previewCol;
  int? _previewRow;
  int? _previewColSpan;
  int? _previewRowSpan;
  bool _isDragging = false;
  bool _isResizing = false;

  double get cellStep => widget.cellSize + widget.gap;
  double get left => widget.item.col * cellStep;
  double get top => widget.item.row * cellStep;
  double get width => widget.item.colSpan * cellStep - widget.gap;
  double get height => widget.item.rowSpan * cellStep - widget.gap;

  int _offsetToCol(double dx, int colSpan) {
    return (dx / cellStep).floor().clamp(0, widget.totalCols - colSpan).toInt();
  }

  int _offsetToRow(double dy, int rowSpan) {
    return (dy / cellStep).floor().clamp(0, widget.totalRows - rowSpan).toInt();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragDeltaX += details.delta.dx;
      _dragDeltaY += details.delta.dy;
      _previewCol = _offsetToCol(left + _dragDeltaX, widget.item.colSpan);
      _previewRow = _offsetToRow(top + _dragDeltaY, widget.item.rowSpan);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final col = _previewCol ?? widget.item.col;
    final row = _previewRow ?? widget.item.row;
    setState(() {
      _isDragging = false;
      _dragDeltaX = 0;
      _dragDeltaY = 0;
      _previewCol = null;
      _previewRow = null;
    });
    widget.onMove(col, row);
  }

  void _handleResizeUpdate(DragUpdateDetails details) {
    setState(() {
      _isResizing = true;
      _resizeDeltaX += details.delta.dx;
      _resizeDeltaY += details.delta.dy;
      _previewColSpan = (widget.item.colSpan + (_resizeDeltaX / cellStep).round())
          .clamp(1, widget.totalCols - widget.item.col)
          .toInt();
      _previewRowSpan = (widget.item.rowSpan + (_resizeDeltaY / cellStep).round())
          .clamp(1, widget.totalRows - widget.item.row)
          .toInt();
    });
  }

  void _handleResizeEnd(DragEndDetails details) {
    final colSpan = _previewColSpan ?? widget.item.colSpan;
    final rowSpan = _previewRowSpan ?? widget.item.rowSpan;
    setState(() {
      _isResizing = false;
      _resizeDeltaX = 0;
      _resizeDeltaY = 0;
      _previewColSpan = null;
      _previewRowSpan = null;
    });
    widget.onResize(colSpan, rowSpan);
  }

  @override
  Widget build(BuildContext context) {
    final previewLeft = (_previewCol ?? widget.item.col) * cellStep;
    final previewTop = (_previewRow ?? widget.item.row) * cellStep;
    final previewWidth = (_previewColSpan ?? widget.item.colSpan) * cellStep -
        widget.gap;
    final previewHeight = (_previewRowSpan ?? widget.item.rowSpan) * cellStep -
        widget.gap;

    return Stack(
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
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: _isResizing ? null : _handleDragUpdate,
            onPanEnd: _isResizing ? null : _handleDragEnd,
            child: Stack(
              children: [
                Positioned.fill(child: widget.item.child),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: _handleResizeUpdate,
                    onPanEnd: _handleResizeEnd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Icon(
                        Icons.open_in_full,
                        size: 14,
                        color: AppColors.gold,
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
