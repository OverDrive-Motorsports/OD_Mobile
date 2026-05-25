/*
##
## OverDrive 2026
## All Technical rights reserved
##
## auth_page_shell.dart - Shared visual shell for the authentication entry screens.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glass_pill.dart';

/// Shared page frame for login and registration screens.
class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    required this.formChild,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.footer,
    this.topAside,
    super.key,
  });

  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final Widget formChild;
  final Widget? footer;
  final Widget? topAside;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.black),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: topPadding + 72,
              child: Center(
                child: Image.asset(
                  'assets/logoOD/OverDrive_white&gold.png',
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 164, 20, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eyebrow != null) ...[
                          GlassPill(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  eyebrow!,
                                  style: AppTextStyles.label(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (title != null) ...[
                          Text(title!, style: AppTextStyles.display()),
                          if (subtitle != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              subtitle!,
                              style: AppTextStyles.body(
                                color: AppColors.textSecondary,
                              ).copyWith(height: 1.45),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                        if (topAside != null) ...[
                          topAside!,
                          const SizedBox(height: 24),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          padding: const EdgeInsets.all(22),
                          child: formChild,
                        ),
                        if (footer != null) ...[
                          const SizedBox(height: 18),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small footer link used to switch between auth flows.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.prompt,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String prompt;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(prompt, style: AppTextStyles.caption()),
          GestureDetector(
            onTap: onTap,
            child: Text(
              label,
              style: AppTextStyles.bodyBold(
                color: AppColors.gold,
              ).copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional informational card used by auth screens.
class AuthInfoCard extends StatelessWidget {
  const AuthInfoCard({
    required this.title,
    required this.description,
    this.trailing,
    super.key,
  });

  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.flash_on_rounded,
              size: 18,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption().copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
