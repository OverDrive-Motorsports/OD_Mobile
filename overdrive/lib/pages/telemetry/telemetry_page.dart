import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/telemetry/drs_ers_widget.dart';
import '../../widgets/telemetry/driver_snapshot_widget.dart';
import '../../widgets/telemetry/engine_widget.dart';
import '../../widgets/telemetry/fuel_widget.dart';
import '../../widgets/telemetry/g_force_widget.dart';
import '../../widgets/telemetry/gear_rpm_widget.dart';
import '../../widgets/telemetry/lap_delta_widget.dart';
import '../../widgets/telemetry/pit_strategy_widget.dart';
import '../../widgets/telemetry/sector_split_widget.dart';
import '../../widgets/telemetry/speedometer_widget.dart';
import '../../widgets/telemetry/standings_widget.dart';
import '../../widgets/telemetry/telemetry_mock_data.dart';
import '../../widgets/telemetry/throttle_brake_widget.dart';
import '../../widgets/telemetry/tire_temp_widget.dart';
import '../../widgets/telemetry/weather_widget.dart';
import 'grid/grid_board.dart';
import 'grid/grid_item.dart';

// ─── Widget catalogue ─────────────────────────────────────────────────────────

enum _WidgetType {
  speedometer('Speedometer', Icons.speed_rounded),
  gearRpm('Gear & RPM', Icons.settings_outlined),
  throttleBrake('Throttle / Brake', Icons.tune_rounded),
  lapDelta('Lap Delta', Icons.timer_outlined),
  drsErs('DRS & ERS', Icons.bolt_rounded),
  gForce('G-Force', Icons.radar_rounded),
  sectorSplit('Sector Split', Icons.bar_chart_rounded),
  driverSnapshot('Driver Snapshot', Icons.person_outline_rounded),
  tireTemp('Tyre Temps', Icons.circle_outlined),
  fuel('Fuel Load', Icons.local_gas_station_rounded),
  weather('Weather', Icons.wb_sunny_outlined),
  pitStrategy('Pit Strategy', Icons.swap_horiz_rounded),
  engine('Engine', Icons.settings_input_svideo_rounded),
  standings('Standings', Icons.format_list_numbered_rounded);

  const _WidgetType(this.label, this.icon);
  final String label;
  final IconData icon;
}

Widget _buildWidget(_WidgetType type) => switch (type) {
      _WidgetType.speedometer => const SpeedometerWidget(),
      _WidgetType.gearRpm => const GearRpmWidget(),
      _WidgetType.throttleBrake => const ThrottleBrakeWidget(),
      _WidgetType.lapDelta => const LapDeltaWidget(),
      _WidgetType.drsErs => const DrsErsWidget(),
      _WidgetType.gForce => const GForceWidget(),
      _WidgetType.sectorSplit => const SectorSplitWidget(),
      _WidgetType.driverSnapshot => const DriverSnapshotWidget(),
      _WidgetType.tireTemp => const TireTempWidget(),
      _WidgetType.fuel => const FuelWidget(),
      _WidgetType.weather => const WeatherWidget(),
      _WidgetType.pitStrategy => const PitStrategyWidget(),
      _WidgetType.engine => const EngineWidget(),
      _WidgetType.standings => const StandingsWidget(),
    };

// ─── Page root — owns the simulator ──────────────────────────────────────────

class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TelemetrySimulator(),
      child: const _TelemetryBoard(),
    );
  }
}

// ─── Board — owns grid state ───────────────────────────────────────────────────

class _TelemetryBoard extends StatefulWidget {
  const _TelemetryBoard();

  @override
  State<_TelemetryBoard> createState() => _TelemetryBoardState();
}

class _TelemetryBoardState extends State<_TelemetryBoard> {
  static const int _minCols = 5;
  static const int _rows = 15;
  static const double _cellSize = 64;
  static const double _gap = 5;
  static const double _boardPadding = 16;
  static const int _defaultColSpan = 2;
  static const int _defaultRowSpan = 2;

  final List<GridItem> _items = [
    GridItem(
      id: 'speedometer_0',
      col: 0,
      row: 0,
      colSpan: _defaultColSpan,
      rowSpan: _defaultRowSpan,
      child: const SpeedometerWidget(),
    ),
  ];

  int _idCounter = 1;
  final ScrollController _verticalScroll = ScrollController();

  @override
  void dispose() {
    _verticalScroll.dispose();
    super.dispose();
  }

  // ── Grid helpers ───────────────────────────────────────────────────────────

  int _responsiveCols() {
    final w = MediaQuery.sizeOf(context).width;
    final usable = math.max(0.0, w - _boardPadding * 2);
    return math.max(_minCols, ((usable + _gap) / (_cellSize + _gap)).floor());
  }

  bool _overlaps(int col, int row, int cs, int rs) {
    for (final item in _items) {
      if (col < item.col + item.colSpan &&
          col + cs > item.col &&
          row < item.row + item.rowSpan &&
          row + rs > item.row) {
        return true;
      }
    }
    return false;
  }

  ({int col, int row})? _findFirstSlot() {
    final cols = _responsiveCols();
    for (var r = 0; r <= _rows - _defaultRowSpan; r++) {
      for (var c = 0; c <= cols - _defaultColSpan; c++) {
        if (!_overlaps(c, r, _defaultColSpan, _defaultRowSpan)) {
          return (col: c, row: r);
        }
      }
    }
    return null;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _addWidget(_WidgetType type) {
    final slot = _findFirstSlot();
    if (slot == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('No space left in the grid.')),
      );
      return;
    }
    setState(() {
      _items.add(GridItem(
        id: '${type.name}_$_idCounter',
        col: slot.col,
        row: slot.row,
        colSpan: _defaultColSpan,
        rowSpan: _defaultRowSpan,
        child: _buildWidget(type),
      ));
      _idCounter++;
    });
  }

  void _removeWidget(String id) {
    setState(() => _items.removeWhere((item) => item.id == id));
  }

  void _resetWidget(String id) {
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx == -1) return;
    setState(() {
      _items[idx] = _items[idx].copyWith(
        colSpan: _defaultColSpan,
        rowSpan: _defaultRowSpan,
      );
    });
  }

  void _syncBoardItems(List<GridItem> items) {
    setState(() {
      _items
        ..clear()
        ..addAll(items);
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  // ── Add-widget bottom sheet ────────────────────────────────────────────────

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text('Add widget', style: AppTextStyles.bodyBold()),
                  const Spacer(),
                  Text(
                    '${_WidgetType.values.length} available',
                    style: AppTextStyles.label(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                children: [
                  for (final type in _WidgetType.values)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.35),
                          ),
                        ),
                        child:
                            Icon(type.icon, color: AppColors.gold, size: 18),
                      ),
                      title: Text(type.label, style: AppTextStyles.body()),
                      trailing: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _addWidget(type);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cols = _responsiveCols();

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
        title: Text('Telemetry', style: AppTextStyles.bodyBold()),
        actions: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('LIVE', style: AppTextStyles.label(color: AppColors.green)),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Add widget',
                onPressed: _showAddSheet,
                icon: const Icon(Icons.add_rounded, color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          controller: _verticalScroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalScroll,
            child: Padding(
              padding: const EdgeInsets.all(_boardPadding),
              child: GridBoard(
                cols: cols,
                rows: _rows,
                cellSize: _cellSize,
                gap: _gap,
                items: List<GridItem>.from(_items),
                onItemsChanged: _syncBoardItems,
                onItemRemoved: _removeWidget,
                onItemReset: _resetWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
