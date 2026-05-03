/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_error_message.dart - Shared inline and banner error presentation widgets.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum ErrorMessageVariant { inline, banner }

/// A shared error widget with inline and banner layouts.
class OdErrorMessage extends StatelessWidget {
  const OdErrorMessage({
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

/// A small error row used under fields or sections.
class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.caption(
              color: AppColors.red,
            ).copyWith(fontSize: 12, height: 1.25),
          ),
        ),
      ],
    );
  }
}

/// A larger error card used for page-level or section-level feedback.
class _BannerErrorMessage extends StatelessWidget {
  const _BannerErrorMessage({required this.message, this.subtitle});

  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: AppTextStyles.bodyBold().copyWith(fontSize: 14),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption().copyWith(height: 1.35),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: AppColors.red),
          ),
        ],
      ),
    );
  }
}
