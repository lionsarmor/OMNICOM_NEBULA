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
  static const accentDark = Color(0xFFFFEA00); // Neon yellow accents
  static const textDark = Colors.white70;
  static const borderDark = Color(0xFF1E2435);

  // =============================
  // ☀️ LIGHT MODE — “AOL CLASSIC”
  // =============================
  static const backgroundLight = Color(0xFFE4E9F4); // Soft gray-blue base
  static const surfaceLight = Color(0xFFD9E4FF); // Panel / card blue
  static const primaryLight = Color(0xFF0044AA); // AOL deep blue
  static const accentLight = Color(0xFF0066FF); // Hover / link blue
  static const textLight = Color(0xFF001A44); // Strong navy for text
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
