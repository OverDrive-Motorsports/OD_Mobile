import 'package:flutter/widgets.dart';

// Describes a widget's position and span on the freeform grid.
// col/row are 0-based cell coordinates (grid units, not pixels).
// colSpan/rowSpan are sizes in cells; minimum 1 each.
class GridItem {
  final String id;
  int col;
  int row;
  int colSpan;
  int rowSpan;
  final Widget child;

  GridItem({
    required this.id,
    required this.col,
    required this.row,
    required this.colSpan,
    required this.rowSpan,
    required this.child,
  });

  GridItem copyWith({int? col, int? row, int? colSpan, int? rowSpan}) {
    return GridItem(
      id: id,
      col: col ?? this.col,
      row: row ?? this.row,
      colSpan: colSpan ?? this.colSpan,
      rowSpan: rowSpan ?? this.rowSpan,
      child: child,
    );
  }
}
