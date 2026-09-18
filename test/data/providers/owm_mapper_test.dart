import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/core/utils/weather_condition.dart';
import 'package:weathertracker/data/providers/openweather/owm_mapper.dart';

import '../../fixtures/owm_fixtures.dart';

void main() {
  group('currentFromWeatherEndpoint', () {
    test('maps the main fields and derives the dew point', () {
      final current = OwmMapper.currentFromWeatherEndpoint(currentWeatherJson());

      expect(current.temperature, 18.4);
      expect(current.feelsLike, 18.1);
      expect(current.humidity, 72);
      expect(current.pressure, 1012);
      expect(current.visibility, 10000);
      expect(current.windSpeed, 4.6);
      expect(current.windDegrees, 230);
      expect(current.windGust, 8.2);
      expect(current.cloudiness, 75);
      expect(current.rainLastHour, 0.4);
      expect(current.iconCode, '10d');
      expect(current.condition, WeatherCondition.rain);
      expect(current.capitalizedDescription, 'Light rain');
      expect(current.uvIndex, isNull, reason: 'free tier has no UV');
      expect(current.dewPoint, closeTo(13.2, 0.3));
      expect(current.sunrise.isUtc, isTrue);
      expect(current.timestamp, DateTime.utc(2025, 6, 10, 11));
    });

    test('extracts the location and timezone', () {
      final json = currentWeatherJson();
      final location = OwmMapper.locationFromWeatherEndpoint(json);
      expect(location.name, 'London');
      expect(location.country, 'GB');
      expect(location.coordinates.latitude, 51.5085);
      expect(OwmMapper.timezoneOffsetFromWeatherEndpoint(json), 3600);
    });
  });

  group('forecast endpoint', () {
    test('hourly keeps every 3-hour step in order', () {
      final hourly = OwmMapper.hourlyFromForecastEndpoint(forecastJson());
      expect(hourly.length, 7);
      expect(hourly.first.temperature, 20);
      expect(hourly[2].precipitationProbability, 0.6);
      expect(hourly[2].condition, WeatherCondition.rain);
    });

    test('daily aggregation groups by local day', () {
      final daily = OwmMapper.dailyFromForecastEndpoint(
        forecastJson(),
        timezoneOffsetSeconds: 3600,
      );

      expect(daily.length, 2);

      final today = daily[0];
      expect(today.tempMin, 14, reason: 'min of temp_min over 4 entries (15-1)');
      expect(today.tempMax, 23, reason: 'max of temp_max (22+1)');
      expect(today.precipitationProbability, 0.6, reason: 'max pop of the day');
      expect(today.rainVolume, closeTo(1.2, 0.001));
      expect(today.iconCode, '01d', reason: 'entry closest to midday represents the day');
      expect(today.humidity, 60);

      final tomorrow = daily[1];
      expect(tomorrow.tempMin, 11);
      expect(tomorrow.tempMax, 25);
      expect(tomorrow.iconCode, '02d');
      expect(tomorrow.rainVolume, isNull);
    });

    test('daily rows never use a night icon', () {
      final json = forecastJson();
      // Only night entries for the second day.
      (json['list'] as List).removeLast();
      final daily = OwmMapper.dailyFromForecastEndpoint(json, timezoneOffsetSeconds: 3600);
      expect(daily[1].iconCode, '01d');
    });

    test('daily dates format as consecutive local days', () {
      final daily = OwmMapper.dailyFromForecastEndpoint(forecastJson(), timezoneOffsetSeconds: 3600);
      final first = daily[0].date.add(const Duration(seconds: 3600));
      final second = daily[1].date.add(const Duration(seconds: 3600));
      expect(first.day, 10);
      expect(second.day, 11);
      expect(first.hour, 12);
    });
  });

  test('air pollution maps the first sample', () {
    final aqi = OwmMapper.airQualityFromEndpoint(airPollutionJson());
    expect(aqi, isNotNull);
    expect(aqi!.index, 2);
    expect(aqi.label, 'Fair');
    expect(aqi.pm2_5, 8.5);
  });

  test('air pollution returns null for an empty list', () {
    expect(OwmMapper.airQualityFromEndpoint({'list': []}), isNull);
  });

  test('geocoding maps state and country', () {
    final location = OwmMapper.locationFromGeocoding(geocodeJson().first as Map<String, dynamic>);
    expect(location.name, 'London');
    expect(location.state, 'England');
    expect(location.subtitle, 'England, GB');
    expect(location.fullName, 'London, England, GB');
  });

  test('tolerates missing sections without throwing', () {
    final current = OwmMapper.currentFromWeatherEndpoint({'dt': 1749553200});
    expect(current.temperature, 0);
    expect(current.iconCode, '01d');
    expect(OwmMapper.hourlyFromForecastEndpoint({}), isEmpty);
    expect(OwmMapper.dailyFromForecastEndpoint({}, timezoneOffsetSeconds: 0), isEmpty);
  });
}
