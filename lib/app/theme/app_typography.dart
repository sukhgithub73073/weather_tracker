import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Outfit for display/headlines (geometric, modern), Inter for body/labels.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;
    final body = GoogleFonts.interTextTheme(base);
    final display = GoogleFonts.outfitTextTheme(base);

    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return body
        .copyWith(
          displayLarge: display.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
          displayMedium: display.displayMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
          ),
          displaySmall: display.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
          headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: textColor, displayColor: textColor);
  }
}
