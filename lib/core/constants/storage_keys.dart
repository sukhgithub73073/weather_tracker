/// Keys used with [StorageService]. Keep them here so no two features collide.
class StorageKeys {
  StorageKeys._();

  static const String container = 'weather_tracker';

  // Settings
  static const String themeMode = 'settings.theme_mode';
  static const String temperatureUnit = 'settings.temperature_unit';
  static const String windSpeedUnit = 'settings.wind_speed_unit';
  static const String pressureUnit = 'settings.pressure_unit';
  static const String use24HourClock = 'settings.use_24h_clock';
  static const String dailySummaryEnabled = 'settings.daily_summary_enabled';
  static const String dailySummaryTime = 'settings.daily_summary_time';
  static const String severeAlertsEnabled = 'settings.severe_alerts_enabled';

  // Data
  static const String favorites = 'data.favorites';
  static const String recentSearches = 'data.recent_searches';
  static const String selectedLocation = 'data.selected_location';
  static const String cachedWeatherPrefix = 'cache.weather.';
  static const String lastLocationPermissionAsk = 'data.last_permission_ask';
}
