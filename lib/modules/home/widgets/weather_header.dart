import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/weather_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../core/widgets/weather_scene/weather_scene.dart';
import '../controllers/home_controller.dart';

/// Hero section: condition gradient + animated scene + today's headline
/// numbers. Everything inside reacts to the controller through Obx.
class WeatherHeader extends StatelessWidget {
  const WeatherHeader({super.key, required this.controller, this.bottomInset = 0});

  final HomeController controller;

  /// Extra space at the bottom so an overlapping widget (the quick-actions
  /// bar) never covers the content.
  final double bottomInset;

  static const Color _onGradient = Colors.white;
  static const List<Shadow> _textShadow = [
    Shadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Obx(() {
      final bundle = controller.weather.value;
      if (bundle == null) return const SizedBox.shrink();
      final current = bundle.current;
      final condition = current.condition;
      final gradient = WeatherGradients.forCondition(
        condition,
        brightness: context.themeData.brightness,
      );

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
        child: AnimatedContainer(
          duration: AppDurations.slow,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  child: WeatherScene(
                    key: ValueKey(condition),
                    condition: condition,
                  ),
                ),
              ),
              // Legibility overlay for light gradients (snow, mist).
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.22),
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  topPadding + AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.lg + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(controller: controller),
                    const SizedBox(height: AppSpacing.lg),
                    _DateLine(controller: controller),
                    const SizedBox(height: AppSpacing.sm),
                    _Headline(controller: controller),
                    const SizedBox(height: AppSpacing.md),
                    _SummaryChips(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final location = controller.weather.value!.location;
      return _LocationPill(controller: controller, isCurrent: location.isCurrentLocation);
    });
  }
}

/// Frosted pill showing the city; taps open the saved-locations list.
class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.controller, required this.isCurrent});

  final HomeController controller;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    final location = controller.weather.value!.location;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => controller.openRoute(Routes.favorites),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCurrent ? Icons.my_location_rounded : Icons.location_on_rounded,
                  color: WeatherHeader._onGradient,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: WeatherHeader._onGradient,
                          height: 1.1,
                        ),
                      ),
                      if (location.subtitle.isNotEmpty)
                        Text(
                          location.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: WeatherHeader._onGradient.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.expand_more_rounded,
                  color: WeatherHeader._onGradient.withValues(alpha: 0.9),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bundle = controller.weather.value!;
      final style = context.textStyles.bodyMedium?.copyWith(
        color: WeatherHeader._onGradient.withValues(alpha: 0.9),
        shadows: WeatherHeader._textShadow,
      );
      return Row(
        children: [
          Flexible(
            child: Text(
              controller.fullDate(controller.nowUtc),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: WeatherHeader._onGradient.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (controller.isRefreshing.value)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WeatherHeader._onGradient.withValues(alpha: 0.9),
              ),
            )
          else
            Text('Updated ${controller.lastUpdatedLabel}', style: style),
          if (bundle.isFromCache && !controller.isRefreshing.value) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.offline_pin_rounded,
              size: 14,
              color: WeatherHeader._onGradient.withValues(alpha: 0.8),
            ),
          ],
        ],
      );
    });
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    return Obx(() {
      final current = controller.weather.value!.current;
      final tempText = controller.temp(current.temperature);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tempText,
                  key: ValueKey(tempText),
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 96,
                    height: 1,
                    color: WeatherHeader._onGradient,
                    shadows: WeatherHeader._textShadow,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  current.capitalizedDescription,
                  style: textTheme.titleLarge?.copyWith(
                    color: WeatherHeader._onGradient,
                    fontWeight: FontWeight.w500,
                    shadows: WeatherHeader._textShadow,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: WeatherIcon(condition: current.condition, size: 72)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: GetNumUtils(2).seconds, curve: Curves.easeInOut),
          ),
        ],
      );
    });
  }
}

class _SummaryChips extends StatelessWidget {
  const _SummaryChips({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.weather.value!.current;
      final chips = <(IconData, String)>[
        (Icons.thermostat_rounded, 'Feels like ${controller.temp(current.feelsLike)}'),
        (
          Icons.swap_vert_rounded,
          'H ${controller.temp(current.tempMax)}  L ${controller.temp(current.tempMin)}',
        ),
        if (current.precipitationProbability != null)
          (
            Icons.umbrella_rounded,
            '${(current.precipitationProbability! * 100).round()}% rain',
          ),
      ];
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final (icon, label) in chips)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: WeatherHeader._onGradient),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: WeatherHeader._onGradient,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
