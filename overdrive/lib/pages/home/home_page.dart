/*
##
## OverDrive 2026
## All Technical rights reserved
##
## home_page.dart - Home screen shell providing the root scaffold and entry point for the bottom navigation.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/base/demo_liquid.dart';

// Root scaffold for the home screen; currently hosts the liquid glass calibration gallery.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liquid Glass',
                    style: AppTextStyles.bodyBold().copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calibration des surfaces',
                    style: AppTextStyles.body(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // 1 — Très léger, blanc
                  const _DemoRow(
                    label: 'Très léger — blanc',
                    child: DemoLiquid(
                      tintOpacity: 0.04,
                      blurSigma: 12.0,
                      specularOpacity: 0.04,
                      edgeColor: Color(0x18FFFFFF),
                      height: 64,
                    ),
                  ),

                  // 2 — Léger, blanc
                  const _DemoRow(
                    label: 'Léger — blanc',
                    child: DemoLiquid(
                      tintOpacity: 0.08,
                      blurSigma: 16.0,
                      specularOpacity: 0.06,
                      edgeColor: Color(0x22FFFFFF),
                      height: 64,
                    ),
                  ),

                  // 3 — Léger, gris
                  const _DemoRow(
                    label: 'Léger — gris',
                    child: DemoLiquid(
                      tintOpacity: 0.08,
                      blurSigma: 16.0,
                      specularOpacity: 0.06,
                      edgeColor: Color(0x22AAAAAA),
                      fillColor: Color(0x0CAAAAAA),
                      height: 64,
                    ),
                  ),

                  // 4 — Moyen, blanc
                  const _DemoRow(
                    label: 'Moyen — blanc',
                    child: DemoLiquid(
                      tintOpacity: 0.14,
                      blurSigma: 22.0,
                      specularOpacity: 0.10,
                      edgeColor: Color(0x30FFFFFF),
                      height: 72,
                    ),
                  ),

                  // 5 — Moyen, gris
                  const _DemoRow(
                    label: 'Moyen — gris',
                    child: DemoLiquid(
                      tintOpacity: 0.14,
                      blurSigma: 22.0,
                      specularOpacity: 0.08,
                      edgeColor: Color(0x28888888),
                      fillColor: Color(0x12888888),
                      height: 72,
                    ),
                  ),

                  // 6 — Moyen+, blanc, grande hauteur
                  const _DemoRow(
                    label: 'Moyen+ — blanc, haut',
                    child: DemoLiquid(
                      tintOpacity: 0.20,
                      blurSigma: 26.0,
                      specularOpacity: 0.12,
                      vibrancyIntensity: 0.05,
                      edgeColor: Color(0x38FFFFFF),
                      height: 96,
                      borderRadius: 26,
                    ),
                  ),

                  // 7 — Fort, blanc
                  const _DemoRow(
                    label: 'Fort — blanc',
                    child: DemoLiquid(
                      tintOpacity: 0.28,
                      blurSigma: 32.0,
                      specularOpacity: 0.14,
                      vibrancyIntensity: 0.06,
                      edgeColor: Color(0x44FFFFFF),
                      height: 72,
                    ),
                  ),

                  // 8 — Fort, gris foncé
                  const _DemoRow(
                    label: 'Fort — gris foncé',
                    child: DemoLiquid(
                      tintOpacity: 0.28,
                      blurSigma: 32.0,
                      specularOpacity: 0.10,
                      edgeColor: Color(0x30666666),
                      fillColor: Color(0x1A555555),
                      height: 72,
                    ),
                  ),

                  // 9 — Très fort, blanc, pill
                  const _DemoRow(
                    label: 'Très fort — blanc, pill',
                    child: DemoLiquid(
                      tintOpacity: 0.38,
                      blurSigma: 38.0,
                      specularOpacity: 0.16,
                      vibrancyIntensity: 0.08,
                      edgeColor: Color(0x55FFFFFF),
                      height: 56,
                      borderRadius: 999,
                    ),
                  ),

                  // 10 — Maximum, gris blanc
                  const _DemoRow(
                    label: 'Maximum — gris blanc',
                    child: DemoLiquid(
                      tintOpacity: 0.50,
                      blurSigma: 44.0,
                      noiseOpacity: 0.02,
                      specularOpacity: 0.20,
                      vibrancyIntensity: 0.10,
                      edgeColor: Color(0x60DDDDDD),
                      fillColor: Color(0x14DDDDDD),
                      height: 88,
                      borderRadius: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row wrapper with label ────────────────────────────────────────────────

// Labeled wrapper that pairs a preset name with its DemoLiquid surface.
class _DemoRow extends StatelessWidget {
  const _DemoRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────

// Multi-layer gradient and radial white-blob backdrop rendered behind the gallery content.
class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.grayOpaque.withValues(alpha: 0.16),
            AppColors.black,
            AppColors.black,
          ],
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grayOpaque.withValues(alpha: 0.12),
                  Colors.transparent,
                  AppColors.black.withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          // ── White blob ──────────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.55,
                  colors: [
                    Colors.white.withValues(alpha: 0.46),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
