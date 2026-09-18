import 'package:flutter/material.dart';

/// Brand palette derived from the Weather Tracker logo.
class AppColors {
  AppColors._();

  // Brand blues
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDeep = Color(0xFF082B5C);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color skyLight = Color(0xFF90CAF9);
  static const Color skyPale = Color(0xFFE3F2FD);

  // Accents from the logo
  static const Color sun = Color(0xFFFFB300);
  static const Color sunLight = Color(0xFFFFD54F);
  static const Color sunDeep = Color(0xFFFF8F00);
  static const Color rain = Color(0xFF4FC3F7);
  static const Color cloud = Color(0xFFE8F1FB);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF3F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE9F0F8);
  static const Color textPrimaryLight = Color(0xFF0F1B2D);
  static const Color textSecondaryLight = Color(0xFF5B6B80);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF12213A);
  static const Color darkSurfaceElevated = Color(0xFF1A2D4A);
  static const Color textPrimaryDark = Color(0xFFF5F8FC);
  static const Color textSecondaryDark = Color(0xFFA7B4C6);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Alert severities
  static const Color severityExtreme = Color(0xFFD32F2F);
  static const Color severitySevere = Color(0xFFF4511E);
  static const Color severityModerate = Color(0xFFFFB300);
  static const Color severityMinor = Color(0xFF29B6F6);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B3D91), Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF29B6F6)],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient sunGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunLight, sun, sunDeep],
  );
}
