import 'dart:math' as math;

/// Deterministic particle layouts, generated once and reused every frame.
/// All values are normalised (0..1) and scaled to the canvas when painting.
///
/// Speeds are whole numbers of loops per animation cycle so positions are
/// identical at t = 0 and t = 1 – the loop is seamless.
class SceneParticles {
  SceneParticles({int seed = 1}) {
    final random = math.Random(seed);
    stars = List.generate(46, (_) => Star(
          x: random.nextDouble(),
          y: random.nextDouble() * 0.65,
          radius: 0.6 + random.nextDouble() * 1.5,
          phase: random.nextDouble(),
          speed: 3 + random.nextInt(5),
        ));
    raindrops = List.generate(120, (_) => Raindrop(
          x: random.nextDouble(),
          phase: random.nextDouble(),
          speed: 14 + random.nextInt(10),
          length: 0.035 + random.nextDouble() * 0.03,
          alpha: 0.25 + random.nextDouble() * 0.35,
          width: 1.2 + random.nextDouble() * 0.9,
        ));
    snowflakes = List.generate(70, (_) => Snowflake(
          x: random.nextDouble(),
          phase: random.nextDouble(),
          speed: 3 + random.nextInt(4),
          radius: 1.4 + random.nextDouble() * 2.6,
          swayPhase: random.nextDouble(),
          alpha: 0.5 + random.nextDouble() * 0.5,
        ));
    clouds = [
      const Cloud(x: 0.05, y: 0.10, width: 0.42, speed: 1, alpha: 0.95),
      const Cloud(x: 0.55, y: 0.30, width: 0.34, speed: 2, alpha: 0.75),
      const Cloud(x: 0.30, y: 0.48, width: 0.50, speed: 1, alpha: 0.85),
      const Cloud(x: 0.80, y: 0.06, width: 0.28, speed: 2, alpha: 0.65),
      const Cloud(x: 0.62, y: 0.66, width: 0.38, speed: 1, alpha: 0.70),
    ];
    mistBands = [
      const MistBand(y: 0.22, height: 0.14, width: 0.75, phase: 0.0, speed: 1, alpha: 0.16),
      const MistBand(y: 0.42, height: 0.16, width: 0.85, phase: 0.4, speed: 1, alpha: 0.20),
      const MistBand(y: 0.62, height: 0.15, width: 0.70, phase: 0.7, speed: 2, alpha: 0.18),
      const MistBand(y: 0.82, height: 0.18, width: 0.90, phase: 0.2, speed: 1, alpha: 0.22),
    ];
  }

  late final List<Star> stars;
  late final List<Raindrop> raindrops;
  late final List<Snowflake> snowflakes;
  late final List<Cloud> clouds;
  late final List<MistBand> mistBands;
}

class Star {
  const Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });
  final double x, y, radius, phase;
  final int speed;
}

class Raindrop {
  const Raindrop({
    required this.x,
    required this.phase,
    required this.speed,
    required this.length,
    required this.alpha,
    required this.width,
  });
  final double x, phase, length, alpha, width;
  final int speed;
}

class Snowflake {
  const Snowflake({
    required this.x,
    required this.phase,
    required this.speed,
    required this.radius,
    required this.swayPhase,
    required this.alpha,
  });
  final double x, phase, radius, swayPhase, alpha;
  final int speed;
}

class Cloud {
  const Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.speed,
    required this.alpha,
  });
  final double x, y, width, alpha;
  final int speed;
}

class MistBand {
  const MistBand({
    required this.y,
    required this.height,
    required this.width,
    required this.phase,
    required this.speed,
    required this.alpha,
  });
  final double y, height, width, phase, alpha;
  final int speed;
}
