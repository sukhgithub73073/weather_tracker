import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// Full-bleed gradient container. Animates smoothly when [gradient] changes
/// (e.g. when the weather condition updates).
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.brandGradient,
    this.borderRadius,
    this.duration = AppDurations.slow,
  });

  final Widget child;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius),
      child: child,
    );
  }
}
