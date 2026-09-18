import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// Shown when start-up fails before the real app can be built.
///
/// Turns a silent black screen into a readable diagnostic. In release builds
/// the technical details are still shown so a user can report them.
class BootErrorView extends StatelessWidget {
  const BootErrorView({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.sunLight, size: 56),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Weather Tracker could not start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Something failed during initialization. The details below '
                  'point at the cause.',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        '$error\n\n${stackTrace ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onRetry,
                      child: const Text('Try again'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
