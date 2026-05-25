/**
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
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFC9A84C);
  static const Color red = Color(0xFFE8002D);
  static const Color blue = Color(0xFF0A84FF);
  static const Color green = Color(0xFF32D74B);

  static const Color grayOpaque = Color(0xFF262628);
  static const Color graySurface = Color(0xFF161616);
  static const Color grayText = Color(0x8CFFFFFF);

  static const Color background = black;
  static const Color surface = graySurface;
  static const Color surfaceElevated = grayOpaque;
  static const Color inputSurface = grayOpaque;
  static const Color toastSurface = grayOpaque;
  static const Color handle = grayText;
  static const Color divider = Color(0x14FFFFFF);
  static const Color border = Color(0x1FFFFFFF);
  static const Color overlay = Color(0x99000000);
  static const Color scrim = Color(0x1F000000);

  static const Color textPrimary = white;
  static const Color textSecondary = grayText;
  static const Color textMuted = Color(0xA8FFFFFF);
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
      primary: AppColors.gold,
      onPrimary: AppColors.black,
      surface: AppColors.surface,
      error: AppColors.red,
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
          backgroundColor: AppColors.gold,
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
