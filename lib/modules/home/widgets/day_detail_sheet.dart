import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/weather_math.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../data/models/daily_forecast.dart';
import '../controllers/home_controller.dart';
import 'weather_details_grid.dart';

/// Bottom sheet with everything known about one forecast day.
class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.day,
    required this.controller,
    this.scrollController,
  });

  final DailyForecast day;
  final HomeController controller;
  final ScrollController? scrollController;

  static Future<void> show(
    BuildContext context, {
    required DailyForecast day,
    required HomeController controller,
  }) {
    return AppBottomSheet.show<void>(
      context,
      initialSize: 0.72,
      builder: (_, scrollController) => DayDetailSheet(
        day: day,
        controller: controller,
        scrollController: scrollController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    final secondary = context.appColors.textSecondary;
    final columns = context.isWideScreen ? 3 : 2;

    final tiles = <Widget>[
      DetailTile(
        icon: Icons.umbrella_outlined,
        label: 'Chance of rain',
        value: '${day.precipitationPercent}%',
        subtitle: day.rainVolume != null ? '${day.rainVolume!.toStringAsFixed(1)} mm expected' : null,
        accent: AppColors.primary,
      ),
      DetailTile(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${day.humidity}%',
        accent: AppColors.rain,
      ),
      DetailTile(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: controller.wind(day.windSpeed),
        subtitle: 'From ${controller.windDirection(day.windDegrees)}',
        accent: AppColors.info,
      ),
      DetailTile(
        icon: Icons.wb_sunny_outlined,
        label: 'UV index',
        value: day.uvIndex == null ? '—' : day.uvIndex!.toStringAsFixed(1),
        subtitle: WeatherMath.uvLabel(day.uvIndex),
        accent: AppColors.sun,
      ),
      if (day.cloudiness != null)
        DetailTile(
          icon: Icons.cloud_outlined,
          label: 'Cloud cover',
          value: '${day.cloudiness}%',
          accent: const Color(0xFF90A4AE),
        ),
      if (day.pressure != null)
        DetailTile(
          icon: Icons.speed_rounded,
          label: 'Pressure',
          value: controller.pressure(day.pressure!),
          accent: AppColors.sunDeep,
        ),
      if (day.sunrise != null)
        DetailTile(
          icon: Icons.wb_twilight_rounded,
          label: 'Sunrise',
          value: controller.time(day.sunrise!),
          accent: AppColors.sunLight,
        ),
      if (day.sunset != null)
        DetailTile(
          icon: Icons.nightlight_outlined,
          label: 'Sunset',
          value: controller.time(day.sunset!),
          accent: AppColors.primaryLight,
        ),
      if (day.snowVolume != null)
        DetailTile(
          icon: Icons.ac_unit_rounded,
          label: 'Snow',
          value: '${day.snowVolume!.toStringAsFixed(1)} mm',
          accent: AppColors.skyLight,
        ),
    ];

    return ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xl),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.dayName(day.date, full: true), style: textTheme.headlineSmall),
                    Text(
                      controller.fullDate(day.date),
                      style: textTheme.bodyMedium?.copyWith(color: secondary),
                    ),
                  ],
                ),
              ),
              WeatherIcon(condition: day.condition, size: 56),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(day.summary ?? day.capitalizedDescription, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _TempStat(label: 'High', value: controller.temp(day.tempMax), color: AppColors.sunDeep),
              _TempStat(label: 'Low', value: controller.temp(day.tempMin), color: AppColors.rain),
              if (day.tempDay != null)
                _TempStat(label: 'Day', value: controller.temp(day.tempDay!), color: AppColors.sun),
              if (day.tempNight != null)
                _TempStat(label: 'Night', value: controller.temp(day.tempNight!), color: AppColors.primaryLight),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm + 2,
            crossAxisSpacing: AppSpacing.sm + 2,
            childAspectRatio: 1.55,
            children: tiles,
          ),
        ],
    );
  }
}

class _TempStat extends StatelessWidget {
  const _TempStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
