import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_mock_data.dart';

Color teamColor(String team) => switch (team) {
      'Red Bull Racing' => const Color(0xFF3671C6),
      'Ferrari' => const Color(0xFFE8002D),
      'McLaren' => const Color(0xFFFF8000),
      _ => AppColors.gold,
    };

Future<void> showTelemetryWidgetMenu(
  BuildContext context, {
  required String widgetLabel,
  String? currentDriverId,
  ValueChanged<String>? onDriverSelected,
  VoidCallback? onReset,
  VoidCallback? onRemove,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    _TelemetryMenuRoute(
      widgetLabel: widgetLabel,
      currentDriverId: currentDriverId,
      onDriverSelected: onDriverSelected,
      onReset: onReset,
      onRemove: onRemove,
    ),
  );
}

class _TelemetryMenuRoute extends PopupRoute<void> {
  _TelemetryMenuRoute({
    required this.widgetLabel,
    this.currentDriverId,
    this.onDriverSelected,
    this.onReset,
    this.onRemove,
  });

  final String widgetLabel;
  final String? currentDriverId;
  final ValueChanged<String>? onDriverSelected;
  final VoidCallback? onReset;
  final VoidCallback? onRemove;

  @override
  // Transparent barrier — the blur + tint overlay is drawn manually inside buildPage
  // so we can animate its opacity independently from the card scale animation.
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: FadeTransition(
                opacity: fade,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: const ColoredBox(color: AppColors.overlay),
                ),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: scale,
              child: FadeTransition(
                opacity: fade,
                child: _MenuCard(
                  widgetLabel: widgetLabel,
                  currentDriverId: currentDriverId,
                  onDriverSelected: onDriverSelected,
                  onReset: onReset,
                  onRemove: onRemove,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.widgetLabel,
    this.currentDriverId,
    this.onDriverSelected,
    this.onReset,
    this.onRemove,
  });

  final String widgetLabel;
  final String? currentDriverId;
  final ValueChanged<String>? onDriverSelected;
  final VoidCallback? onReset;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasDrivers = currentDriverId != null && onDriverSelected != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 48,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
                child: Row(
                  children: [
                    Text(widgetLabel, style: AppTextStyles.bodyBold()),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDrivers) ...[
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                  child: Text(
                    'DRIVER',
                    style: AppTextStyles.label(color: AppColors.textMuted),
                  ),
                ),
                for (final driver in TelemetryMockData.drivers)
                  _DriverRow(
                    driver: driver,
                    isSelected: driver['id'] == currentDriverId,
                    onTap: () {
                      onDriverSelected!(driver['id'] as String);
                      Navigator.of(context).maybePop();
                    },
                  ),
                const SizedBox(height: 6),
              ],
              const Divider(height: 1, color: AppColors.divider),
              if (onReset != null)
                _ActionRow(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset size',
                  color: AppColors.textSecondary,
                  onTap: () {
                    Navigator.of(context).maybePop();
                    onReset!();
                  },
                ),
              if (onRemove != null) ...[
                const Divider(height: 1, color: AppColors.divider),
                _ActionRow(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove widget',
                  color: AppColors.red,
                  onTap: () {
                    Navigator.of(context).maybePop();
                    onRemove!();
                  },
                ),
              ],
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.driver,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> driver;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = teamColor(driver['team'] as String);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tc.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? tc.withValues(alpha: 0.45) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tc.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                driver['id'] as String,
                style: AppTextStyles.label(color: AppColors.white)
                    .copyWith(fontSize: 10),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver['name'] as String, style: AppTextStyles.body()),
                  Text(
                    driver['team'] as String,
                    style: AppTextStyles.caption(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              'P${driver['position']}',
              style: AppTextStyles.label(color: AppColors.textMuted),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_rounded, size: 15, color: tc),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body(color: color)),
          ],
        ),
      ),
    );
  }
}
