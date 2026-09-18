import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/gradient_button.dart';
import '../controllers/home_controller.dart';

/// Floating bar that straddles the bottom edge of the weather header:
/// a search pill plus favourites and settings shortcuts.
class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key, required this.controller});

  final HomeController controller;

  static const double height = 64;

  /// How far the bar hangs below the header.
  static const double overlap = height / 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: AppGradients.card(context.brightness),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColors.cardBorder),
        boxShadow: AppGradients.floatingShadow(context.brightness),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.mdRadius,
                onTap: () => controller.openRoute(Routes.search),
                child: Row(
                  children: [
                    const GradientIconBadge(
                      icon: Icons.search_rounded,
                      color: Color(0xFF1E88E5),
                      size: 40,
                      iconSize: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        'Search for a city…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.appColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: context.appColors.divider,
          ),
          GradientIconButton(
            icon: Icons.favorite_rounded,
            gradient: AppGradients.favorite,
            size: 40,
            iconSize: 20,
            tooltip: 'Favorite locations',
            onPressed: () => controller.openRoute(Routes.favorites),
          ),
          const SizedBox(width: AppSpacing.sm),
          GradientIconButton(
            icon: Icons.settings_rounded,
            gradient: AppGradients.settings,
            size: 40,
            iconSize: 20,
            tooltip: 'Settings',
            onPressed: () => controller.openRoute(Routes.settings),
          ),
        ],
      ),
    );
  }
}
