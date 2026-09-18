import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colors that Material's [ColorScheme] does not model but the app needs
/// consistently in both themes. Access via `context.appColors`.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.textSecondary,
    required this.cardBorder,
    required this.cardShadow,
    required this.glassFill,
    required this.glassBorder,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.chipBackground,
    required this.divider,
  });

  final Color textSecondary;
  final Color cardBorder;
  final Color cardShadow;
  final Color glassFill;
  final Color glassBorder;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color chipBackground;
  final Color divider;

  static const AppColorsExtension light = AppColorsExtension(
    textSecondary: AppColors.textSecondaryLight,
    cardBorder: Color(0xFFE1E9F2),
    cardShadow: Color(0x141E88E5),
    glassFill: Color(0x33FFFFFF),
    glassBorder: Color(0x59FFFFFF),
    shimmerBase: Color(0xFFE6EDF5),
    shimmerHighlight: Color(0xFFF7FAFD),
    chipBackground: AppColors.lightSurfaceVariant,
    divider: Color(0xFFE1E9F2),
  );

  static const AppColorsExtension dark = AppColorsExtension(
    textSecondary: AppColors.textSecondaryDark,
    cardBorder: Color(0xFF223554),
    cardShadow: Color(0x33000000),
    glassFill: Color(0x1FFFFFFF),
    glassBorder: Color(0x38FFFFFF),
    shimmerBase: Color(0xFF1A2D4A),
    shimmerHighlight: Color(0xFF243B5E),
    chipBackground: AppColors.darkSurfaceElevated,
    divider: Color(0xFF223554),
  );

  @override
  AppColorsExtension copyWith({
    Color? textSecondary,
    Color? cardBorder,
    Color? cardShadow,
    Color? glassFill,
    Color? glassBorder,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? chipBackground,
    Color? divider,
  }) {
    return AppColorsExtension(
      textSecondary: textSecondary ?? this.textSecondary,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      chipBackground: chipBackground ?? this.chipBackground,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
