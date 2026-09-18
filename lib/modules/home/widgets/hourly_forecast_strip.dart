import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../data/models/hourly_forecast.dart';
import '../controllers/home_controller.dart';

/// Horizontally scrolling next-24-hours forecast with the current hour
/// highlighted.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bundle = controller.weather.value!;
      final hours = bundle.next24Hours;
      if (hours.isEmpty) return const SizedBox.shrink();
      final now = controller.nowUtc;

      // The entry covering the current hour (or the first upcoming one).
      var currentIndex = hours.indexWhere((h) => !h.time.isBefore(now));
      if (currentIndex > 0 && hours[currentIndex].time.difference(now).inMinutes > 30) {
        currentIndex -= 1;
      }
      if (currentIndex < 0) currentIndex = 0;

      return SectionCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SectionHeader(
                title: bundle.hasFullForecast ? 'Hourly forecast' : 'Forecast · 3-hour steps',
                icon: Icons.schedule_rounded,
                accent: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            physics: const BouncingScrollPhysics(),
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) => _HourTile(
              hour: hours[index],
              isCurrent: index == currentIndex,
              label: index == currentIndex ? 'Now' : controller.hour(hours[index].time),
              temperature: controller.temp(hours[index].temperature),
            ),
          ),
        ),
          ],
        ),
      );
    });
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({
    required this.hour,
    required this.isCurrent,
    required this.label,
    required this.temperature,
  });

  final HourlyForecast hour;
  final bool isCurrent;
  final String label;
  final String temperature;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textStyles;
    final foreground = isCurrent ? scheme.onPrimary : scheme.onSurface;
    final secondary = isCurrent
        ? scheme.onPrimary.withValues(alpha: 0.85)
        : context.appColors.textSecondary;

    return AnimatedContainer(
      duration: AppDurations.normal,
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: isCurrent
            ? AppGradients.primary
            : AppGradients.tint(scheme.primary, context.brightness, strength: 0.5),
        border: isCurrent ? null : Border.all(color: scheme.primary.withValues(alpha: 0.12)),
        borderRadius: AppRadius.mdRadius,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: secondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          WeatherIcon(
            condition: hour.condition,
            size: 30,
            monochrome: isCurrent ? foreground : null,
          ),
          Text(
            temperature,
            style: textTheme.titleMedium?.copyWith(color: foreground),
          ),
          SizedBox(
            height: 16,
            child: hour.precipitationPercent > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 11,
                        color: isCurrent ? foreground : AppColors.rain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${hour.precipitationPercent}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: isCurrent ? foreground : AppColors.rain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
