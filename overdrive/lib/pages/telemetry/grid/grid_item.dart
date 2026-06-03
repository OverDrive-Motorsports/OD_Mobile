import 'package:flutter/widgets.dart';

class GridItem {
  final String id;
  int col;
  int row;
  int colSpan;
  int rowSpan;
  final int initialCol;
  final int initialRow;
  final int initialColSpan;
  final int initialRowSpan;
  final Widget child;

  GridItem({
    required this.id,
    required this.col,
    required this.row,
    required this.colSpan,
    required this.rowSpan,
    required this.child,
    int? initialCol,
    int? initialRow,
    int? initialColSpan,
    int? initialRowSpan,
  }) : initialCol = initialCol ?? col,
       initialRow = initialRow ?? row,
       initialColSpan = initialColSpan ?? colSpan,
       initialRowSpan = initialRowSpan ?? rowSpan;

  GridItem copyWith({int? col, int? row, int? colSpan, int? rowSpan}) {
    return GridItem(
      id: id,
      col: col ?? this.col,
      row: row ?? this.row,
      colSpan: colSpan ?? this.colSpan,
      rowSpan: rowSpan ?? this.rowSpan,
      initialCol: initialCol,
      initialRow: initialRow,
      initialColSpan: initialColSpan,
      initialRowSpan: initialRowSpan,
      child: child,
    );
  }
}
