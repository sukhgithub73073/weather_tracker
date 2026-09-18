import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/home_controller.dart';

/// Compact air-quality summary (hidden when the API has no data).
class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final aqi = controller.weather.value!.airQuality;
      if (aqi == null) return const SizedBox.shrink();
      final textTheme = context.textStyles;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: SectionCard(
        title: 'Air quality',
        icon: Icons.eco_outlined,
        accent: AppColors.success,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppGradients.badge(aqi.color),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: aqi.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                '${aqi.index}',
                style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aqi.label, style: textTheme.titleMedium?.copyWith(color: aqi.color)),
                  const SizedBox(height: 4),
                  _Scale(index: aqi.index),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Pollutant(label: 'PM2.5', value: aqi.pm2_5),
                _Pollutant(label: 'PM10', value: aqi.pm10),
                _Pollutant(label: 'O₃', value: aqi.ozone),
              ],
            ),
          ],
        ),
        ),
      );
    });
  }
}

class _Scale extends StatelessWidget {
  const _Scale({required this.index});

  final int index;

  static const _colors = [
    Color(0xFF2ECC71),
    Color(0xFF9CCC65),
    Color(0xFFFFA726),
    Color(0xFFF4511E),
    Color(0xFFD32F2F),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++) ...[
          Expanded(
            child: Container(
              height: i + 1 == index ? 8 : 5,
              decoration: BoxDecoration(
                color: i + 1 <= index ? _colors[i] : context.appColors.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i < 4) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _Pollutant extends StatelessWidget {
  const _Pollutant({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: context.textStyles.labelSmall?.copyWith(color: context.appColors.textSecondary),
          ),
          TextSpan(
            text: value.toStringAsFixed(value >= 100 ? 0 : 1),
            style: context.textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
