/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## grid_item.dart - Data model representing one item's position and size within the telemetry grid.
 ##
 */

import 'package:flutter/widgets.dart';

// Describes a widget's position and span on the freeform grid.
// col/row are 0-based coordinates (grid units); colSpan/rowSpan are cell sizes (min 1); minColSpan/minRowSpan constrain resizing.
class GridItem {
  final String id;
  int col;
  int row;
  int colSpan;
  int rowSpan;
  final int minColSpan;
  final int minRowSpan;
  final Widget child;

  GridItem({
    required this.id,
    required this.col,
    required this.row,
    required this.colSpan,
    required this.rowSpan,
    this.minColSpan = 1,
    this.minRowSpan = 1,
    required this.child,
  });

  GridItem copyWith({
    int? col,
    int? row,
    int? colSpan,
    int? rowSpan,
    int? minColSpan,
    int? minRowSpan,
  }) {
    return GridItem(
      id: id,
      col: col ?? this.col,
      row: row ?? this.row,
      colSpan: colSpan ?? this.colSpan,
      rowSpan: rowSpan ?? this.rowSpan,
      minColSpan: minColSpan ?? this.minColSpan,
      minRowSpan: minRowSpan ?? this.minRowSpan,
      child: child,
    );
  }
}
