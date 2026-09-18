import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/weather_location.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/favorite_location_card.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.scaffold(context.brightness)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Saved locations'),
          actions: [
            Obx(() {
              final city = controller.savableCurrentCity;
              if (city == null) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: controller.saveCurrentCity,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: Text('Save ${city.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            }),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openSearch,
          backgroundColor: Colors.transparent,
          elevation: 0,
          extendedPadding: EdgeInsets.zero,
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppGradients.search,
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppGradients.floatingShadow(context.brightness),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Add city',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        body: Obx(() {
          final favorites = controller.favorites;
          final isCurrentSelected = controller.isShowingCurrentLocation;
          final selected = controller.selectedLocation;

          final header = Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
            child: FavoriteLocationCard(
              title: controller.currentLocationWeather?.location.name ?? 'Current location',
              subtitle: controller.currentLocationWeather?.location.subtitle ?? 'Use device GPS',
              leadingIcon: Icons.my_location_rounded,
              summary: controller.currentLocationWeather,
              isSelected: isCurrentSelected,
              onTap: controller.useCurrentLocation,
              formatTemp: controller.temp,
            ).animate().fadeIn(duration: 300.ms),
          );

          if (favorites.isEmpty) {
            return Column(
              children: [
                header,
                Expanded(
                  child: ErrorStateView(
                    icon: Icons.favorite_border_rounded,
                    iconColor: const Color(0xFFFF5F8F),
                    title: 'No saved locations yet',
                    message:
                        'Save cities you care about to switch between them instantly. You can keep up to ${AppConstants.maxFavorites}.',
                    primaryLabel: controller.savableCurrentCity == null ? null : 'Save current city',
                    onPrimary: controller.savableCurrentCity == null ? null : controller.saveCurrentCity,
                    secondaryLabel: 'Search for a city',
                    onSecondary: controller.openSearch,
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ReorderableListView.builder(
              header: header,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 120),
              buildDefaultDragHandles: false,
              onReorder: controller.reorder,
              proxyDecorator: (child, index, animation) => AnimatedBuilder(
                animation: animation,
                builder: (context, _) => Transform.scale(
                  scale: 1 + 0.03 * Curves.easeInOut.transform(animation.value),
                  child: child,
                ),
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final location = favorites[index];
                return _FavoriteRow(
                  key: ValueKey(location.id),
                  index: index,
                  location: location,
                  isSelected: selected?.id == location.id,
                  controller: controller,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({
    super.key,
    required this.index,
    required this.location,
    required this.isSelected,
    required this.controller,
  });

  final int index;
  final WeatherLocation location;
  final bool isSelected;
  final FavoritesController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: ValueKey('dismiss-${location.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.remove(location),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppGradients.badge(AppColors.error),
            borderRadius: AppRadius.lgRadius,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
        ),
        child: Obx(() {
          final summary = controller.summaries[location.id];
          final isLoading = controller.loadingIds.contains(location.id);
          return FavoriteLocationCard(
            title: location.name,
            subtitle: location.subtitle,
            summary: summary,
            isLoading: isLoading,
            isSelected: isSelected,
            onTap: () => controller.select(location),
            formatTemp: controller.temp,
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: 'Hold to reorder',
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate(delay: (40 * index).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
