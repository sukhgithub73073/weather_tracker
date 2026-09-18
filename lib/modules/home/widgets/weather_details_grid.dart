import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/weather_math.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/home_controller.dart';

/// Today's conditions in a responsive 2/3-column grid of metric tiles.
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final columns = context.isWideScreen ? 3 : 2;

    return Obx(() {
      final bundle = controller.weather.value!;
      final current = bundle.current;
      final pop = current.precipitationProbability;
      final uv = current.uvIndex;

      final tiles = <Widget>[
        DetailTile(
          icon: Icons.water_drop_outlined,
          label: 'Humidity',
          value: '${current.humidity}%',
          subtitle: _humidityLabel(current.humidity),
          accent: AppColors.rain,
        ),
        DetailTile(
          icon: Icons.air_rounded,
          label: 'Wind',
          value: controller.wind(current.windSpeed),
          subtitle: current.windGust != null
              ? 'Gusts ${controller.wind(current.windGust!)}'
              : 'From ${controller.windDirection(current.windDegrees)}',
          accent: AppColors.info,
          trailing: _WindCompass(degrees: current.windDegrees),
        ),
        DetailTile(
          icon: Icons.visibility_outlined,
          label: 'Visibility',
          value: controller.visibility(current.visibility),
          subtitle: _visibilityLabel(current.visibility),
          accent: AppColors.primaryLight,
        ),
        DetailTile(
          icon: Icons.speed_rounded,
          label: 'Pressure',
          value: controller.pressure(current.pressure),
          subtitle: _pressureLabel(current.pressure),
          accent: AppColors.sunDeep,
        ),
        DetailTile(
          icon: Icons.wb_sunny_outlined,
          label: 'UV index',
          value: uv == null ? '—' : uv.toStringAsFixed(uv >= 10 ? 0 : 1),
          subtitle: uv == null ? 'Needs One Call API' : WeatherMath.uvLabel(uv),
          accent: AppColors.sun,
        ),
        DetailTile(
          icon: Icons.umbrella_outlined,
          label: 'Chance of rain',
          value: pop == null ? '—' : '${(pop * 100).round()}%',
          subtitle: pop == null
              ? 'Unavailable'
              : pop >= 0.6
                  ? 'Bring an umbrella'
                  : pop >= 0.3
                      ? 'Possible showers'
                      : 'Unlikely',
          accent: AppColors.primary,
        ),
        DetailTile(
          icon: Icons.cloud_outlined,
          label: 'Cloud cover',
          value: '${current.cloudiness}%',
          subtitle: _cloudLabel(current.cloudiness),
          accent: const Color(0xFF90A4AE),
        ),
        DetailTile(
          icon: Icons.opacity_rounded,
          label: 'Dew point',
          value: current.dewPoint == null ? '—' : controller.tempWithUnit(current.dewPoint!),
          subtitle: current.dewPoint == null ? '' : _dewLabel(current.dewPoint!),
          accent: const Color(0xFF26C6DA),
        ),
      ];

      return SectionCard(
        title: 'Details',
        icon: Icons.grid_view_rounded,
        accent: AppColors.info,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm + 2,
          crossAxisSpacing: AppSpacing.sm + 2,
          childAspectRatio: 1.55,
          children: tiles,
        ),
      );
    });
  }

  static String _humidityLabel(int humidity) {
    if (humidity >= 80) return 'Very humid';
    if (humidity >= 60) return 'Humid';
    if (humidity >= 30) return 'Comfortable';
    return 'Dry';
  }

  static String _visibilityLabel(int? meters) {
    if (meters == null) return '';
    if (meters >= 10000) return 'Excellent';
    if (meters >= 5000) return 'Good';
    if (meters >= 2000) return 'Moderate';
    return 'Poor';
  }

  static String _pressureLabel(double hPa) {
    if (hPa >= 1022) return 'High';
    if (hPa <= 1005) return 'Low';
    return 'Normal';
  }

  static String _cloudLabel(int cloudiness) {
    if (cloudiness >= 85) return 'Overcast';
    if (cloudiness >= 50) return 'Mostly cloudy';
    if (cloudiness >= 20) return 'Partly cloudy';
    return 'Clear';
  }

  static String _dewLabel(double dewPoint) {
    if (dewPoint >= 21) return 'Oppressive';
    if (dewPoint >= 16) return 'Muggy';
    if (dewPoint >= 10) return 'Pleasant';
    return 'Dry air';
  }
}

/// One metric card. Reused by the details screen in a later module.
class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.accent,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.colorScheme.primary;
    final textTheme = context.textStyles;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppGradients.tint(color, context.brightness),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GradientIconBadge(icon: icon, color: color, size: 22, iconSize: 12),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            subtitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WindCompass extends StatelessWidget {
  const _WindCompass({required this.degrees});

  final int degrees;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Transform.rotate(
        // Meteorological direction is where wind comes FROM; the arrow
        // points where it blows TO.
        angle: (degrees + 180) * math.pi / 180,
        child: Icon(Icons.navigation_rounded, size: 14, color: AppColors.info),
      ),
    );
  }
}
