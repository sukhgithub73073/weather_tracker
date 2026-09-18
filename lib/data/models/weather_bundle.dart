import '../../core/utils/json_utils.dart';
import 'air_quality.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';
import 'weather_alert.dart';
import 'weather_location.dart';

/// Everything the UI needs for one location, fetched together and cached
/// as a unit so offline mode always shows a consistent snapshot.
class WeatherBundle {
  const WeatherBundle({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezoneOffsetSeconds,
    required this.fetchedAt,
    this.alerts = const [],
    this.airQuality,
    this.isFromCache = false,
    this.hasFullForecast = true,
  });

  final WeatherLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final List<WeatherAlert> alerts;
  final AirQuality? airQuality;

  /// Seconds from UTC at the location – used for all displayed times.
  final int timezoneOffsetSeconds;
  final DateTime fetchedAt;
  final bool isFromCache;

  /// False when the free tier was used: hourly data is 3-hourly and UV index
  /// / alerts are unavailable.
  final bool hasFullForecast;

  bool isStale(Duration ttl, {DateTime? now}) =>
      (now ?? DateTime.now()).difference(fetchedAt) > ttl;

  List<WeatherAlert> activeAlerts({DateTime? now}) {
    final instant = now ?? DateTime.now().toUtc();
    return alerts.where((a) => !a.end.isBefore(instant)).toList(growable: false);
  }

  /// Hourly entries from now onward, capped at 24 hours.
  List<HourlyForecast> get next24Hours {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(minutes: 59));
    final limit = DateTime.now().toUtc().add(const Duration(hours: 24));
    return hourly
        .where((h) => h.time.isAfter(cutoff) && !h.time.isAfter(limit))
        .toList(growable: false);
  }

  WeatherBundle copyWith({bool? isFromCache, DateTime? fetchedAt}) => WeatherBundle(
        location: location,
        current: current,
        hourly: hourly,
        daily: daily,
        alerts: alerts,
        airQuality: airQuality,
        timezoneOffsetSeconds: timezoneOffsetSeconds,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        isFromCache: isFromCache ?? this.isFromCache,
        hasFullForecast: hasFullForecast,
      );

  factory WeatherBundle.fromJson(Map<String, dynamic> json) => WeatherBundle(
        location: WeatherLocation.fromJson(JsonUtils.toMap(json['location']) ?? const {}),
        current: CurrentWeather.fromJson(JsonUtils.toMap(json['current']) ?? const {}),
        hourly: JsonUtils.toMapList(json['hourly']).map(HourlyForecast.fromJson).toList(),
        daily: JsonUtils.toMapList(json['daily']).map(DailyForecast.fromJson).toList(),
        alerts: JsonUtils.toMapList(json['alerts']).map(WeatherAlert.fromJson).toList(),
        airQuality: json['airQuality'] == null
            ? null
            : AirQuality.fromJson(JsonUtils.toMap(json['airQuality']) ?? const {}),
        timezoneOffsetSeconds: JsonUtils.toInt(json['timezoneOffset']) ?? 0,
        fetchedAt: JsonUtils.fromUnix(json['fetchedAt']) ?? DateTime.now().toUtc(),
        hasFullForecast: JsonUtils.toBool(json['hasFullForecast']) ?? true,
        isFromCache: true,
      );

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'current': current.toJson(),
        'hourly': hourly.map((h) => h.toJson()).toList(),
        'daily': daily.map((d) => d.toJson()).toList(),
        'alerts': alerts.map((a) => a.toJson()).toList(),
        'airQuality': airQuality?.toJson(),
        'timezoneOffset': timezoneOffsetSeconds,
        'fetchedAt': JsonUtils.toUnix(fetchedAt),
        'hasFullForecast': hasFullForecast,
      };
}
