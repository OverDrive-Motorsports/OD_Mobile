/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_page.dart - Freeform drag-and-resize telemetry dashboard page composing all 22 telemetry widgets.
 ##
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/base/app_modal.dart';
import '../../widgets/telemetry/damage.dart';
import '../../widgets/telemetry/drs_ers.dart';
import '../../widgets/telemetry/lap_history.dart';
import '../../widgets/telemetry/lap_position.dart';
import '../../widgets/telemetry/pedal_trace.dart';
import '../../widgets/telemetry/weather_forecast.dart';
import '../../widgets/telemetry/weather_radar.dart';
import '../../widgets/telemetry/driver_snapshot.dart';
import '../../widgets/telemetry/engine_temps.dart';
import '../../widgets/telemetry/fuel_gauge.dart';
import '../../widgets/telemetry/g_force.dart';
import '../../widgets/telemetry/gear_rpm.dart';
import '../../widgets/telemetry/lap_delta.dart';
import '../../widgets/telemetry/penalty.dart';
import '../../widgets/telemetry/pit_strategy.dart';
import '../../widgets/telemetry/sector_split.dart';
import '../../widgets/telemetry/speedometer.dart';
import '../../widgets/telemetry/race_standings.dart';
import '../../widgets/telemetry/telemetry_mock_data.dart';
import '../../widgets/telemetry/throttle_brake.dart';
import '../../widgets/telemetry/tire_temps.dart';
import '../../widgets/telemetry/weather.dart';
import 'grid/grid_board.dart';
import 'grid/grid_item.dart';

// ─── Widget catalogue ─────────────────────────────────────────────────────────

// Enum listing every addable telemetry widget with its display label and icon.
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
  standings('Standings', Icons.format_list_numbered_rounded),
  penalty('Penalties', Icons.gavel_rounded),
  damage('Damage', Icons.car_crash_rounded),
  lapHistory('Lap History', Icons.show_chart_rounded),
  lapPosition('Lap Positions', Icons.swap_vert_rounded),
  pedalTrace('Pedal Trace', Icons.stacked_line_chart_rounded),
  weatherForecast('Météo Prévisions', Icons.wb_cloudy_rounded),
  weatherRadar('Radar Météo', Icons.radar_rounded);

  const _WidgetType(this.label, this.icon);
  final String label;
  final IconData icon;
}

// Factory that instantiates the concrete telemetry widget for a given catalogue entry.
Widget _buildWidget(_WidgetType type) => switch (type) {
      _WidgetType.speedometer => const Speedometer(),
      _WidgetType.gearRpm => const GearRpm(),
      _WidgetType.throttleBrake => const ThrottleBrake(),
      _WidgetType.lapDelta => const LapDelta(),
      _WidgetType.drsErs => const DrsErs(),
      _WidgetType.gForce => const GForce(),
      _WidgetType.sectorSplit => const SectorSplit(),
      _WidgetType.driverSnapshot => const DriverSnapshot(),
      _WidgetType.tireTemp => const TireTemps(),
      _WidgetType.fuel => const FuelGauge(),
      _WidgetType.weather => const Weather(),
      _WidgetType.pitStrategy => const PitStrategy(),
      _WidgetType.engine => const EngineTemps(),
      _WidgetType.standings => const RaceStandings(),
      _WidgetType.penalty => const Penalty(),
      _WidgetType.damage => const Damage(),
      _WidgetType.lapHistory => const LapHistory(),
      _WidgetType.lapPosition => const LapPosition(),
      _WidgetType.pedalTrace => const PedalTrace(),
      _WidgetType.weatherForecast => const WeatherForecast(),
      _WidgetType.weatherRadar => const WeatherRadar(),
    };

// ─── Page root — owns the simulator ──────────────────────────────────────────

// Provides the TelemetrySimulator to the widget subtree and delegates layout to _TelemetryBoard.
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
  static const double _gap = 4;
  static const double _boardPaddingV = 12;
  static const int _defaultColSpan = 2;
  static const int _defaultRowSpan = 2;

  final List<GridItem> _items = [
    GridItem(
      id: 'speedometer_0',
      col: 0,
      row: 0,
      colSpan: _defaultColSpan,
      rowSpan: _defaultRowSpan,
      child: const Speedometer(),
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

  // One extra column beyond the natural fit so the grid fills the full width.
  int _responsiveCols() {
    final w = MediaQuery.sizeOf(context).width;
    final base = math.max(_minCols, ((w + _gap) / (64.0 + _gap)).floor());
    return base + 1;
  }

  // Cell size computed so cols×(cellSize+gap)−gap == screenWidth exactly.
  double _cellSizeForCols(int cols) {
    final w = MediaQuery.sizeOf(context).width;
    return (w + _gap) / cols - _gap;
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
    AppModal.show<void>(
      context,
      title: 'Ajouter un widget',
      child: _WidgetPickerGrid(onSelected: _addWidget),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cols = _responsiveCols();
    final cellSize = _cellSizeForCols(cols);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        leading: AppButton(
          icon: Icons.arrow_back_rounded,
          onPressed: _goBack,
        ),
        title: Text('Telemetry', style: AppTextStyles.bodyBold()),
        actions: [
          AppButton(
            icon: Icons.add_rounded,
            onPressed: _showAddSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _verticalScroll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _boardPaddingV),
          child: GridBoard(
            cols: cols,
            rows: _rows,
            cellSize: cellSize,
            gap: _gap,
            items: List<GridItem>.from(_items),
            onItemsChanged: _syncBoardItems,
            onItemRemoved: _removeWidget,
            onItemReset: _resetWidget,
          ),
        ),
      ),
    );
  }
}

// ─── Widget picker ─────────────────────────────────────────────────────────────

// 3-column grid shown in the add-widget bottom sheet; tapping a tile inserts it onto the board.
class _WidgetPickerGrid extends StatelessWidget {
  const _WidgetPickerGrid({required this.onSelected});

  final ValueChanged<_WidgetType> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _WidgetType.values.length,
      itemBuilder: (context, index) {
        final type = _WidgetType.values[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
            onSelected(type);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(type.icon, color: AppColors.gold, size: 22),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    type.label,
                    style: AppTextStyles.body(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
