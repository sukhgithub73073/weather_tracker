import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Three dots that pulse in sequence – a lighter loader than a spinner.
class PulsingDots extends StatelessWidget {
  const PulsingDots({super.key, this.color = Colors.white, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.45),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          )
              .animate(
                delay: (index * 180).ms,
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scaleXY(begin: 0.55, end: 1.0, duration: 520.ms, curve: Curves.easeInOut)
              .fade(begin: 0.35, end: 1.0),
        );
      }),
    );
  }
}
