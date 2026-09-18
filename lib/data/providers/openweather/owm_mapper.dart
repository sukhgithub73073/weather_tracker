import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/utils/weather_math.dart';
import '../../models/air_quality.dart';
import '../../models/coordinates.dart';
import '../../models/current_weather.dart';
import '../../models/daily_forecast.dart';
import '../../models/hourly_forecast.dart';
import '../../models/weather_alert.dart';
import '../../models/weather_location.dart';

/// Pure functions that turn OpenWeatherMap JSON into app models.
///
/// Kept free of I/O so every branch is unit-testable with fixture JSON.
class OwmMapper {
  OwmMapper._();

  // ---------------------------------------------------------------------------
  // Free tier: /data/2.5/weather
  // ---------------------------------------------------------------------------

  static CurrentWeather currentFromWeatherEndpoint(Map<String, dynamic> json) {
    final main = JsonUtils.toMap(json['main']) ?? const {};
    final wind = JsonUtils.toMap(json['wind']) ?? const {};
    final clouds = JsonUtils.toMap(json['clouds']) ?? const {};
    final sys = JsonUtils.toMap(json['sys']) ?? const {};
    final rain = JsonUtils.toMap(json['rain']) ?? const {};
    final snow = JsonUtils.toMap(json['snow']) ?? const {};
    final weather = _firstWeather(json['weather']);

    final temperature = JsonUtils.toDouble(main['temp']) ?? 0;
    final humidity = JsonUtils.toInt(main['humidity']) ?? 0;

    return CurrentWeather(
      timestamp: JsonUtils.fromUnix(json['dt']) ?? DateTime.now().toUtc(),
      temperature: temperature,
      feelsLike: JsonUtils.toDouble(main['feels_like']) ?? temperature,
      tempMin: JsonUtils.toDouble(main['temp_min']) ?? temperature,
      tempMax: JsonUtils.toDouble(main['temp_max']) ?? temperature,
      humidity: humidity,
      pressure: JsonUtils.toDouble(main['pressure']) ?? 0,
      visibility: JsonUtils.toInt(json['visibility']),
      windSpeed: JsonUtils.toDouble(wind['speed']) ?? 0,
      windDegrees: JsonUtils.toInt(wind['deg']) ?? 0,
      windGust: JsonUtils.toDouble(wind['gust']),
      cloudiness: JsonUtils.toInt(clouds['all']) ?? 0,
      // Not provided by this endpoint – derived / filled in by the repository.
      uvIndex: null,
      dewPoint: WeatherMath.dewPoint(temperature, humidity),
      precipitationProbability: null,
      rainLastHour: JsonUtils.toDouble(rain['1h']),
      snowLastHour: JsonUtils.toDouble(snow['1h']),
      conditionId: JsonUtils.toInt(weather['id']) ?? 0,
      conditionMain: JsonUtils.toStr(weather['main']) ?? '',
      description: JsonUtils.toStr(weather['description']) ?? '',
      iconCode: JsonUtils.toStr(weather['icon']) ?? '01d',
      sunrise: JsonUtils.fromUnix(sys['sunrise']) ?? DateTime.now().toUtc(),
      sunset: JsonUtils.fromUnix(sys['sunset']) ?? DateTime.now().toUtc(),
    );
  }

  /// City name/country embedded in the /weather response.
  static WeatherLocation locationFromWeatherEndpoint(
    Map<String, dynamic> json, {
    bool isCurrentLocation = false,
  }) {
    final coord = JsonUtils.toMap(json['coord']) ?? const {};
    final sys = JsonUtils.toMap(json['sys']) ?? const {};
    return WeatherLocation(
      name: JsonUtils.toStr(json['name']) ?? '',
      country: JsonUtils.toStr(sys['country']) ?? '',
      coordinates: Coordinates(
        latitude: JsonUtils.toDouble(coord['lat']) ?? 0,
        longitude: JsonUtils.toDouble(coord['lon']) ?? 0,
      ),
      isCurrentLocation: isCurrentLocation,
    );
  }

  static int timezoneOffsetFromWeatherEndpoint(Map<String, dynamic> json) =>
      JsonUtils.toInt(json['timezone']) ?? 0;

  // ---------------------------------------------------------------------------
  // Free tier: /data/2.5/forecast (3-hour steps, 5 days)
  // ---------------------------------------------------------------------------

  static int timezoneOffsetFromForecastEndpoint(Map<String, dynamic> json) {
    final city = JsonUtils.toMap(json['city']) ?? const {};
    return JsonUtils.toInt(city['timezone']) ?? 0;
  }

  static List<HourlyForecast> hourlyFromForecastEndpoint(Map<String, dynamic> json) {
    return JsonUtils.toMapList(json['list']).map((entry) {
      final main = JsonUtils.toMap(entry['main']) ?? const {};
      final wind = JsonUtils.toMap(entry['wind']) ?? const {};
      final clouds = JsonUtils.toMap(entry['clouds']) ?? const {};
      final weather = _firstWeather(entry['weather']);
      final temperature = JsonUtils.toDouble(main['temp']) ?? 0;
      return HourlyForecast(
        time: JsonUtils.fromUnix(entry['dt']) ?? DateTime.now().toUtc(),
        temperature: temperature,
        feelsLike: JsonUtils.toDouble(main['feels_like']) ?? temperature,
        iconCode: JsonUtils.toStr(weather['icon']) ?? '01d',
        description: JsonUtils.toStr(weather['description']) ?? '',
        precipitationProbability: JsonUtils.toDouble(entry['pop']) ?? 0,
        humidity: JsonUtils.toInt(main['humidity']) ?? 0,
        windSpeed: JsonUtils.toDouble(wind['speed']) ?? 0,
        windDegrees: JsonUtils.toInt(wind['deg']) ?? 0,
        cloudiness: JsonUtils.toInt(clouds['all']),
      );
    }).toList(growable: false);
  }

  /// Collapses 3-hour entries into one row per local calendar day.
  ///
  /// The representative icon/description is the entry closest to midday so
  /// a day is not labelled "clear" because of one clear night slot.
  static List<DailyForecast> dailyFromForecastEndpoint(
    Map<String, dynamic> json, {
    required int timezoneOffsetSeconds,
  }) {
    final entries = JsonUtils.toMapList(json['list']);
    final city = JsonUtils.toMap(json['city']) ?? const {};
    final sunrise = JsonUtils.fromUnix(city['sunrise']);
    final sunset = JsonUtils.fromUnix(city['sunset']);

    final groups = <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in entries) {
      final time = JsonUtils.fromUnix(entry['dt']);
      if (time == null) continue;
      final local = DateFormatter.toLocationTime(time, timezoneOffsetSeconds);
      final dayKey = DateTime.utc(local.year, local.month, local.day);
      groups.putIfAbsent(dayKey, () => []).add(entry);
    }

    final days = <DailyForecast>[];
    for (final dayEntry in groups.entries) {
      final list = dayEntry.value;
      var min = double.infinity;
      var max = double.negativeInfinity;
      var pop = 0.0;
      var humiditySum = 0;
      var windMax = 0.0;
      var windDeg = 0;
      var rain = 0.0;
      var snow = 0.0;
      var pressureSum = 0.0;
      var cloudSum = 0;
      Map<String, dynamic>? representative;
      var bestDistance = 1 << 30;

      for (final entry in list) {
        final main = JsonUtils.toMap(entry['main']) ?? const {};
        final wind = JsonUtils.toMap(entry['wind']) ?? const {};
        final clouds = JsonUtils.toMap(entry['clouds']) ?? const {};
        final temp = JsonUtils.toDouble(main['temp']) ?? 0;
        min = [min, JsonUtils.toDouble(main['temp_min']) ?? temp, temp].reduce((a, b) => a < b ? a : b);
        max = [max, JsonUtils.toDouble(main['temp_max']) ?? temp, temp].reduce((a, b) => a > b ? a : b);
        final entryPop = JsonUtils.toDouble(entry['pop']) ?? 0;
        if (entryPop > pop) pop = entryPop;
        humiditySum += JsonUtils.toInt(main['humidity']) ?? 0;
        pressureSum += JsonUtils.toDouble(main['pressure']) ?? 0;
        cloudSum += JsonUtils.toInt(clouds['all']) ?? 0;
        final speed = JsonUtils.toDouble(wind['speed']) ?? 0;
        if (speed >= windMax) {
          windMax = speed;
          windDeg = JsonUtils.toInt(wind['deg']) ?? windDeg;
        }
        rain += JsonUtils.toDouble((JsonUtils.toMap(entry['rain']) ?? const {})['3h']) ?? 0;
        snow += JsonUtils.toDouble((JsonUtils.toMap(entry['snow']) ?? const {})['3h']) ?? 0;

        final time = JsonUtils.fromUnix(entry['dt'])!;
        final localHour = DateFormatter.toLocationTime(time, timezoneOffsetSeconds).hour;
        final distance = (localHour - 12).abs();
        if (distance < bestDistance) {
          bestDistance = distance;
          representative = entry;
        }
      }

      final weather = _firstWeather(representative?['weather']);
      days.add(
        DailyForecast(
          // Midday UTC of the local day keeps day-name formatting stable.
          date: dayEntry.key.subtract(Duration(seconds: timezoneOffsetSeconds)).add(const Duration(hours: 12)),
          tempMin: min.isFinite ? min : 0,
          tempMax: max.isFinite ? max : 0,
          iconCode: (JsonUtils.toStr(weather['icon']) ?? '01d').replaceAll('n', 'd'),
          description: JsonUtils.toStr(weather['description']) ?? '',
          conditionMain: JsonUtils.toStr(weather['main']) ?? '',
          precipitationProbability: pop,
          humidity: list.isEmpty ? 0 : (humiditySum / list.length).round(),
          windSpeed: windMax,
          windDegrees: windDeg,
          rainVolume: rain > 0 ? rain : null,
          snowVolume: snow > 0 ? snow : null,
          cloudiness: list.isEmpty ? null : (cloudSum / list.length).round(),
          pressure: list.isEmpty ? null : pressureSum / list.length,
          // The 5-day endpoint only reports today's sun times; reuse them.
          sunrise: sunrise,
          sunset: sunset,
        ),
      );
    }
    days.sort((a, b) => a.date.compareTo(b.date));
    return days;
  }

  // ---------------------------------------------------------------------------
  // One Call 3.0
  // ---------------------------------------------------------------------------

  static int timezoneOffsetFromOneCall(Map<String, dynamic> json) =>
      JsonUtils.toInt(json['timezone_offset']) ?? 0;

  static CurrentWeather currentFromOneCall(Map<String, dynamic> json) {
    final current = JsonUtils.toMap(json['current']) ?? const {};
    final daily = JsonUtils.toMapList(json['daily']);
    final today = daily.isNotEmpty ? JsonUtils.toMap(daily.first['temp']) ?? const {} : const {};
    final hourly = JsonUtils.toMapList(json['hourly']);
    final weather = _firstWeather(current['weather']);
    final rain = JsonUtils.toMap(current['rain']) ?? const {};
    final snow = JsonUtils.toMap(current['snow']) ?? const {};
    final temperature = JsonUtils.toDouble(current['temp']) ?? 0;
    final humidity = JsonUtils.toInt(current['humidity']) ?? 0;

    return CurrentWeather(
      timestamp: JsonUtils.fromUnix(current['dt']) ?? DateTime.now().toUtc(),
      temperature: temperature,
      feelsLike: JsonUtils.toDouble(current['feels_like']) ?? temperature,
      tempMin: JsonUtils.toDouble(today['min']) ?? temperature,
      tempMax: JsonUtils.toDouble(today['max']) ?? temperature,
      humidity: humidity,
      pressure: JsonUtils.toDouble(current['pressure']) ?? 0,
      visibility: JsonUtils.toInt(current['visibility']),
      windSpeed: JsonUtils.toDouble(current['wind_speed']) ?? 0,
      windDegrees: JsonUtils.toInt(current['wind_deg']) ?? 0,
      windGust: JsonUtils.toDouble(current['wind_gust']),
      cloudiness: JsonUtils.toInt(current['clouds']) ?? 0,
      uvIndex: JsonUtils.toDouble(current['uvi']),
      dewPoint: JsonUtils.toDouble(current['dew_point']) ?? WeatherMath.dewPoint(temperature, humidity),
      precipitationProbability:
          hourly.isNotEmpty ? JsonUtils.toDouble(hourly.first['pop']) : null,
      rainLastHour: JsonUtils.toDouble(rain['1h']),
      snowLastHour: JsonUtils.toDouble(snow['1h']),
      conditionId: JsonUtils.toInt(weather['id']) ?? 0,
      conditionMain: JsonUtils.toStr(weather['main']) ?? '',
      description: JsonUtils.toStr(weather['description']) ?? '',
      iconCode: JsonUtils.toStr(weather['icon']) ?? '01d',
      sunrise: JsonUtils.fromUnix(current['sunrise']) ?? DateTime.now().toUtc(),
      sunset: JsonUtils.fromUnix(current['sunset']) ?? DateTime.now().toUtc(),
    );
  }

  static List<HourlyForecast> hourlyFromOneCall(Map<String, dynamic> json) {
    return JsonUtils.toMapList(json['hourly']).map((entry) {
      final weather = _firstWeather(entry['weather']);
      final temperature = JsonUtils.toDouble(entry['temp']) ?? 0;
      return HourlyForecast(
        time: JsonUtils.fromUnix(entry['dt']) ?? DateTime.now().toUtc(),
        temperature: temperature,
        feelsLike: JsonUtils.toDouble(entry['feels_like']) ?? temperature,
        iconCode: JsonUtils.toStr(weather['icon']) ?? '01d',
        description: JsonUtils.toStr(weather['description']) ?? '',
        precipitationProbability: JsonUtils.toDouble(entry['pop']) ?? 0,
        humidity: JsonUtils.toInt(entry['humidity']) ?? 0,
        windSpeed: JsonUtils.toDouble(entry['wind_speed']) ?? 0,
        windDegrees: JsonUtils.toInt(entry['wind_deg']) ?? 0,
        uvIndex: JsonUtils.toDouble(entry['uvi']),
        cloudiness: JsonUtils.toInt(entry['clouds']),
      );
    }).toList(growable: false);
  }

  static List<DailyForecast> dailyFromOneCall(Map<String, dynamic> json) {
    return JsonUtils.toMapList(json['daily']).map((entry) {
      final temp = JsonUtils.toMap(entry['temp']) ?? const {};
      final feels = JsonUtils.toMap(entry['feels_like']) ?? const {};
      final weather = _firstWeather(entry['weather']);
      return DailyForecast(
        date: JsonUtils.fromUnix(entry['dt']) ?? DateTime.now().toUtc(),
        tempMin: JsonUtils.toDouble(temp['min']) ?? 0,
        tempMax: JsonUtils.toDouble(temp['max']) ?? 0,
        tempDay: JsonUtils.toDouble(temp['day']),
        tempNight: JsonUtils.toDouble(temp['night']),
        feelsLikeDay: JsonUtils.toDouble(feels['day']),
        iconCode: JsonUtils.toStr(weather['icon']) ?? '01d',
        description: JsonUtils.toStr(weather['description']) ?? '',
        conditionMain: JsonUtils.toStr(weather['main']) ?? '',
        precipitationProbability: JsonUtils.toDouble(entry['pop']) ?? 0,
        humidity: JsonUtils.toInt(entry['humidity']) ?? 0,
        windSpeed: JsonUtils.toDouble(entry['wind_speed']) ?? 0,
        windDegrees: JsonUtils.toInt(entry['wind_deg']) ?? 0,
        uvIndex: JsonUtils.toDouble(entry['uvi']),
        sunrise: JsonUtils.fromUnix(entry['sunrise']),
        sunset: JsonUtils.fromUnix(entry['sunset']),
        rainVolume: JsonUtils.toDouble(entry['rain']),
        snowVolume: JsonUtils.toDouble(entry['snow']),
        cloudiness: JsonUtils.toInt(entry['clouds']),
        pressure: JsonUtils.toDouble(entry['pressure']),
        summary: JsonUtils.toStr(entry['summary']),
      );
    }).toList(growable: false);
  }

  static List<WeatherAlert> alertsFromOneCall(Map<String, dynamic> json) {
    return JsonUtils.toMapList(json['alerts']).map((entry) {
      return WeatherAlert(
        senderName: JsonUtils.toStr(entry['sender_name']) ?? '',
        event: JsonUtils.toStr(entry['event']) ?? 'Weather alert',
        start: JsonUtils.fromUnix(entry['start']) ?? DateTime.now().toUtc(),
        end: JsonUtils.fromUnix(entry['end']) ?? DateTime.now().toUtc(),
        description: JsonUtils.toStr(entry['description']) ?? '',
        tags: (entry['tags'] as List?)?.whereType<String>().toList() ?? const [],
      );
    }).toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Air pollution & geocoding
  // ---------------------------------------------------------------------------

  static AirQuality? airQualityFromEndpoint(Map<String, dynamic> json) {
    final list = JsonUtils.toMapList(json['list']);
    if (list.isEmpty) return null;
    final entry = list.first;
    final main = JsonUtils.toMap(entry['main']) ?? const {};
    final c = JsonUtils.toMap(entry['components']) ?? const {};
    return AirQuality(
      timestamp: JsonUtils.fromUnix(entry['dt']) ?? DateTime.now().toUtc(),
      index: JsonUtils.toInt(main['aqi']) ?? 0,
      pm2_5: JsonUtils.toDouble(c['pm2_5']) ?? 0,
      pm10: JsonUtils.toDouble(c['pm10']) ?? 0,
      ozone: JsonUtils.toDouble(c['o3']) ?? 0,
      nitrogenDioxide: JsonUtils.toDouble(c['no2']) ?? 0,
      sulphurDioxide: JsonUtils.toDouble(c['so2']) ?? 0,
      carbonMonoxide: JsonUtils.toDouble(c['co']) ?? 0,
    );
  }

  static WeatherLocation locationFromGeocoding(
    Map<String, dynamic> json, {
    bool isCurrentLocation = false,
  }) =>
      WeatherLocation(
        name: JsonUtils.toStr(json['name']) ?? '',
        state: JsonUtils.toStr(json['state']),
        country: JsonUtils.toStr(json['country']) ?? '',
        coordinates: Coordinates(
          latitude: JsonUtils.toDouble(json['lat']) ?? 0,
          longitude: JsonUtils.toDouble(json['lon']) ?? 0,
        ),
        isCurrentLocation: isCurrentLocation,
      );

  static Map<String, dynamic> _firstWeather(dynamic list) {
    final items = JsonUtils.toMapList(list);
    return items.isEmpty ? const {} : items.first;
  }
}
