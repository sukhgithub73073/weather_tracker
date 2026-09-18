/// Normalised weather conditions used to pick backgrounds, icons and the
/// animated scene. Derived from OpenWeatherMap icon codes.
enum WeatherCondition {
  clearDay,
  clearNight,
  partlyCloudyDay,
  partlyCloudyNight,
  cloudy,
  drizzle,
  rain,
  thunderstorm,
  snow,
  mist,
  unknown;

  bool get isNight =>
      this == WeatherCondition.clearNight || this == WeatherCondition.partlyCloudyNight;

  bool get hasPrecipitation =>
      this == WeatherCondition.drizzle ||
      this == WeatherCondition.rain ||
      this == WeatherCondition.thunderstorm ||
      this == WeatherCondition.snow;

  /// Maps an OpenWeatherMap icon code (`01d`, `10n`, …) to a condition.
  static WeatherCondition fromIcon(String? iconCode) {
    if (iconCode == null || iconCode.length < 2) return WeatherCondition.unknown;
    final code = iconCode.substring(0, 2);
    final isNight = iconCode.endsWith('n');
    switch (code) {
      case '01':
        return isNight ? WeatherCondition.clearNight : WeatherCondition.clearDay;
      case '02':
        return isNight
            ? WeatherCondition.partlyCloudyNight
            : WeatherCondition.partlyCloudyDay;
      case '03':
      case '04':
        return WeatherCondition.cloudy;
      case '09':
        return WeatherCondition.drizzle;
      case '10':
        return WeatherCondition.rain;
      case '11':
        return WeatherCondition.thunderstorm;
      case '13':
        return WeatherCondition.snow;
      case '50':
        return WeatherCondition.mist;
      default:
        return WeatherCondition.unknown;
    }
  }
}
