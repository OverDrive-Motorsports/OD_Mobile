/*
##
## OverDrive 2026
## All Technical rights reserved
##
## error_message.dart - Shared inline and banner error presentation widgets.
##
*/

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Glass theme
// ---------------------------------------------------------------------------

const _kBannerEdgeColor = Color(0x80FF3030);

final _kBannerTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.42,
  blurSigma: 28.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.06,
  edgeLightColor: _kBannerEdgeColor,
  edgeShadowColor: _kBannerEdgeColor,
);

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Visual variants supported by the shared error message widget.
enum ErrorMessageVariant { inline, banner }

/// A shared error widget with inline and banner layouts.
class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    required this.message,
    this.subtitle,
    this.variant = ErrorMessageVariant.inline,
    super.key,
  });

  final String message;
  final String? subtitle;
  final ErrorMessageVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ErrorMessageVariant.inline => _InlineErrorMessage(message: message),
      ErrorMessageVariant.banner => _BannerErrorMessage(
        message: message,
        subtitle: subtitle,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Inline
// ---------------------------------------------------------------------------

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.red.withValues(alpha: 0.90),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.caption(
              color: AppColors.red.withValues(alpha: 0.90),
            ).copyWith(fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner
// ---------------------------------------------------------------------------

class _BannerErrorMessage extends StatelessWidget {
  const _BannerErrorMessage({required this.message, this.subtitle});

  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kBannerTheme,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // ── Red fill ────────────────────────────────────────────────
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.red.withValues(alpha: 0.28),
                ),
              ),

              // ── Content ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 22,
                        color: AppColors.red.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            style: AppTextStyles.bodyBold().copyWith(
                              fontSize: 15,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              subtitle!,
                              style: AppTextStyles.body(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 13, height: 1.35),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Red border overlay ──────────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.80),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
