import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to values from the `.env` file.
///
/// Secrets are never hardcoded – copy `.env.example` to `.env` and fill it in.
class Env {
  Env._();

  static const String _fileName = '.env';
  static bool _loaded = false;

  /// Loads the `.env` asset. Safe to call when the file is missing: the app
  /// still boots and surfaces a "missing API key" state instead of crashing.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: _fileName);
    } catch (error) {
      debugPrint('Env: could not load $_fileName ($error)');
    } finally {
      _loaded = true;
    }
  }

  static String _get(String key, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    final value = dotenv.maybeGet(key)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static String get openWeatherApiKey => _get('OPENWEATHER_API_KEY');

  static bool get hasApiKey => openWeatherApiKey.isNotEmpty;

  static String get openWeatherBaseUrl =>
      _get('OPENWEATHER_BASE_URL', fallback: 'https://api.openweathermap.org');

  /// Whether the key has One Call 3.0 access (hourly/daily/UV/alerts).
  static bool get useOneCallApi =>
      _get('OPENWEATHER_USE_ONE_CALL', fallback: 'false').toLowerCase() ==
      'true';
}
