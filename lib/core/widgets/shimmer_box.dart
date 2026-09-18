import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_dimens.dart';
import '../utils/context_extensions.dart';

/// Placeholder block used to build loading skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.smRadius,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Wraps skeleton content in the app's shimmer colors.
class ShimmerArea extends StatelessWidget {
  const ShimmerArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.shimmerBase,
      highlightColor: context.appColors.shimmerHighlight,
      child: child,
    );
  }
}
