import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/base/od_button.dart';
import '../../widgets/glass_pill.dart';
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
  static const int _minRows = 7;
  static const double _cellSize = 54;
  static const double _gap = 6;
  static const double _headerHorizontalPadding = 18;
  static const double _pageBottomPadding = 18;
  static const double _defaultWidgetColSpan = 2;
  static const double _defaultWidgetRowSpan = 2;

  final List<GridItem> _items = <GridItem>[
    GridItem(
      id: 'speed_1',
      col: 0,
      row: 0,
      colSpan: _defaultWidgetColSpan.toInt(),
      rowSpan: _defaultWidgetRowSpan.toInt(),
      child: const SpeedGaugeWidget(),
    ),
  ];

  int _speedCounter = 1;

  int _responsiveCols(double availableWidth) {
    final colsFromWidth = ((availableWidth + _gap) / (_cellSize + _gap))
        .floor();
    return math.max(_minCols, colsFromWidth);
  }

  int _responsiveRows(double availableHeight) {
    final rowsFromHeight = ((availableHeight + _gap) / (_cellSize + _gap))
        .floor();
    return math.max(_minRows, rowsFromHeight);
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

  ({int col, int row})? _findFirstSlot(int cols, int rows) {
    final widgetColSpan = _defaultWidgetColSpan.toInt();
    final widgetRowSpan = _defaultWidgetRowSpan.toInt();

    if (widgetColSpan > cols || widgetRowSpan > rows) {
      return null;
    }

    for (var row = 0; row <= rows - widgetRowSpan; row++) {
      for (var col = 0; col <= cols - widgetColSpan; col++) {
        if (!_overlaps(col, row, widgetColSpan, widgetRowSpan, _items)) {
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

  void _addSpeedWidget(int cols, int rows) {
    final slot = _findFirstSlot(cols, rows);

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
          colSpan: _defaultWidgetColSpan.toInt(),
          rowSpan: _defaultWidgetRowSpan.toInt(),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _headerHorizontalPadding,
                26,
                _headerHorizontalPadding,
                0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _goBack,
                    child: GlassPill(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: AppColors.white.withValues(alpha: 0.08),
                      borderColor: AppColors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Telemetry',
                    style: AppTextStyles.bodyBold().copyWith(
                      fontSize: 26,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenSize = MediaQuery.sizeOf(context);
                        final cols = _responsiveCols(screenSize.width);
                        final rows = _responsiveRows(screenSize.height - 180);
                        return OdButton(
                          label: '+',
                          onPressed: () => _addSpeedWidget(cols, rows),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: _pageBottomPadding),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = _responsiveCols(constraints.maxWidth);
                    final rows = _responsiveRows(constraints.maxHeight);

                    return Align(
                      alignment: Alignment.topLeft,
                      child: GridBoard(
                        cols: cols,
                        rows: rows,
                        cellSize: _cellSize,
                        gap: _gap,
                        items: List<GridItem>.from(_items),
                        onItemsChanged: _syncBoardItems,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
