/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_icon.dart - Reusable championship icon tile.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../glass_pill.dart';

/// A championship tile with a circular icon and text labels.
class ChampionshipIcon extends StatelessWidget {
  const ChampionshipIcon({
    required this.name,
    required this.logoAsset,
    required this.onTap,
    this.subtitle,
    this.isFavorite = false,
    super.key,
  });

  final String name;
  final String logoAsset;
  final String? subtitle;
  final bool isFavorite;
  final VoidCallback onTap;

  static const double _iconDiameter = 80;

  @override
  Widget build(BuildContext context) {
    final title = isFavorite ? '★ $name' : name;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _iconDiameter,
            height: _iconDiameter,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GlassPill(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.inputSurface,
                    borderColor: AppColors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox.expand(),
                  ),
                ),
                Center(child: _LogoContent(logoAsset: logoAsset)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold().copyWith(fontSize: 12),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

/// The centered logo content used inside the championship tile.
class _LogoContent extends StatelessWidget {
  const _LogoContent({required this.logoAsset});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    if (_isEmojiFallback(logoAsset)) {
      return Text(
        logoAsset,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 34, height: 1),
      );
    }

    return Image.asset(
      logoAsset,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return const Text(
          '🏁',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 34, height: 1),
        );
      },
    );
  }

  bool _isEmojiFallback(String value) {
    return !value.contains('/') && !value.contains('.');
  }
}
