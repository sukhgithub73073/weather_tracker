/// OpenWeatherMap endpoints and helpers.
///
/// Only paths live here – the base URL and API key come from [Env] so the
/// provider can be swapped or pointed at a proxy without touching code.
class ApiConstants {
  ApiConstants._();

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Free tier endpoints
  static const String currentWeather = '/data/2.5/weather';
  static const String forecast5Day = '/data/2.5/forecast';
  static const String airPollution = '/data/2.5/air_pollution';

  // One Call 3.0 (subscription) – hourly, daily, UV index, alerts
  static const String oneCall = '/data/3.0/onecall';

  // Geocoding
  static const String geoDirect = '/geo/1.0/direct';
  static const String geoReverse = '/geo/1.0/reverse';

  /// Units requested from the API. The app converts locally so unit changes
  /// in Settings never require another network call.
  static const String units = 'metric';

  /// Weather condition icon, e.g. `10d` → https://openweathermap.org/img/wn/10d@4x.png
  static String iconUrl(String iconCode, {int scale = 4}) =>
      'https://openweathermap.org/img/wn/$iconCode@${scale}x.png';

  /// Raster tile layer for the weather map (precipitation_new, clouds_new,
  /// temp_new, wind_new, pressure_new). `{z}/{x}/{y}` are filled by flutter_map.
  static String tileUrl(String layer, String apiKey) =>
      'https://tile.openweathermap.org/map/$layer/{z}/{x}/{y}.png?appid=$apiKey';

  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
