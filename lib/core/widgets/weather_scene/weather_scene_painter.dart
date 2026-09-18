import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../utils/weather_condition.dart';
import 'scene_particles.dart';

/// Paints one frame of the weather scene; [progress] runs from 0 to 1 per cycle.
class WeatherScenePainter extends CustomPainter {
  WeatherScenePainter({
    required this.condition,
    required this.progress,
    required this.particles,
  });

  final WeatherCondition condition;
  final double progress;
  final SceneParticles particles;

  static const double _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition) {
      case WeatherCondition.clearDay:
        _paintSun(canvas, size, intensity: 1);
      case WeatherCondition.clearNight:
        _paintStars(canvas, size);
        _paintMoon(canvas, size);
      case WeatherCondition.partlyCloudyDay:
        _paintSun(canvas, size, intensity: 0.9);
        _paintClouds(canvas, size, count: 3, tint: _cloudLight);
      case WeatherCondition.partlyCloudyNight:
        _paintStars(canvas, size);
        _paintMoon(canvas, size);
        _paintClouds(canvas, size, count: 3, tint: _cloudNight);
      case WeatherCondition.cloudy:
        _paintClouds(canvas, size, count: 5, tint: _cloudGrey);
      case WeatherCondition.drizzle:
        _paintClouds(canvas, size, count: 4, tint: _cloudGrey);
        _paintRain(canvas, size, count: 45, speedScale: 0.8);
      case WeatherCondition.rain:
        _paintClouds(canvas, size, count: 4, tint: _cloudDark);
        _paintRain(canvas, size, count: 100, speedScale: 1);
      case WeatherCondition.thunderstorm:
        _paintClouds(canvas, size, count: 5, tint: _cloudStorm);
        _paintRain(canvas, size, count: 120, speedScale: 1.25);
        _paintLightning(canvas, size);
      case WeatherCondition.snow:
        _paintClouds(canvas, size, count: 3, tint: _cloudLight);
        _paintSnow(canvas, size);
      case WeatherCondition.mist:
        _paintSun(canvas, size, intensity: 0.35);
        _paintMist(canvas, size);
      case WeatherCondition.unknown:
        _paintSun(canvas, size, intensity: 0.6);
        _paintClouds(canvas, size, count: 2, tint: _cloudLight);
    }
  }

  // ---------------------------------------------------------------------------
  // Sun & moon
  // ---------------------------------------------------------------------------

  void _paintSun(Canvas canvas, Size size, {required double intensity}) {
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width * 0.80, size.height * 0.24);
    final radius = shortest * 0.11;
    final pulse = 1 + 0.05 * math.sin(_tau * progress * 4);

    // Outer glow
    canvas.drawCircle(
      center,
      radius * 2.6 * pulse,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.sunLight.withValues(alpha: 0.45 * intensity),
            AppColors.sunLight.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.6 * pulse)),
    );

    // Rays
    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.14;
    final rotation = _tau * progress; // one revolution per cycle
    const rayCount = 12;
    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (_tau / rayCount) * i;
      final isLong = i.isEven;
      final inner = radius * 1.35;
      final outer = radius * (isLong ? 1.85 : 1.65);
      rayPaint.color = Colors.white.withValues(alpha: (isLong ? 0.55 : 0.32) * intensity);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        rayPaint,
      );
    }

    // Disc
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, AppColors.sunLight, 0.35)!.withValues(alpha: intensity),
            AppColors.sun.withValues(alpha: intensity),
          ],
          stops: const [0.2, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintMoon(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width * 0.80, size.height * 0.24);
    final radius = shortest * 0.09;
    final pulse = 1 + 0.04 * math.sin(_tau * progress * 2);

    canvas.drawCircle(
      center,
      radius * 2.4 * pulse,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE8ECF7).withValues(alpha: 0.30),
            const Color(0xFFE8ECF7).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.4 * pulse)),
    );

    final full = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final cut = Path()
      ..addOval(Rect.fromCircle(
        center: center + Offset(radius * 0.45, -radius * 0.25),
        radius: radius * 0.85,
      ));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cut),
      Paint()..color = const Color(0xFFF6F3E3),
    );
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in particles.stars) {
      final twinkle = 0.5 + 0.5 * math.sin(_tau * (progress * star.speed + star.phase));
      paint.color = Colors.white.withValues(alpha: 0.25 + 0.7 * twinkle);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius * (0.8 + 0.4 * twinkle),
        paint,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Clouds
  // ---------------------------------------------------------------------------

  static const Color _cloudLight = Color(0xFFFFFFFF);
  static const Color _cloudGrey = Color(0xFFDCE4EE);
  static const Color _cloudDark = Color(0xFFB7C4D4);
  static const Color _cloudStorm = Color(0xFF8C9BB0);
  static const Color _cloudNight = Color(0xFF9BA8C2);

  void _paintClouds(Canvas canvas, Size size, {required int count, required Color tint}) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final cloud in particles.clouds.take(count)) {
      final width = cloud.width * size.width;
      // Drift left → right and wrap seamlessly.
      final travel = (cloud.x + progress * cloud.speed) % 1.0;
      final x = travel * (size.width + width) - width;
      final y = cloud.y * size.height;
      paint.color = tint.withValues(alpha: 0.55 * cloud.alpha);
      canvas.drawPath(_cloudPath(Offset(x, y), width), paint);
    }
  }

  Path _cloudPath(Offset origin, double width) {
    final height = width * 0.55;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx + width * 0.08, origin.dy + height * 0.55, width * 0.84, height * 0.45),
        Radius.circular(height * 0.25),
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(origin.dx + width * 0.30, origin.dy + height * 0.62), radius: width * 0.22))
      ..addOval(Rect.fromCircle(
        center: Offset(origin.dx + width * 0.52, origin.dy + height * 0.45), radius: width * 0.30))
      ..addOval(Rect.fromCircle(
        center: Offset(origin.dx + width * 0.75, origin.dy + height * 0.64), radius: width * 0.20));
    return path;
  }

  // ---------------------------------------------------------------------------
  // Precipitation
  // ---------------------------------------------------------------------------

  void _paintRain(Canvas canvas, Size size, {required int count, required double speedScale}) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (final drop in particles.raindrops.take(count)) {
      final length = drop.length * size.height;
      final fall = (drop.phase + progress * (drop.speed * speedScale).round()) % 1.0;
      final y = fall * (size.height + length) - length;
      final x = drop.x * size.width - fall * size.width * 0.06; // slight wind slant
      paint
        ..color = Colors.white.withValues(alpha: drop.alpha)
        ..strokeWidth = drop.width;
      canvas.drawLine(Offset(x, y), Offset(x - length * 0.12, y + length), paint);
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint();
    for (final flake in particles.snowflakes) {
      final fall = (flake.phase + progress * flake.speed) % 1.0;
      final y = fall * (size.height + 12) - 6;
      final sway = math.sin(_tau * (progress * 2 + flake.swayPhase)) * 14;
      final x = flake.x * size.width + sway;
      paint.color = Colors.white.withValues(alpha: flake.alpha);
      canvas.drawCircle(Offset(x, y), flake.radius, paint);
    }
  }

  void _paintLightning(Canvas canvas, Size size) {
    // Two short flash windows per cycle; each flashes twice for realism.
    const windows = [(0.18, 0.21), (0.225, 0.24), (0.66, 0.68), (0.695, 0.705)];
    var flash = 0.0;
    var boltIndex = 0;
    for (var i = 0; i < windows.length; i++) {
      final (start, end) = windows[i];
      if (progress >= start && progress <= end) {
        final local = (progress - start) / (end - start);
        flash = math.sin(local * math.pi); // fade in / out
        boltIndex = i < 2 ? 0 : 1;
        break;
      }
    }
    if (flash <= 0) return;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: 0.16 * flash),
    );

    final startX = size.width * (boltIndex == 0 ? 0.32 : 0.68);
    final bolt = Path()..moveTo(startX, size.height * 0.30);
    final segments = boltIndex == 0
        ? const [(-0.05, 0.14), (0.04, 0.10), (-0.06, 0.16), (0.03, 0.12)]
        : const [(0.05, 0.12), (-0.04, 0.12), (0.06, 0.15), (-0.03, 0.11)];
    var x = startX;
    var y = size.height * 0.30;
    for (final (dx, dy) in segments) {
      x += dx * size.width;
      y += dy * size.height;
      bolt.lineTo(x, y);
    }
    canvas.drawPath(
      bolt,
      Paint()
        ..color = AppColors.sunLight.withValues(alpha: 0.9 * flash)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      bolt,
      Paint()
        ..color = Colors.white.withValues(alpha: flash)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ---------------------------------------------------------------------------
  // Mist
  // ---------------------------------------------------------------------------

  void _paintMist(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    for (final band in particles.mistBands) {
      final width = band.width * size.width;
      final travel = (band.phase + progress * band.speed) % 1.0;
      // Sweep back and forth rather than wrap, so bands never pop in.
      final x = (0.5 - 0.5 * math.cos(_tau * travel)) * (size.width - width);
      paint.color = Colors.white.withValues(alpha: band.alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, band.y * size.height, width, band.height * size.height),
          Radius.circular(band.height * size.height / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WeatherScenePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.condition != condition;
}
