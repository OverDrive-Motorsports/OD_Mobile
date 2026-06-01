import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/telemetry/speed_gauge_widget.dart';
import 'grid/grid_board.dart';
import 'grid/grid_item.dart';

class TelemetryPage extends StatefulWidget {
  const TelemetryPage({super.key});

  @override
  State<TelemetryPage> createState() => _TelemetryPageState();
}

class _TelemetryPageState extends State<TelemetryPage> {
  static const int _minCols = 5;
  static const int _rows = 7;
  static const double _cellSize = 64;
  static const double _gap = 5;
  static const double _boardPadding = 16;
  static const int _defaultWidgetColSpan = 2;
  static const int _defaultWidgetRowSpan = 2;

  final List<GridItem> _items = <GridItem>[
    GridItem(
      id: 'speed_1',
      col: 0,
      row: 0,
      colSpan: _defaultWidgetColSpan,
      rowSpan: _defaultWidgetRowSpan,
      child: const SpeedGaugeWidget(),
    ),
  ];

  int _speedCounter = 1;

  int _responsiveCols(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final usableWidth = math.max(0, screenWidth - (_boardPadding * 2));
    final colsFromWidth = ((usableWidth + _gap) / (_cellSize + _gap)).floor();
    return math.max(_minCols, colsFromWidth);
  }

  bool _overlaps(
    int col,
    int row,
    int colSpan,
    int rowSpan,
    List<GridItem> items,
  ) {
    final right = col + colSpan;
    final bottom = row + rowSpan;

    for (final item in items) {
      final itemRight = item.col + item.colSpan;
      final itemBottom = item.row + item.rowSpan;

      final intersects =
          col < itemRight &&
          right > item.col &&
          row < itemBottom &&
          bottom > item.row;

      if (intersects) {
        return true;
      }
    }

    return false;
  }

  ({int col, int row})? _findFirstSlot(int cols) {
    if (_defaultWidgetColSpan > cols || _defaultWidgetRowSpan > _rows) {
      return null;
    }

    for (var row = 0; row <= _rows - _defaultWidgetRowSpan; row++) {
      for (var col = 0; col <= cols - _defaultWidgetColSpan; col++) {
        if (!_overlaps(
          col,
          row,
          _defaultWidgetColSpan,
          _defaultWidgetRowSpan,
          _items,
        )) {
          return (col: col, row: row);
        }
      }
    }

    return null;
  }

  void _syncBoardItems(List<GridItem> items) {
    setState(() {
      _items
        ..clear()
        ..addAll(items);
    });
  }

  void _addSpeedWidget() {
    final cols = _responsiveCols(context);
    final slot = _findFirstSlot(cols);

    if (slot == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('No space left in telemetry grid.')),
      );
      return;
    }

    setState(() {
      _speedCounter += 1;
      _items.add(
        GridItem(
          id: 'speed_$_speedCounter',
          col: slot.col,
          row: slot.row,
          colSpan: _defaultWidgetColSpan,
          rowSpan: _defaultWidgetRowSpan,
          child: const SpeedGaugeWidget(),
        ),
      );
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final cols = _responsiveCols(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Add speed widget',
            onPressed: _addSpeedWidget,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_boardPadding),
            child: GridBoard(
              cols: cols,
              rows: _rows,
              cellSize: _cellSize,
              gap: _gap,
              items: List<GridItem>.from(_items),
              onItemsChanged: _syncBoardItems,
            ),
          ),
        ),
      ),
    );
  }
}
