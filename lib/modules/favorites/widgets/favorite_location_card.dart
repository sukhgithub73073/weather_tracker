import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../app/theme/weather_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../data/models/weather_bundle.dart';

/// Gradient card summarising one location's weather.
class FavoriteLocationCard extends StatelessWidget {
  const FavoriteLocationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.summary,
    this.isLoading = false,
    this.isSelected = false,
    this.leadingIcon,
    this.dragHandle,
    required this.formatTemp,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final WeatherBundle? summary;
  final bool isLoading;
  final bool isSelected;
  final IconData? leadingIcon;
  final Widget? dragHandle;
  final String Function(double celsius) formatTemp;

  static const List<Shadow> _shadow = [
    Shadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    final current = summary?.current;
    final gradient = current == null
        ? AppGradients.primary
        : WeatherGradients.forCondition(current.condition, brightness: context.brightness);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadius.lgRadius,
          border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (leadingIcon != null) ...[
                            Icon(leadingIcon, size: 18, color: Colors.white, shadows: _shadow),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(color: Colors.white, shadows: _shadow),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                          ],
                        ],
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            shadows: _shadow,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      if (current != null)
                        Text(
                          current.capitalizedDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white, shadows: _shadow),
                        )
                      else
                        Text(
                          isLoading ? 'Loading forecast…' : 'Tap to view weather',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (current != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WeatherIcon(condition: current.condition, size: 34),
                          const SizedBox(width: 6),
                          Text(
                            formatTemp(current.temperature),
                            style: textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 40,
                              height: 1,
                              shadows: _shadow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'H ${formatTemp(current.tempMax)}  L ${formatTemp(current.tempMin)}',
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: _shadow,
                        ),
                      ),
                    ],
                  )
                else if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                if (dragHandle != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  dragHandle!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
