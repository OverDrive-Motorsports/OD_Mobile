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

  static const Color black        = Color(0xFF000000);
  static const Color bg           = Color(0xFF0A0A0A);
  static const Color surface1     = Color(0xFF111111);
  static const Color surface2     = Color(0xFF1A1A1A);

  static const Color glass        = Color(0x12FFFFFF);
  static const Color glassBorder  = Color(0x1FFFFFFF);
  static const Color glassDivider = Color(0x14FFFFFF);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x8CFFFFFF);
  static const Color textMuted     = Color(0x66FFFFFF);
  static const Color textTertiary  = textMuted;
  static const Color divider       = glassDivider;

  static const Color gold = Color(0xFFC9A84C);
  static const Color red  = Color(0xFFE8002D);
  static const Color f1Red = red;

  static const Color teamMercedes = Color(0xFF27F4D2);
  static const Color teamFerrari  = Color(0xFFE8002D);
  static const Color teamRedBull  = Color(0xFF3671C6);
  static const Color teamMcLaren  = Color(0xFFFF8000);
  static const Color teamAston    = Color(0xFF229971);
  static const Color teamWilliams = Color(0xFF64C4FF);
  static const Color teamSauber   = Color(0xFF52E252);

  static const Color sectorPurple = Color(0xFFC77DFF);
  static const Color sectorGreen  = Color(0xFF39D353);
  static const Color sectorYellow = Color(0xFFFFD60A);
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

  static TextStyle heading({Color color = AppColors.textPrimary}) =>
      GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle appBarTitle({Color color = AppColors.textPrimary}) =>
      GoogleFonts.orbitron(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.4,
      );

  static const TextStyle _hv = TextStyle(
    fontFamilyFallback: ['Helvetica Neue', 'Helvetica'],
  );

  static TextStyle sectionTitle({Color color = AppColors.textPrimary}) =>
      _hv.copyWith(fontSize: 17, fontWeight: FontWeight.w600, color: color);

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _hv.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: color);

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
      _hv.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: color);

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      _hv.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: color);

  static TextStyle captionBold({Color color = AppColors.textPrimary}) =>
      _hv.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: color);

  static TextStyle label({Color color = AppColors.textMuted}) =>
      _hv.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.8,
      );

  static TextStyle pill({Color color = AppColors.textPrimary}) =>
      _hv.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: color);
}

class AppText {
  AppText._();

  static TextStyle get display => AppTextStyles.display();
  static TextStyle get h2 => AppTextStyles.sectionTitle();
  static TextStyle get body => AppTextStyles.body();
  static TextStyle get caption => AppTextStyles.caption();
  static TextStyle get micro => AppTextStyles.label();
}


class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const ColorScheme cs = ColorScheme.dark(
      primary:   AppColors.gold,
      onPrimary: AppColors.black,
      surface:   AppColors.surface1,
      error:     AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.appBarTitle(),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glass,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        color: AppColors.glassDivider,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.gold.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label(color: AppColors.textPrimary);
          }
          return AppTextStyles.label(color: AppColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.textPrimary, size: 22);
          }
          return IconThemeData(color: AppColors.textMuted, size: 22);
        }),
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
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
