import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/gradient_background.dart';
import '../controllers/splash_controller.dart';
import '../widgets/floating_orbs.dart';
import '../widgets/pulsing_dots.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize =
        (MediaQuery.sizeOf(context).shortestSide * 0.38).clamp(120.0, 200.0).toDouble();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientBackground(
          gradient: AppColors.splashGradient,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const FloatingOrbs(),
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    _AnimatedLogo(size: logoSize),
                    const SizedBox(height: AppSpacing.xl),
                    const _BrandTitle(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.tagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.4,
                          ),
                    ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
                    const Spacer(flex: 4),
                    _LoadingSection(controller: controller),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: AppColors.skyLight.withValues(alpha: 0.35),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: AppLogo(size: size, borderRadius: radius),
    )
        // Entrance: pop in with a slight overshoot, then a single light sweep.
        .animate()
        .scale(
          begin: const Offset(0.45, 0.45),
          end: const Offset(1, 1),
          duration: 900.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 600.ms)
        .then(delay: 150.ms)
        .shimmer(duration: 1100.ms, color: Colors.white.withValues(alpha: 0.4))
        // Idle: gentle float that loops while the bootstrap finishes.
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -8, duration: 2200.ms, curve: Curves.easeInOut);
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'Weather',
          style: textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        )
            .animate(delay: 350.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.4, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tracker',
          style: textTheme.headlineMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w300,
            letterSpacing: 6,
            height: 1,
          ),
        )
            .animate(delay: 500.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.4, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
      ],
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const PulsingDots(),
        const SizedBox(height: AppSpacing.md),
        Obx(
          () => AnimatedSwitcher(
            duration: AppDurations.normal,
            child: Text(
              controller.statusMessage.value,
              key: ValueKey(controller.statusMessage.value),
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(
          () => Text(
            controller.appVersion.value,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    ).animate(delay: 1000.ms).fadeIn(duration: 500.ms);
  }
}
