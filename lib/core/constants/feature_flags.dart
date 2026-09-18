/// Compile-time switches for optional features.
///
/// Flip a flag to hide the feature everywhere (routes, navigation, settings)
/// without deleting code.
class FeatureFlags {
  FeatureFlags._();

  /// Weather map screen (flutter_map + OpenWeatherMap tile overlays).
  static const bool weatherMap = true;

  /// Local notifications (daily summary + severe alerts).
  static const bool notifications = true;

  /// Air quality card on the details screen (OpenWeatherMap Air Pollution API).
  static const bool airQuality = true;

  /// Severe weather alerts (requires One Call 3.0 – gracefully hidden otherwise).
  static const bool weatherAlerts = true;
}
