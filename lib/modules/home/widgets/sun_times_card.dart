import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/weather_math.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/home_controller.dart';

/// Sunrise / sunset with the sun's current position on its daily arc.
class SunTimesCard extends StatelessWidget {
  const SunTimesCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.weather.value!.current;
      final now = controller.nowUtc;
      final progress = WeatherMath.sunProgress(now, current.sunrise, current.sunset);
      final daylight = current.sunset.difference(current.sunrise);
      final textTheme = context.textStyles;

      return SectionCard(
        title: 'Sun',
        icon: Icons.wb_twilight_rounded,
        accent: AppColors.sunDeep,
        trailing: Text(
          'Daylight ${daylight.inHours}h ${daylight.inMinutes.remainder(60)}m',
          style: textTheme.labelMedium?.copyWith(color: context.appColors.textSecondary),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 96,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SunArcPainter(
                  progress: progress,
                  trackColor: context.appColors.cardBorder,
                  isDark: context.isDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _SunTime(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Sunrise',
                  value: controller.time(current.sunrise),
                  alignment: CrossAxisAlignment.start,
                ),
                const Spacer(),
                _SunTime(
                  icon: Icons.nightlight_outlined,
                  label: 'Sunset',
                  value: controller.time(current.sunset),
                  alignment: CrossAxisAlignment.end,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({
    required this.icon,
    required this.label,
    required this.value,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.sun),
            const SizedBox(width: 4),
            Text(label, style: textTheme.labelMedium?.copyWith(color: context.appColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: textTheme.titleMedium),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({
    required this.progress,
    required this.trackColor,
    required this.isDark,
  });

  /// 0..1 during the day, null at night.
  final double? progress;
  final Color trackColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(12, 12, size.width - 24, (size.height - 12) * 2);
    const start = math.pi;
    const sweep = math.pi;

    // Horizon line
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      Paint()
        ..color = trackColor
        ..strokeWidth = 1,
    );

    // Dashed track
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const dashCount = 28;
    for (var i = 0; i < dashCount; i += 2) {
      canvas.drawArc(rect, start + sweep * i / dashCount, sweep / dashCount, false, track);
    }

    final p = progress;
    if (p == null) return;

    // Travelled part
    canvas.drawArc(
      rect,
      start,
      sweep * p,
      false,
      Paint()
        ..shader = const LinearGradient(colors: [AppColors.sunDeep, AppColors.sunLight])
            .createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Sun marker
    final angle = start + sweep * p;
    final center = rect.center + Offset(math.cos(angle) * rect.width / 2, math.sin(angle) * rect.height / 2);
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.sunLight.withValues(alpha: 0.55), AppColors.sunLight.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: 16)),
    );
    canvas.drawCircle(center, 7, Paint()..color = AppColors.sun);
    canvas.drawCircle(center, 7, Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.5 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
