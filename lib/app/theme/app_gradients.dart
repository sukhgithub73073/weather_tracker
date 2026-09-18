import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Every gradient the UI uses, so surfaces stay consistent across screens.
class AppGradients {
  AppGradients._();

  static bool _dark(Brightness b) => b == Brightness.dark;

  /// Page background behind all scrollable content.
  static LinearGradient scaffold(Brightness brightness) => _dark(brightness)
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1B31), Color(0xFF071021)],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6EFFA), Color(0xFFF7FAFE)],
        );

  /// Cards, sheets and bars.
  static LinearGradient card(Brightness brightness) => _dark(brightness)
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF182C4E), Color(0xFF0F1F3B)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFF5FD)],
        );

  /// Soft wash of an accent colour – detail tiles, banners, chips.
  static LinearGradient tint(
    Color accent,
    Brightness brightness, {
    double strength = 1,
  }) {
    final dark = _dark(brightness);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withValues(alpha: (dark ? 0.30 : 0.20) * strength),
        accent.withValues(alpha: (dark ? 0.10 : 0.05) * strength),
      ],
    );
  }

  /// Solid badge / icon circle in an accent colour.
  static LinearGradient badge(Color accent) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(accent, Colors.white, 0.18)!,
          accent,
          Color.lerp(accent, Colors.black, 0.18)!,
        ],
        stops: const [0, 0.55, 1],
      );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
  );

  static const LinearGradient search = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26C6DA), Color(0xFF1E88E5)],
  );

  static const LinearGradient favorite = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5F8F), Color(0xFFFF8E72)],
  );

  static const LinearGradient settings = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
  );

  static const LinearGradient sun = AppColors.sunGradient;

  /// Elevation for cards and floating bars.
  static List<BoxShadow> cardShadow(Brightness brightness) => [
        BoxShadow(
          color: _dark(brightness)
              ? Colors.black.withValues(alpha: 0.35)
              : AppColors.primary.withValues(alpha: 0.10),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> floatingShadow(Brightness brightness) => [
        BoxShadow(
          color: _dark(brightness)
              ? Colors.black.withValues(alpha: 0.45)
              : AppColors.primaryDark.withValues(alpha: 0.22),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
