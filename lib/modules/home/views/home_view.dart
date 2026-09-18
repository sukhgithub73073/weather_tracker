import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/status_banner.dart';
import '../controllers/home_controller.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/alerts_banner.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_loading_view.dart';
import '../widgets/hourly_forecast_strip.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/sun_times_card.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_header.dart';

/// Home dashboard: today's weather with condition-driven visuals.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The header gradient is always dark enough for white status icons.
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.scaffold(context.brightness)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() {
          return AnimatedSwitcher(
            duration: AppDurations.slow,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: switch (controller.status.value) {
              HomeStatus.loading => HomeLoadingView(
                  key: const ValueKey('loading'),
                  controller: controller,
                ),
              HomeStatus.error => HomeErrorView(
                  key: const ValueKey('error'),
                  controller: controller,
                ),
              HomeStatus.loaded => _DashboardBody(
                  key: const ValueKey('loaded'),
                  controller: controller,
                ),
            },
          );
        }),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    // Conditional sections (banner, alerts, AQI) add their own bottom gap
    // only when visible, so hidden ones never leave empty space.
    final sections = <Widget>[
      _FallbackLocationBanner(controller: controller),
      _CachedBanner(controller: controller),
      AlertsBanner(controller: controller),
      _Section(child: HourlyForecastStrip(controller: controller)),
      _Section(child: WeatherDetailsGrid(controller: controller)),
      _Section(child: SunTimesCard(controller: controller)),
      AirQualityCard(controller: controller),
      _Section(child: DailyForecastList(controller: controller)),
    ];

    return RefreshIndicator(
      onRefresh: controller.refresh,
      edgeOffset: MediaQuery.paddingOf(context).top + AppSpacing.md,
      color: context.colorScheme.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            // The bar hangs half below the header; the padding reserves that
            // space inside the Stack so the bar stays tappable.
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: QuickActionsBar.overlap),
                  child: WeatherHeader(
                    controller: controller,
                    bottomInset: QuickActionsBar.overlap + AppSpacing.xs,
                  ),
                ),
                Positioned(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  bottom: 0,
                  child: QuickActionsBar(controller: controller),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            sliver: SliverList.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) => sections[index]
                  .animate(delay: (60 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: child);
}

/// Explains that the dashboard is showing the default city because the
/// device position was unavailable, with a one-tap way to retry.
class _FallbackLocationBanner extends StatelessWidget {
  const _FallbackLocationBanner({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.usingFallbackLocation.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: StatusBanner(
          icon: Icons.location_off_rounded,
          color: context.colorScheme.primary,
          message: 'Showing the default location · enable location access to see local weather',
          actionLabel: 'Use my location',
          onAction: () => controller.useCurrentLocation(),
        ),
      );
    });
  }
}

class _CachedBanner extends StatelessWidget {
  const _CachedBanner({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showCachedBanner) return const SizedBox.shrink();
      final offline = !controller.isOnline.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: StatusBanner(
        icon: offline ? Icons.cloud_off_rounded : Icons.history_rounded,
        message: offline
            ? "You're offline · showing data from ${controller.lastUpdatedLabel}"
            : 'Showing saved data from ${controller.lastUpdatedLabel}',
        actionLabel: offline ? null : 'Refresh',
        onAction: offline ? null : () => controller.refresh(),
        ),
      );
    });
  }
}
