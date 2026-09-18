import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/weather_scene/weather_scene.dart';
import '../../../core/utils/weather_condition.dart';
import '../controllers/home_controller.dart';

/// Skeleton that mirrors the dashboard layout while the first load runs.
class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
            child: GradientBackground(
              gradient: AppColors.brandGradient,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: WeatherScene(condition: WeatherCondition.partlyCloudyDay),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      topPadding + AppSpacing.md,
                      AppSpacing.page,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _WhiteBar(width: 160, height: 22),
                        const SizedBox(height: 6),
                        const _WhiteBar(width: 100, height: 14),
                        const SizedBox(height: AppSpacing.xl),
                        const _WhiteBar(width: 150, height: 84, radius: 20),
                        const SizedBox(height: AppSpacing.md),
                        const _WhiteBar(width: 200, height: 18),
                        const SizedBox(height: AppSpacing.lg),
                        Obx(
                          () => Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                controller.loadingMessage.value,
                                style: context.textStyles.bodyMedium?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: ShimmerArea(
              child: Column(
                children: [
                  const _CardSkeleton(height: 150),
                  const SizedBox(height: AppSpacing.md),
                  const _CardSkeleton(height: 260),
                  const SizedBox(height: AppSpacing.md),
                  const _CardSkeleton(height: 200),
                ].animate(interval: 80.ms).fadeIn(duration: 300.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteBar extends StatelessWidget {
  const _WhiteBar({required this.width, required this.height, this.radius = 8});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: 0.6, end: 1, duration: 900.ms);
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: double.infinity, height: height, borderRadius: AppRadius.card);
  }
}
