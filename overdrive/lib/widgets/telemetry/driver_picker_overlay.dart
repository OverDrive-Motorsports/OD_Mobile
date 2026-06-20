import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'telemetry_mock_data.dart';

Color teamColor(String team) {
  switch (team) {
    case 'Red Bull Racing':
      return const Color(0xFF3671C6);
    case 'Ferrari':
      return const Color(0xFFE8002D);
    case 'McLaren':
      return const Color(0xFFFF8000);
    default:
      return AppColors.gold;
  }
}

Future<void> showDriverPicker(
  BuildContext context, {
  required String currentDriverId,
  required ValueChanged<String> onDriverSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Select Driver', style: AppTextStyles.bodyBold()),
                const Spacer(),
                Text('LONG PRESS ANY WIDGET', style: AppTextStyles.label()),
              ],
            ),
            const SizedBox(height: 12),
            for (final driver in TelemetryMockData.drivers)
              _DriverTile(
                driver: driver,
                isSelected: driver['id'] == currentDriverId,
                onTap: () {
                  onDriverSelected(driver['id'] as String);
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    ),
  );
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.6)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tc.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: tc.withValues(alpha: 0.6)),
              ),
              alignment: Alignment.center,
              child: Text(
                driver['id'] as String,
                style: AppTextStyles.label(color: AppColors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver['name'] as String, style: AppTextStyles.bodyBold()),
                  Text(driver['team'] as String, style: AppTextStyles.caption()),
                ],
              ),
            ),
            Text(
              'P${driver['position']}',
              style: AppTextStyles.bodyBold(color: AppColors.gold),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
