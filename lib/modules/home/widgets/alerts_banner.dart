import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/weather_alert.dart';
import '../controllers/home_controller.dart';

/// Colour-coded card for the most severe active alert; tapping lists all.
class AlertsBanner extends StatelessWidget {
  const AlertsBanner({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alerts = controller.weather.value!.activeAlerts(now: controller.nowUtc);
      if (alerts.isEmpty) return const SizedBox.shrink();

      final sorted = [...alerts]..sort((a, b) => a.severity.index.compareTo(b.severity.index));
      final top = sorted.first;
      final color = top.severity.color;
      final textTheme = context.textStyles;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: () => AlertsSheet.show(context, alerts: sorted, controller: controller),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppGradients.tint(color, context.brightness, strength: 1.4),
              borderRadius: AppRadius.card,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(gradient: AppGradients.badge(color), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        top.event,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(color: color),
                      ),
                      Text(
                        '${top.severity.label} · until ${controller.dateTime(top.end)}'
                        '${sorted.length > 1 ? ' · +${sorted.length - 1} more' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
        ),
      );
    });
  }
}

class AlertsSheet extends StatelessWidget {
  const AlertsSheet({
    super.key,
    required this.alerts,
    required this.controller,
    this.scrollController,
  });

  final List<WeatherAlert> alerts;
  final HomeController controller;
  final ScrollController? scrollController;

  static Future<void> show(
    BuildContext context, {
    required List<WeatherAlert> alerts,
    required HomeController controller,
  }) =>
      AppBottomSheet.show<void>(
        context,
        builder: (_, scrollController) => AlertsSheet(
          alerts: alerts,
          controller: controller,
          scrollController: scrollController,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xl),
        itemCount: alerts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text('Weather alerts', style: textTheme.headlineSmall);
          }
          final alert = alerts[index - 1];
          final color = alert.severity.color;
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppGradients.tint(color, context.brightness),
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppGradients.badge(color),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        alert.severity.label.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        alert.senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(alert.event, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${controller.dateTime(alert.start)} → ${controller.dateTime(alert.end)}',
                  style: textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(alert.description, style: textTheme.bodyMedium?.copyWith(height: 1.45)),
              ],
            ),
          );
        },
    );
  }
}
