import '../models/coordinates.dart';
import '../models/weather_bundle.dart';
import '../models/weather_location.dart';

/// Business-facing weather access. Swap the implementation to change the
/// weather provider without touching controllers or UI.
abstract class WeatherRepository {
  /// Fetches fresh data from the network and updates the cache.
  /// Throws [ApiException] on failure – callers decide whether to fall back
  /// to [getCached].
  Future<WeatherBundle> fetchWeather(WeatherLocation location);

  /// Last successful response for [location], if any.
  WeatherBundle? getCached(WeatherLocation location);

  /// Last successful response for any location.
  WeatherBundle? getLastCached();

  Future<List<WeatherLocation>> searchLocations(String query, {int limit = 8});

  Future<WeatherLocation?> reverseGeocode(Coordinates coordinates);

  Future<void> clearCache();
}
