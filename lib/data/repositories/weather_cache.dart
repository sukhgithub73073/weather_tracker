import '../../core/constants/storage_keys.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_logger.dart';
import '../models/weather_bundle.dart';
import '../models/weather_location.dart';

/// Persists the last successful [WeatherBundle] per location for offline use.
class WeatherCache {
  WeatherCache(this._storage);

  final StorageService _storage;

  static const String _lastKey = '${StorageKeys.cachedWeatherPrefix}last';

  String _keyFor(WeatherLocation location) =>
      '${StorageKeys.cachedWeatherPrefix}${location.id}';

  Future<void> save(WeatherBundle bundle) async {
    try {
      await _storage.write(_keyFor(bundle.location), bundle.toJson());
      await _storage.write(_lastKey, _keyFor(bundle.location));
    } catch (error) {
      AppLogger.e('Failed to cache weather', error: error, tag: 'WeatherCache');
    }
  }

  WeatherBundle? read(WeatherLocation location) => _readKey(_keyFor(location));

  /// The most recently saved bundle for any location.
  WeatherBundle? readLast() {
    final key = _storage.read<String>(_lastKey);
    return key == null ? null : _readKey(key);
  }

  WeatherBundle? _readKey(String key) {
    final json = _storage.readJson(key);
    if (json == null) return null;
    try {
      return WeatherBundle.fromJson(json);
    } catch (error) {
      AppLogger.e('Corrupt weather cache, discarding', error: error, tag: 'WeatherCache');
      _storage.remove(key);
      return null;
    }
  }

  Future<void> clear() =>
      _storage.removeWhere((key) => key.startsWith(StorageKeys.cachedWeatherPrefix));
}
