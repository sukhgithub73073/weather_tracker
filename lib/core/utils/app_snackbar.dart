import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// Consistent floating snackbars, usable from controllers (no BuildContext).
class AppSnackbar {
  AppSnackbar._();

  static void show(
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    final isDark = Get.isDarkMode;
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
                onAction();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.sunLight,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: Text(actionLabel),
            ),
        ],
      ),
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.darkSurfaceElevated : AppColors.textPrimaryLight),
      borderRadius: AppRadius.md,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      duration: duration,
      animationDuration: AppDurations.normal,
    );
  }

  static void error(String message, {String? actionLabel, VoidCallback? onAction}) => show(
        message,
        icon: Icons.error_outline_rounded,
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        actionLabel: actionLabel,
        onAction: onAction,
      );

  static void success(String message) =>
      show(message, icon: Icons.check_circle_outline_rounded, backgroundColor: AppColors.success);

  static void offline(String message) =>
      show(message, icon: Icons.cloud_off_rounded, backgroundColor: const Color(0xFF546E7A));
}
