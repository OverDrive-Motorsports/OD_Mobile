import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'grid_item.dart';
import 'grid_item_widget.dart';

class GridBoard extends StatefulWidget {
  const GridBoard({
    super.key,
    required this.items,
    required this.cols,
    required this.rows,
    required this.cellSize,
    required this.gap,
    this.onItemsChanged,
  });

  final List<GridItem> items;
  final int cols;
  final int rows;
  final double cellSize;
  final double gap;
  final ValueChanged<List<GridItem>>? onItemsChanged;

  @override
  State<GridBoard> createState() => _GridBoardState();
}

class _GridBoardState extends State<GridBoard> {
  late List<GridItem> _items;

  double get cellStep => widget.cellSize + widget.gap;

  double get boardWidth => widget.cols * cellStep - widget.gap;

  double get boardHeight => widget.rows * cellStep - widget.gap;

  @override
  void initState() {
    super.initState();
    _items = List<GridItem>.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant GridBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List<GridItem>.from(widget.items);
    }
  }

  void _emitItemsChanged() {
    widget.onItemsChanged?.call(List<GridItem>.from(_items));
  }

  bool _isPlacementValid({
    required String itemId,
    required int col,
    required int row,
    required int colSpan,
    required int rowSpan,
  }) {
    final right = col + colSpan;
    final bottom = row + rowSpan;

    if (col < 0 || row < 0 || right > widget.cols || bottom > widget.rows) {
      return false;
    }

    for (final other in _items) {
      if (other.id == itemId) {
        continue;
      }

      final overlaps =
          col < other.col + other.colSpan &&
          right > other.col &&
          row < other.row + other.rowSpan &&
          bottom > other.row;

      if (overlaps) {
        return false;
      }
    }

    return true;
  }

  void _onMove(String id, int newCol, int newRow) {
    var didMove = false;

    setState(() {
      final index = _items.indexWhere((e) => e.id == id);
      if (index == -1) {
        return;
      }

      final item = _items[index];
      if (!_isPlacementValid(
        itemId: id,
        col: newCol,
        row: newRow,
        colSpan: item.colSpan,
        rowSpan: item.rowSpan,
      )) {
        return;
      }

      _items[index] = item.copyWith(col: newCol, row: newRow);
      didMove = true;
    });

    if (didMove) {
      _emitItemsChanged();
    }
  }

  void _onResize(String id, int newColSpan, int newRowSpan) {
    var didResize = false;

    setState(() {
      final index = _items.indexWhere((e) => e.id == id);
      if (index == -1) {
        return;
      }

      final item = _items[index];
      final clampedColSpan = newColSpan
          .clamp(1, widget.cols - item.col)
          .toInt();
      final clampedRowSpan = newRowSpan
          .clamp(1, widget.rows - item.row)
          .toInt();

      if (!_isPlacementValid(
        itemId: id,
        col: item.col,
        row: item.row,
        colSpan: clampedColSpan,
        rowSpan: clampedRowSpan,
      )) {
        return;
      }

      _items[index] = item.copyWith(
        colSpan: clampedColSpan,
        rowSpan: clampedRowSpan,
      );
      didResize = true;
    });

    if (didResize) {
      _emitItemsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(boardWidth, boardHeight),
            painter: _GridBackgroundPainter(
              cols: widget.cols,
              rows: widget.rows,
              cellSize: widget.cellSize,
              gap: widget.gap,
              cellColor: AppColors.surface,
              borderColor: AppColors.border,
            ),
          ),
          for (final item in _items)
            GridItemWidget(
              item: item,
              cellSize: widget.cellSize,
              gap: widget.gap,
              totalCols: widget.cols,
              totalRows: widget.rows,
              onMove: (col, row) => _onMove(item.id, col, row),
              onResize: (colSpan, rowSpan) =>
                  _onResize(item.id, colSpan, rowSpan),
            ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  const _GridBackgroundPainter({
    required this.cols,
    required this.rows,
    required this.cellSize,
    required this.gap,
    required this.cellColor,
    required this.borderColor,
  });

  final int cols;
  final int rows;
  final double cellSize;
  final double gap;
  final Color cellColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = cellColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final step = cellSize + gap;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final rect = Rect.fromLTWH(col * step, row * step, cellSize, cellSize);
        final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(8));
        canvas.drawRRect(rounded, fillPaint);
        canvas.drawRRect(rounded, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) {
    return oldDelegate.cols != cols ||
        oldDelegate.rows != rows ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.gap != gap ||
        oldDelegate.cellColor != cellColor ||
        oldDelegate.borderColor != borderColor;
  }
}
