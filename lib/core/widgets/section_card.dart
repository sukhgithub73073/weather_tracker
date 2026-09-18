import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_gradients.dart';
import '../utils/context_extensions.dart';
import 'gradient_button.dart';

/// Gradient card with an optional title row – the building block of every
/// dashboard section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.accent,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
  });

  final Widget child;
  final String? title;
  final IconData? icon;

  /// Colour of the header icon badge; defaults to the primary colour.
  final Color? accent;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        gradient: AppGradients.card(context.brightness),
        borderRadius: AppRadius.card,
        border: Border.all(color: context.appColors.cardBorder),
        boxShadow: AppGradients.cardShadow(context.brightness),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              SectionHeader(title: title!, icon: icon, accent: accent, trailing: trailing),
              const SizedBox(height: AppSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.accent,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          GradientIconBadge(icon: icon!, color: accent ?? context.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm + 2),
        ],
        Expanded(
          child: Text(
            title,
            style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
