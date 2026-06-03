import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'grid_item.dart';

enum _InteractionMode { none, drag, resize }

enum _WidgetMenuAction { reset, delete }

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
    required this.onDelete,
    required this.onReset,
    required this.onInteractionChanged,
  });

  final GridItem item;
  final double cellSize;
  final double gap;
  final int totalCols;
  final int totalRows;
  final void Function(int col, int row) onMove;
  final void Function(int colSpan, int rowSpan) onResize;
  final VoidCallback onDelete;
  final VoidCallback onReset;
  final ValueChanged<bool> onInteractionChanged;

  @override
  State<GridItemWidget> createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  static const double _resizeHandleVisualSize = 30;
  static const double _resizeHandleTouchSize = 52;
  static const Duration _settleDuration = Duration(milliseconds: 140);

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
  bool get _isInteracting => _interactionMode != _InteractionMode.none;

  int _clampCol(int value, int colSpan) {
    return value.clamp(0, widget.totalCols - colSpan).toInt();
  }

  int _clampRow(int value, int rowSpan) {
    return value.clamp(0, widget.totalRows - rowSpan).toInt();
  }

  int _snapOffsetToStep(double delta) {
    return (delta / cellStep).round();
  }

  void _startDrag(DragStartDetails details) {
    widget.onInteractionChanged(true);
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

      final stepX = _snapOffsetToStep(_dragDeltaX);
      final stepY = _snapOffsetToStep(_dragDeltaY);

      _previewCol = _clampCol(_dragStartCol + stepX, widget.item.colSpan);
      _previewRow = _clampRow(_dragStartRow + stepY, widget.item.rowSpan);
    });
  }

  void _startResize(DragStartDetails details) {
    widget.onInteractionChanged(true);
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

      final stepX = _snapOffsetToStep(_resizeDeltaX);
      final stepY = _snapOffsetToStep(_resizeDeltaY);

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

    widget.onInteractionChanged(false);
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

  Future<void> _openContextMenu(LongPressStartDetails details) async {
    if (_interactionMode != _InteractionMode.none) {
      return;
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null || !mounted) {
      return;
    }

    final tapPosition = details.globalPosition;
    final selectedAction = await showMenu<_WidgetMenuAction>(
      context: context,
      color: AppColors.surfaceElevated,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 1, 1),
        Offset.zero & overlay.context.size!,
      ),
      items: const [
        PopupMenuItem<_WidgetMenuAction>(
          value: _WidgetMenuAction.reset,
          child: Text('Reset'),
        ),
        PopupMenuItem<_WidgetMenuAction>(
          value: _WidgetMenuAction.delete,
          child: Text('Supp'),
        ),
      ],
    );

    if (!mounted || selectedAction == null) {
      return;
    }

    switch (selectedAction) {
      case _WidgetMenuAction.reset:
        widget.onReset();
      case _WidgetMenuAction.delete:
        widget.onDelete();
    }
  }

  Widget _buildTile() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: widget.item.child),
        Positioned(
          right: -10,
          bottom: -10,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: _resizeHandleVisualSize,
                  height: _resizeHandleVisualSize,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.white.withValues(
                        alpha: _isResizing ? 0.55 : 0.24,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(
                          alpha: _isResizing ? 0.22 : 0.14,
                        ),
                        blurRadius: _isResizing ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.open_in_full,
                    size: 14,
                    color: _isResizing ? AppColors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

    final liveWidth = _isResizing
        ? (baseWidth + _resizeDeltaX)
              .clamp(widget.cellSize, widget.totalCols * cellStep)
              .toDouble()
        : baseWidth;
    final liveHeight = _isResizing
        ? (baseHeight + _resizeDeltaY)
              .clamp(widget.cellSize, widget.totalRows * cellStep)
              .toDouble()
        : baseHeight;

    final tile = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _startDrag,
      onPanUpdate: _updateDrag,
      onPanEnd: (_) => _endInteraction(),
      onPanCancel: _endInteraction,
      onLongPressStart: _openContextMenu,
      child: _buildTile(),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isInteracting)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            left: previewLeft,
            top: previewTop,
            width: previewWidth,
            height: previewHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
        if (_isInteracting)
          Positioned(
            left: liveLeft,
            top: liveTop,
            width: liveWidth,
            height: liveHeight,
            child: tile,
          )
        else
          AnimatedPositioned(
            duration: _settleDuration,
            curve: Curves.easeOutCubic,
            left: baseLeft,
            top: baseTop,
            width: baseWidth,
            height: baseHeight,
            child: tile,
          ),
      ],
    );
  }
}
