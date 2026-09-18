import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../data/models/daily_forecast.dart';
import '../controllers/home_controller.dart';
import 'day_detail_sheet.dart';

/// Multi-day outlook. Each row shows a temperature range bar positioned
/// against the week's overall min/max so the days compare at a glance.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bundle = controller.weather.value!;
      final days = bundle.daily;
      if (days.isEmpty) return const SizedBox.shrink();

      final weekMin = days.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
      final weekMax = days.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);

      return SectionCard(
        title: '${days.length}-day forecast',
        icon: Icons.calendar_month_rounded,
        accent: const Color(0xFF7E57C2),
        trailing: bundle.hasFullForecast
            ? null
            : Tooltip(
                message: 'Free API tier provides 5 days. Enable One Call for 7.',
                child: Icon(Icons.info_outline_rounded, size: 16, color: context.appColors.textSecondary),
              ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
        child: Column(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              _DayRow(
                day: days[i],
                controller: controller,
                weekMin: weekMin,
                weekMax: weekMax,
                onTap: () => DayDetailSheet.show(context, day: days[i], controller: controller),
              ),
              if (i < days.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      );
    });
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.controller,
    required this.weekMin,
    required this.weekMax,
    required this.onTap,
  });

  final DailyForecast day;
  final HomeController controller;
  final double weekMin;
  final double weekMax;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    final secondary = context.appColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.dayName(day.date), style: textTheme.titleSmall),
                  Text(
                    controller.shortDate(day.date),
                    style: textTheme.bodySmall?.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            WeatherIcon(condition: day.condition, size: 30),
            SizedBox(
              width: 46,
              child: day.precipitationPercent > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop_rounded, size: 11, color: AppColors.rain),
                        const SizedBox(width: 2),
                        Text(
                          '${day.precipitationPercent}%',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.rain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            SizedBox(
              width: 34,
              child: Text(
                controller.temp(day.tempMin),
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(color: secondary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TemperatureRangeBar(
                min: day.tempMin,
                max: day.tempMax,
                rangeMin: weekMin,
                rangeMax: weekMax,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 34,
              child: Text(
                controller.temp(day.tempMax),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: secondary),
          ],
        ),
      ),
    );
  }
}

/// Horizontal bar showing where a day's [min]–[max] sits within the
/// [rangeMin]–[rangeMax] of the whole forecast.
class TemperatureRangeBar extends StatelessWidget {
  const TemperatureRangeBar({
    super.key,
    required this.min,
    required this.max,
    required this.rangeMin,
    required this.rangeMax,
    this.height = 6,
  });

  final double min;
  final double max;
  final double rangeMin;
  final double rangeMax;
  final double height;

  @override
  Widget build(BuildContext context) {
    final span = (rangeMax - rangeMin).abs() < 0.01 ? 1.0 : rangeMax - rangeMin;
    final start = ((min - rangeMin) / span).clamp(0.0, 1.0).toDouble();
    final end = ((max - rangeMin) / span).clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final left = width * start;
        final barWidth = (width * (end - start)).clamp(height, width).toDouble();
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.appColors.cardBorder,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
              Positioned(
                left: left.clamp(0.0, width - barWidth).toDouble(),
                width: barWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(AppColors.rain, AppColors.sun, start)!,
                        Color.lerp(AppColors.rain, AppColors.sunDeep, end)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
