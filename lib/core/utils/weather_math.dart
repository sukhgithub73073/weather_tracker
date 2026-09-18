import 'dart:math' as math;

/// Small meteorological helpers used to fill gaps between API tiers.
class WeatherMath {
  WeatherMath._();

  /// Dew point (°C) from temperature (°C) and relative humidity (%)
  /// using the Magnus–Tetens approximation.
  static double dewPoint(double temperatureC, num humidityPercent) {
    const a = 17.62;
    const b = 243.12;
    final rh = humidityPercent.clamp(1, 100) / 100;
    final gamma = (a * temperatureC) / (b + temperatureC) + math.log(rh);
    return (b * gamma) / (a - gamma);
  }

  /// Human label for a UV index value.
  static String uvLabel(double? uv) {
    if (uv == null) return 'N/A';
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very high';
    return 'Extreme';
  }

  /// Label for the OpenWeatherMap 1–5 air quality index.
  static String aqiLabel(int aqi) => switch (aqi) {
        1 => 'Good',
        2 => 'Fair',
        3 => 'Moderate',
        4 => 'Poor',
        5 => 'Very poor',
        _ => 'Unknown',
      };

  /// Position of the sun along its daily arc, 0 = sunrise, 1 = sunset.
  /// Returns null when it is night.
  static double? sunProgress(DateTime now, DateTime sunrise, DateTime sunset) {
    if (now.isBefore(sunrise) || now.isAfter(sunset)) return null;
    final total = sunset.difference(sunrise).inSeconds;
    if (total <= 0) return null;
    return now.difference(sunrise).inSeconds / total;
  }
}
