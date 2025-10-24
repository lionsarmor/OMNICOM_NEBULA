import 'package:flutter/material.dart';

/// ===============================================================
/// 🪐 NEBULA MASTER COLOR RECORD
/// Centralized color definitions for all UI themes and components.
/// Every other file (main.dart, pages, widgets) should import from here.
/// ===============================================================
class AppColors {
  // =============================
  // 🌙 DARK MODE PALETTE
  // =============================
  static const backgroundDark = Color(0xFF0C0F1A);
  static const surfaceDark = Color(0xFF141B2E);
  static const primaryDark = Color(0xFF33A0FF); // Electric blue highlight
  static const primaryDarkDim = Color(0xFF1E70CC); // Dimmed variant for icons
  static const primaryDarkBright = Color(0xFF66B8FF); // Brighter edge / hover
  static const accentDark = Color(0xFFFFEA00); // Neon yellow accents
  static const accentDarkSoft = Color(0xFFFFF380); // Softer yellow glow
  static const accentDarkDeep = Color(0xFFCFC000); // Deeper yellow for contrast
  static const textDark = Colors.white70;
  static const textDarkStrong = Colors.white;
  static const borderDark = Color(0xFF1E2435);

  // =============================
  // ☀️ LIGHT MODE — “AOL CLASSIC”
  // =============================
  static const backgroundLight = Color(0xFFE4E9F4); // Soft gray-blue base
  static const surfaceLight = Color(0xFFD9E4FF); // Panel / card blue
  static const primaryLight = Color(0xFF0044AA); // AOL deep blue
  static const primaryLightDark = Color(
    0xFF002A66,
  ); // Deeper blue (navbar / icons)
  static const primaryLightBright = Color(
    0xFF1A73E8,
  ); // Accent blue (hover / link)
  static const accentLight = Color(0xFF0066FF); // Bright link blue
  static const accentLightSoft = Color(0xFF99C2FF); // Lighter hover tone
  static const accentLightHighlight = Color(
    0xFFFFEA00,
  ); // Shared neon accent for buttons
  static const textLight = Color(0xFF001A44); // Strong navy for text
  static const textLightMuted = Color(0xFF334D80);
  static const borderLight = Color(0xFFB3C7FF);

  // =============================
  // 🧱 UTILITY COLORS
  // =============================
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFC400);
  static const error = Color(0xFFD50000);
  static const info = Color(0xFF29B6F6);

  // =============================
  // 🎨 GRADIENTS
  // =============================
  static const darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF003366), Color(0xFF000820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lightHeaderGradient = LinearGradient(
    colors: [Color(0xFF33A0FF), Color(0xFF0044AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
