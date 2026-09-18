/// App-wide constants that are not secrets and not theme related.
class AppConstants {
  AppConstants._();

  static const String appName = 'Weather Tracker';
  static const String tagline = 'Your sky, in real time';
  static const String supportEmail = 'support@weathertracker.app';
  static const String privacyUrl = 'https://weathertracker.app/privacy';

  /// Minimum time the splash screen stays visible so the animation completes.
  static const Duration splashMinDuration = Duration(milliseconds: 2600);

  /// Cached weather older than this is considered stale and refreshed.
  static const Duration weatherCacheTtl = Duration(minutes: 30);

  /// Maximum number of recent searches kept in local storage.
  static const int maxRecentSearches = 10;

  /// Maximum number of favorite locations a user can save.
  static const int maxFavorites = 20;

  /// Debounce applied to the city search field.
  static const Duration searchDebounce = Duration(milliseconds: 450);

  /// Shown when the device position is unavailable (permission denied,
  /// location services off, GPS failure). The name is resolved by reverse
  /// geocoding at runtime.
  static const double fallbackLatitude = 30.685860;
  static const double fallbackLongitude = 74.744324;
}
