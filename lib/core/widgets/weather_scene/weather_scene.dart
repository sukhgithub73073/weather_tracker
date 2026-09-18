import 'package:flutter/material.dart';

import '../../utils/weather_condition.dart';
import 'scene_particles.dart';
import 'weather_scene_painter.dart';

/// Ambient animation that reflects the current weather – rotating sun rays,
/// drifting clouds, falling rain or snow, lightning, twinkling stars, mist.
///
/// Place it in a [Stack] behind content (e.g. the home header). One looping
/// controller drives every layer; all motion is periodic over [cycle] so the
/// loop never jumps.
class WeatherScene extends StatefulWidget {
  const WeatherScene({
    super.key,
    required this.condition,
    this.cycle = const Duration(seconds: 20),
    this.animate = true,
  });

  final WeatherCondition condition;
  final Duration cycle;

  /// Set false to freeze the scene (e.g. reduced-motion accessibility).
  final bool animate;

  @override
  State<WeatherScene> createState() => _WeatherSceneState();
}

class _WeatherSceneState extends State<WeatherScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.cycle,
  );
  final SceneParticles _particles = SceneParticles(seed: 7);

  @override
  void initState() {
    super.initState();
    _syncPlayback();
  }

  @override
  void didUpdateWidget(WeatherScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _syncPlayback();
  }

  void _syncPlayback() {
    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _controller.isAnimating) _controller.stop();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: WeatherScenePainter(
            condition: widget.condition,
            progress: _controller.value,
            particles: _particles,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
