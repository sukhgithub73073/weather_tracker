import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/asset_paths.dart';

/// The Weather Tracker logo.
///
/// Renders `assets/images/logo.png`; if the asset is missing it draws a
/// branded fallback so the splash screen never shows a broken image.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120, this.borderRadius});

  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          AssetPaths.logo,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.16,
            left: size * 0.2,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: size * 0.42,
              color: AppColors.sunLight,
            ),
          ),
          Positioned(
            bottom: size * 0.16,
            right: size * 0.16,
            child: Icon(
              Icons.cloud_rounded,
              size: size * 0.52,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
