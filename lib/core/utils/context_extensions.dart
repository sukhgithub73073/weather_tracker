import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extension.dart';

/// Shorthands so widgets stay readable.
///
/// Member names deliberately avoid GetX's `ContextExtensionss` (`theme`,
/// `textTheme`, `isTablet`) so files that import both never hit an
/// ambiguous-extension error.
extension ThemeContext on BuildContext {
  ThemeData get themeData => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
  Brightness get brightness => Theme.of(this).brightness;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

extension LayoutContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isWideScreen => screenSize.shortestSide >= 600;
}
