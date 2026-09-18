import 'package:flutter/material.dart';

import '../../core/utils/weather_condition.dart';

export '../../core/utils/weather_condition.dart';

/// Background gradients that react to the current weather.
///
/// Pure Dart – unit tested in `test/app/theme/weather_gradients_test.dart`.
class WeatherGradients {
  WeatherGradients._();

  /// Maps an OpenWeatherMap icon code (`01d`, `10n`, …) to a condition.
  static WeatherCondition conditionFromIcon(String? iconCode) =>
      WeatherCondition.fromIcon(iconCode);

  static LinearGradient forIcon(String? iconCode, {Brightness brightness = Brightness.light}) =>
      forCondition(conditionFromIcon(iconCode), brightness: brightness);

  static LinearGradient forCondition(
    WeatherCondition condition, {
    Brightness brightness = Brightness.light,
  }) {
    final colors = _colorsFor(condition);
    final adjusted = brightness == Brightness.dark
        ? colors.map((c) => Color.lerp(c, const Color(0xFF07111F), 0.28)!).toList()
        : colors;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: adjusted,
    );
  }

  /// Text/icon color that stays legible on every gradient.
  static const Color onGradient = Colors.white;

  static List<Color> _colorsFor(WeatherCondition condition) => switch (condition) {
        WeatherCondition.clearDay => const [
            Color(0xFF1E88E5),
            Color(0xFF42A5F5),
            Color(0xFF7FD0F7),
          ],
        WeatherCondition.clearNight => const [
            Color(0xFF0B1A33),
            Color(0xFF1B2D55),
            Color(0xFF2E4370),
          ],
        WeatherCondition.partlyCloudyDay => const [
            Color(0xFF2F82CF),
            Color(0xFF5FA6DF),
            Color(0xFF93C5EA),
          ],
        WeatherCondition.partlyCloudyNight => const [
            Color(0xFF16264A),
            Color(0xFF2A3D66),
            Color(0xFF45598A),
          ],
        WeatherCondition.cloudy => const [
            Color(0xFF546E8C),
            Color(0xFF74899F),
            Color(0xFF9DAEC0),
          ],
        WeatherCondition.drizzle => const [
            Color(0xFF3E5E7E),
            Color(0xFF5A7E9E),
            Color(0xFF7FA0BC),
          ],
        WeatherCondition.rain => const [
            Color(0xFF2B4A68),
            Color(0xFF3F6788),
            Color(0xFF5E88A8),
          ],
        WeatherCondition.thunderstorm => const [
            Color(0xFF1B2433),
            Color(0xFF2E3C52),
            Color(0xFF4A5A75),
          ],
        WeatherCondition.snow => const [
            Color(0xFF6FA0C8),
            Color(0xFFA3C4DE),
            Color(0xFFD8E7F3),
          ],
        WeatherCondition.mist => const [
            Color(0xFF6E8296),
            Color(0xFF93A4B5),
            Color(0xFFB7C4D0),
          ],
        WeatherCondition.unknown => const [
            Color(0xFF1565C0),
            Color(0xFF1E88E5),
            Color(0xFF42A5F5),
          ],
      };
}
