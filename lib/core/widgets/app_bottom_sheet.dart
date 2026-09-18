import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';
import '../utils/context_extensions.dart';

/// Draggable modal sheet with the app's gradient surface and drag handle.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext context, ScrollController scrollController) builder,
    double initialSize = 0.7,
    double minSize = 0.4,
    double maxSize = 0.95,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: AppGradients.card(context.brightness),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(child: builder(context, scrollController)),
            ],
          ),
        ),
      ),
    );
  }
}
