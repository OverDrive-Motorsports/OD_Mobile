/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [speedometer.dart] - Telemetry widget displaying real-time vehicle speed in km/h with DRS and gear indicators.
 ##
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../core/theme/app_theme.dart';
import 'telemetry_item_actions.dart';
import 'telemetry_mock_data.dart';
import 'telemetry_widget_menu.dart';
import 'telemetry_widget_style.dart';
import '../../core/di/telemetry_di.dart';
import '../../domain/championship/driver.dart';

// Telemetry widget for vehicle speed; switches between compact and detailed
// layouts based on available grid cell size via TelemetryMode.

class Speedometer extends StatefulWidget {
  const Speedometer({
    this.initialDriverId = 'VER',
    this.sessionId,
    this.drivers = const [],
    super.key,
  });

  final String initialDriverId;
  final String? sessionId;
  final List<Driver> drivers;

  @override
  State<Speedometer> createState() => _SpeedometerState();
}


class _SpeedometerState extends State<Speedometer> {
  late String _driverId;

  final TelemetryDependencyProvider _telemetryProvider =
      TelemetryDependencyProvider();

  double? _apiSpeed;
  bool _isLoadingSpeed = false;
  String? _speedError;
  Timer? _playbackTimer;
  int _loadRequestId = 0;

  int? get _selectedDriverNumber {
    final searchTerm = switch (_driverId) {
      'VER' => 'verstappen',
      'LEC' => 'leclerc',
      'NOR' => 'norris',
      _ => _driverId.toLowerCase(),
    };

    for (final driver in widget.drivers) {
      if (driver.fullName.toLowerCase().contains(searchTerm)) {
        return driver.driverNumber;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _driverId = widget.initialDriverId;
    _loadApiSpeed();
  }

  @override
  void didUpdateWidget(covariant Speedometer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionId != widget.sessionId ||
        oldWidget.drivers != widget.drivers) {
      _loadApiSpeed();
    }
  }

  
  
Future<void> _loadApiSpeed() async {
    _playbackTimer?.cancel();
    _playbackTimer = null;

    final requestId = ++_loadRequestId;
    final sessionId = widget.sessionId;
    final driverNumber = _selectedDriverNumber;
debugPrint('[Speedometer] sessionId: $sessionId');
debugPrint('[Speedometer] driverNumber: $driverNumber');
    if (sessionId == null ||
        sessionId.isEmpty ||
        driverNumber == null) {
        setState(() {
            _apiSpeed = null;
            _isLoadingSpeed = false;
            _speedError = null;
        });
        return;
    }

    setState(() {
        _apiSpeed = null;
        _isLoadingSpeed = true;
        _speedError = null;
    });

    try {
        final telemetry = await _telemetryProvider
            .getTelemetrySpeedUseCase(
                sessionId: sessionId,
                driverNumber: driverNumber,
            );

        if (!mounted || requestId != _loadRequestId) return;

        if (telemetry.isEmpty) {
            setState(() {
                _apiSpeed = null;
                _isLoadingSpeed = false;
                _speedError = 'No speed data';
            });
            return;
        }

        // Sort samples by timestamp, from oldest to newest.
        final samples = [...telemetry];

        samples.sort((a, b) {
            final timeA = DateTime.parse(a.timestamp.toString());
            final timeB = DateTime.parse(b.timestamp.toString());
            return timeA.compareTo(timeB);
        });

        // Show the first sample immediately.
        setState(() {
            _apiSpeed = samples.first.speed;
            _isLoadingSpeed = false;
            _speedError = null;
        });

        // Play the remaining samples using their original time intervals.
        _scheduleNextSpeedSample(samples, 1, requestId);
    } catch (error) {
        if (!mounted || requestId != _loadRequestId) return;

        setState(() {
            _apiSpeed = null;
            _isLoadingSpeed = false;
            _speedError = 'API unavailable';
        });

        debugPrint('[Speedometer] Error loading telemetry: $error');
    }
}

void _scheduleNextSpeedSample(
    List<dynamic> samples,
    int index,
    int requestId,
) {
    if (!mounted ||
        requestId != _loadRequestId ||
        index >= samples.length) {
        return;
    }

    final previousTime = DateTime.parse(
        samples[index - 1].timestamp.toString(),
    );
    final currentTime = DateTime.parse(
        samples[index].timestamp.toString(),
    );

    final delayMs = currentTime
        .difference(previousTime)
        .inMilliseconds;

    _playbackTimer = Timer(
        Duration(milliseconds: delayMs < 0 ? 0 : delayMs),
        () {
            if (!mounted || requestId != _loadRequestId) return;

            setState(() {
                _apiSpeed = samples[index].speed;
            });

            _scheduleNextSpeedSample(
                samples,
                index + 1,
                requestId,
            );
        },
    );
}

@override
void dispose() {
    _playbackTimer?.cancel();
    _loadRequestId++;
    super.dispose();
}


  void _showMenu(BuildContext context) {
    final actions = TelemetryItemActions.maybeOf(context);

    showTelemetryWidgetMenu(
      context,
      widgetLabel: 'Speed',
      currentDriverId: _driverId,
      onDriverSelected: (id) {
        setState(() {
          _driverId = id;
          _apiSpeed = null;
        });
        _loadApiSpeed();
      },
      onReset: actions?.onReset,
      onRemove: actions?.onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TelemetrySimulator>().getSnapshot(_driverId);
    final displayedSpeed = _apiSpeed;

    return GestureDetector(
      onTap: () => _showMenu(context),
      child: TelemetryCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mode = telemetryMode(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: mode == TelemetryMode.small
                        ? _SmallSpeed(
                            data: data,
                            driverId: _driverId,
                            speed: displayedSpeed,
                          )
                        : _LargeSpeed(
                            data: data,
                            driverId: _driverId,
                            speed: displayedSpeed,
                          ),
                  ),
                  if (_isLoadingSpeed)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  if (_speedError != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text(
                        _speedError!,
                        style: AppTextStyles.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 9),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


// ── Small ─────────────────────────────────────────────────────────────────────

class _SmallSpeed extends StatelessWidget {
  const _SmallSpeed({
      required this.data,
      required this.driverId,
      required this.speed,
  });

  final TelemetrySnapshot data;
  final String driverId;
  final double? speed;

  @override
  Widget build(BuildContext context) {
    final speedValue = speed ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SPEED', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: speedValue),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (_, v, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    speed == null ? '—' : v.toInt().toString(),
                    style: AppTextStyles.display(color: AppColors.textPrimary)
                        .copyWith(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -2),
                  ),
                  Text(
                    'km/h',
                    style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        TelemetryBar(
          fraction: speedValue / 340,
          color: AppColors.white.withValues(alpha: 0.60),
        ),
      ],
    );
  }
}

// ── Large ─────────────────────────────────────────────────────────────────────

class _LargeSpeed extends StatelessWidget {
  const _LargeSpeed({
      required this.data,
      required this.driverId,
      required this.speed,
  });

  final TelemetrySnapshot data;
  final String driverId;
  final double? speed;

  @override
  Widget build(BuildContext context) {
    final speedValue = speed ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TelemetryHeader(label: 'SPEED', driverId: driverId),
        Expanded(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: speedValue),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (_, v, _) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Fixed-width right-aligned so digits don't shift the layout
                  SizedBox(
                    width: 92,
                    child: Text(
                      speed == null ? '—' : v.toInt().toString(),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.display(color: AppColors.textPrimary)
                          .copyWith(fontSize: 58, fontWeight: FontWeight.bold, letterSpacing: -3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'km/h',
                    style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        // DRS + Gear row
        Row(
          children: [
            _DrsChip(active: data.drs),
            const Spacer(),
            _GearChip(gear: data.gear),
          ],
        ),
        const SizedBox(height: 8),
        // Speed vs max bar
        Row(
          children: [
            Text(
              'TOP ${data.maxSpeedLap.toInt()}',
              style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
            ),
            const Spacer(),
            Text(
              'AVG ${data.avgSpeedLap.toInt()}',
              style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TelemetryBar(
          fraction: speedValue / 340,
          color: AppColors.white.withValues(alpha: 0.60),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DrsChip extends StatelessWidget {
  const _DrsChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.textMuted.withValues(alpha: 0.40);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.label(color: color).copyWith(fontSize: 10),
          child: const Text('DRS'),
        ),
      ],
    );
  }
}

class _GearChip extends StatelessWidget {
  const _GearChip({required this.gear});
  final int gear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'G',
          style: AppTextStyles.caption(color: AppColors.textMuted).copyWith(fontSize: 10),
        ),
        const SizedBox(width: 2),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: gear.toDouble()),
          duration: const Duration(milliseconds: 120),
          builder: (_, v, _) => Text(
            v.round().toString(),
            style: AppTextStyles.bodyBold(color: AppColors.textPrimary).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
