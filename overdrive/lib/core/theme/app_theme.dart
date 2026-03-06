/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_theme.dart - Centralized app theme and style definitions.
 ##
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
    static const Color primary = Color(0xFFC9A84C);
    static const Color backgroundDark = Color(0xFF1A1A1A);
    static const Color backgroundLight = Color(0xFFF5F5F5);
    static const Color surfaceDark = Color(0xFF2A2A2A);
    static const Color surfaceLight = Color(0xFFFFFFFF);
    static const Color onPrimary = Color(0xFF1A1A1A);
    static const Color error = Color(0xFFE8002D);
}

class AppTheme {
    static ThemeData get darkTheme {
        final ColorScheme colorScheme = ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
        ).copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceDark,
            error: AppColors.error,
        );

        return _buildTheme(
            colorScheme: colorScheme,
            backgroundColor: AppColors.backgroundDark,
        );
    }

    static ThemeData get lightTheme {
        final ColorScheme colorScheme = ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
        ).copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceLight,
            error: AppColors.error,
        );

        return _buildTheme(
            colorScheme: colorScheme,
            backgroundColor: AppColors.backgroundLight,
        );
    }

    static ThemeData _buildTheme({
        required ColorScheme colorScheme,
        required Color backgroundColor,
    }) {
        final TextTheme textTheme = _textTheme(colorScheme.onSurface);

        return ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: backgroundColor,
            textTheme: textTheme,
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: colorScheme.onSurface,
            ),
            cardTheme: CardThemeData(
                color: colorScheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
            ),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                    ),
                ),
            ),
        );
    }

    static TextTheme _textTheme(Color textColor) {
        const TextStyle sansBase = TextStyle(
            fontFamilyFallback: <String>[
                'Helvetica Neue',
                'Helvetica',
            ],
        );

        return TextTheme(
            displayLarge: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
            ),
            headlineMedium: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
            ),
            titleMedium: sansBase.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
            ),
            bodyMedium: sansBase.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
            ),
            labelSmall: sansBase.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
            ),
        );
    }
}
