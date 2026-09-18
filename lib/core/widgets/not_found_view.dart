import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_dimens.dart';
import '../utils/context_extensions.dart';

/// Shown for unknown named routes.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_off_rounded, size: 72, color: context.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text('Page not found', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The screen you were looking for does not exist.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Get.offAllNamed(Routes.home),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
