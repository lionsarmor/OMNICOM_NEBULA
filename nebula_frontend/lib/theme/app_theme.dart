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

    iconTheme: const IconThemeData(color: AppColors.accentDark, size: 22),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentDark,
      foregroundColor: Colors.black,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentDark,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryDarkBright),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodyLarge: TextStyle(color: AppColors.textDarkStrong, fontSize: 16),
      labelLarge: TextStyle(color: AppColors.accentDark),
    ),
  );

  /// ☀️ LIGHT MODE — Classic AOL blue + yellow highlights
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLightHighlight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: AppColors.primaryLightDark, // 🌙 darker icon color
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.primaryLightDark, size: 22),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentLightHighlight, // 🟡 yellow buttons
        foregroundColor: AppColors.textLight, // navy text
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLightBright, // blue links
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLight),
      bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
      labelLarge: TextStyle(color: AppColors.primaryLightBright),
    ),
  );
}
