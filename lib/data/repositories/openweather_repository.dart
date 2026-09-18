import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../../core/constants/feature_flags.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/app_logger.dart';
import '../models/air_quality.dart';
import '../models/coordinates.dart';
import '../models/current_weather.dart';
import '../models/daily_forecast.dart';
import '../models/hourly_forecast.dart';
import '../models/weather_alert.dart';
import '../models/weather_bundle.dart';
import '../models/weather_location.dart';
import '../providers/openweather/openweather_provider.dart';
import '../providers/openweather/owm_mapper.dart';
import 'weather_cache.dart';
import 'weather_repository.dart';

/// OpenWeatherMap-backed [WeatherRepository].
///
/// Uses One Call 3.0 when `OPENWEATHER_USE_ONE_CALL=true`; otherwise it
/// combines the free *Current Weather* and *5 day / 3 hour* endpoints and
/// fills the gaps (dew point, today's high/low, daily rows) locally.
class OpenWeatherRepository implements WeatherRepository {
  OpenWeatherRepository({
    required OpenWeatherProvider provider,
    required WeatherCache cache,
    bool? useOneCall,
  })  : _provider = provider,
        _cache = cache,
        _useOneCall = useOneCall ?? Env.useOneCallApi;

  final OpenWeatherProvider _provider;
  final WeatherCache _cache;
  final bool _useOneCall;

  @override
  Future<WeatherBundle> fetchWeather(WeatherLocation location) async {
    final coordinates = location.coordinates;

    final airQualityFuture = FeatureFlags.airQuality
        ? _fetchAirQualityQuietly(coordinates)
        : Future<AirQuality?>.value(null);

    _ForecastData data;
    if (_useOneCall) {
      try {
        data = await _fetchOneCall(coordinates);
      } on InvalidApiKeyException {
        // Key valid for free endpoints but not One Call – degrade gracefully.
        AppLogger.d('One Call rejected the key, falling back to free tier', tag: 'Weather');
        data = await _fetchFreeTier(coordinates);
      }
    } else {
      data = await _fetchFreeTier(coordinates);
    }

    final resolvedLocation = await _resolveLocation(location, data.fallbackLocation);

    final bundle = WeatherBundle(
      location: resolvedLocation,
      current: data.current,
      hourly: data.hourly,
      daily: data.daily,
      alerts: FeatureFlags.weatherAlerts ? data.alerts : const [],
      airQuality: await airQualityFuture,
      timezoneOffsetSeconds: data.timezoneOffset,
      fetchedAt: DateTime.now().toUtc(),
      hasFullForecast: data.isFull,
    );

    await _cache.save(bundle);
    return bundle;
  }

  Future<_ForecastData> _fetchOneCall(Coordinates coordinates) async {
    final json = await _provider.fetchOneCall(coordinates);
    final daily = OwmMapper.dailyFromOneCall(json);
    return _ForecastData(
      current: OwmMapper.currentFromOneCall(json),
      hourly: OwmMapper.hourlyFromOneCall(json),
      daily: daily.take(7).toList(growable: false),
      alerts: OwmMapper.alertsFromOneCall(json),
      timezoneOffset: OwmMapper.timezoneOffsetFromOneCall(json),
      fallbackLocation: null,
      isFull: true,
    );
  }

  Future<_ForecastData> _fetchFreeTier(Coordinates coordinates) async {
    final results = await Future.wait([
      _provider.fetchCurrentWeather(coordinates),
      _provider.fetchForecast5Day(coordinates),
    ]);
    final currentJson = results[0];
    final forecastJson = results[1];

    final timezoneOffset = OwmMapper.timezoneOffsetFromWeatherEndpoint(currentJson);
    final hourly = OwmMapper.hourlyFromForecastEndpoint(forecastJson);
    final daily = OwmMapper.dailyFromForecastEndpoint(
      forecastJson,
      timezoneOffsetSeconds: timezoneOffset,
    );

    var current = OwmMapper.currentFromWeatherEndpoint(currentJson);
    // /weather's temp_min/max describe the current spread across stations,
    // not the day's range – merge with the aggregated forecast for today.
    if (daily.isNotEmpty) {
      final today = daily.first;
      current = current.copyWith(
        tempMin: [current.tempMin, today.tempMin, current.temperature].reduce((a, b) => a < b ? a : b),
        tempMax: [current.tempMax, today.tempMax, current.temperature].reduce((a, b) => a > b ? a : b),
        precipitationProbability: hourly.isNotEmpty ? hourly.first.precipitationProbability : null,
      );
    }

    return _ForecastData(
      current: current,
      hourly: hourly,
      daily: daily,
      alerts: const [],
      timezoneOffset: timezoneOffset,
      fallbackLocation: OwmMapper.locationFromWeatherEndpoint(currentJson),
      isFull: false,
    );
  }

  Future<AirQuality?> _fetchAirQualityQuietly(Coordinates coordinates) async {
    try {
      return OwmMapper.airQualityFromEndpoint(await _provider.fetchAirPollution(coordinates));
    } catch (error) {
      AppLogger.d('Air quality unavailable: $error', tag: 'Weather');
      return null;
    }
  }

  /// GPS locations arrive without a name – reverse geocode them, falling
  /// back to whatever the weather endpoint reported.
  Future<WeatherLocation> _resolveLocation(
    WeatherLocation requested,
    WeatherLocation? fallback,
  ) async {
    if (requested.name.isNotEmpty) return requested;
    final geocoded = await reverseGeocode(requested.coordinates);
    final resolved = geocoded ?? fallback;
    if (resolved == null) {
      return requested.copyWith(name: 'Current location');
    }
    return resolved.copyWith(
      coordinates: requested.coordinates,
      isCurrentLocation: requested.isCurrentLocation,
    );
  }

  @override
  WeatherBundle? getCached(WeatherLocation location) => _cache.read(location);

  @override
  WeatherBundle? getLastCached() => _cache.readLast();

  @override
  Future<List<WeatherLocation>> searchLocations(
    String query, {
    int limit = 8,
    CancelToken? cancelToken,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final results = await _provider.geocode(trimmed, limit: limit, cancelToken: cancelToken);
    final seen = <String>{};
    return results
        .whereType<Map>()
        .map((json) => OwmMapper.locationFromGeocoding(Map<String, dynamic>.from(json)))
        .where((location) => location.name.isNotEmpty && seen.add(location.id))
        .toList(growable: false);
  }

  @override
  Future<WeatherLocation?> reverseGeocode(Coordinates coordinates) async {
    try {
      final results = await _provider.reverseGeocode(coordinates);
      if (results.isEmpty || results.first is! Map) return null;
      return OwmMapper.locationFromGeocoding(
        Map<String, dynamic>.from(results.first as Map),
        isCurrentLocation: true,
      ).copyWith(coordinates: coordinates);
    } on ApiException catch (error) {
      AppLogger.d('Reverse geocode failed: $error', tag: 'Weather');
      return null;
    }
  }

  @override
  Future<void> clearCache() => _cache.clear();
}

class _ForecastData {
  const _ForecastData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.alerts,
    required this.timezoneOffset,
    required this.fallbackLocation,
    required this.isFull,
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final List<WeatherAlert> alerts;
  final int timezoneOffset;
  final WeatherLocation? fallbackLocation;
  final bool isFull;
}
