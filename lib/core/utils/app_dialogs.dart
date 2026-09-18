import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';

/// Confirmation dialogs callable from controllers.
class AppDialogs {
  AppDialogs._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData? icon,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        icon: icon == null
            ? null
            : Icon(icon, color: destructive ? AppColors.error : Get.theme.colorScheme.primary),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(cancelLabel)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error, minimumSize: Size.zero)
                : FilledButton.styleFrom(minimumSize: Size.zero),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
