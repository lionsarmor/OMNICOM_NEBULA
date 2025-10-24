import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ===============================================================
/// 🌌 NEBULA THEME DEFINITIONS
/// Builds ThemeData for both Light (AOL) and Dark (Neon) modes.
/// ===============================================================
class AppTheme {
  /// 🌙 DARK MODE — Deep space with electric blue + neon yellow
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.accentDark,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.accentDark),
    ),
    iconTheme: const IconThemeData(color: AppColors.accentDark),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentDark,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
      labelLarge: TextStyle(color: AppColors.accentDark),
    ),
  );

  /// ☀️ LIGHT MODE — Classic AOL blue theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.primaryLight),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryLight),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLight),
      bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
      labelLarge: TextStyle(color: AppColors.accentLight),
    ),
  );
}
