import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Soft translucent circles that drift slowly – gives the splash gradient
/// depth without competing with the logo.
class FloatingOrbs extends StatelessWidget {
  const FloatingOrbs({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: Stack(
        children: [
          _Orb(
            left: -size.width * 0.25,
            top: -size.width * 0.15,
            diameter: size.width * 0.8,
            opacity: 0.10,
            travel: 26,
            duration: 6.seconds,
          ),
          _Orb(
            right: -size.width * 0.3,
            top: size.height * 0.28,
            diameter: size.width * 0.7,
            opacity: 0.08,
            travel: -32,
            duration: 7.seconds,
          ),
          _Orb(
            left: size.width * 0.1,
            bottom: -size.width * 0.35,
            diameter: size.width * 0.9,
            opacity: 0.07,
            travel: 20,
            duration: 8.seconds,
          ),
          _Orb(
            right: size.width * 0.12,
            top: size.height * 0.12,
            diameter: 18,
            opacity: 0.55,
            travel: 14,
            duration: 3.seconds,
          ),
          _Orb(
            left: size.width * 0.18,
            top: size.height * 0.2,
            diameter: 10,
            opacity: 0.45,
            travel: -12,
            duration: 4.seconds,
          ),
          _Orb(
            right: size.width * 0.28,
            bottom: size.height * 0.24,
            diameter: 14,
            opacity: 0.4,
            travel: 16,
            duration: 5.seconds,
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.diameter,
    required this.opacity,
    required this.travel,
    required this.duration,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double diameter;
  final double opacity;
  final double travel;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: 0, end: travel, duration: duration, curve: Curves.easeInOut),
    );
  }
}
