/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_theme.dart - Centralized app theme, colors, and text styles.
 ##
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF161616);
  static const Color surfaceBorder = Color(0x1FFFFFFF);
  static const Color divider = Color(0x14FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x8CFFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);
  static const Color accent = Color(0xFFC9A84C);
  static const Color success = Color(0xFF2F8F4E);
  static const Color error = Color(0xFFB53A3A);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({Color color = AppColors.textPrimary}) =>
      GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  static const TextStyle _baseText = TextStyle(
    fontFamilyFallback: ['Helvetica Neue', 'Helvetica'],
  );

  static TextStyle body({Color color = AppColors.textPrimary}) => _baseText
      .copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: color);

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) => _baseText
      .copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: color);

  static TextStyle caption({Color color = AppColors.textSecondary}) => _baseText
      .copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: color);

  static TextStyle label({Color color = AppColors.textMuted}) =>
      _baseText.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.8,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.black,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.black,
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        color: AppColors.divider,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTextStyles.body(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.black,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
