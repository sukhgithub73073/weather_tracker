import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_state_view.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_error.dart';

/// Maps a [HomeError] to the right copy and actions.
class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error == null) return const SizedBox.shrink();

      String? primaryLabel;
      VoidCallback? onPrimary;
      if (error.needsAppSettings) {
        primaryLabel = 'Open settings';
        onPrimary = controller.openAppSettings;
      } else if (error.needsLocationSettings) {
        primaryLabel = 'Turn on location';
        onPrimary = controller.openLocationSettings;
      } else if (error.needsPermissionRequest) {
        primaryLabel = 'Allow location';
        onPrimary = () => controller.useCurrentLocation();
      } else if (error.canRetry) {
        primaryLabel = 'Try again';
        onPrimary = () => controller.refresh();
      }

      return SafeArea(
        child: ErrorStateView(
          icon: error.icon,
          title: error.title,
          message: error.message,
          iconColor: error.kind == HomeErrorKind.noInternet ? AppColors.textSecondaryLight : null,
          primaryLabel: primaryLabel,
          onPrimary: onPrimary,
          secondaryLabel: error.kind == HomeErrorKind.missingApiKey ? null : 'Search for a city',
          onSecondary: error.kind == HomeErrorKind.missingApiKey
              ? null
              : () => controller.openRoute(Routes.search),
        ),
      );
    });
  }
}
