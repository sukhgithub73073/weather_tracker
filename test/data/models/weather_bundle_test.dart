import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/data/models/weather_bundle.dart';
import 'package:weathertracker/data/providers/openweather/owm_mapper.dart';

import '../../fixtures/owm_fixtures.dart';

void main() {
  WeatherBundle buildBundle() {
    final currentJson = currentWeatherJson();
    final forecast = forecastJson();
    return WeatherBundle(
      location: OwmMapper.locationFromWeatherEndpoint(currentJson),
      current: OwmMapper.currentFromWeatherEndpoint(currentJson),
      hourly: OwmMapper.hourlyFromForecastEndpoint(forecast),
      daily: OwmMapper.dailyFromForecastEndpoint(forecast, timezoneOffsetSeconds: 3600),
      airQuality: OwmMapper.airQualityFromEndpoint(airPollutionJson()),
      timezoneOffsetSeconds: 3600,
      fetchedAt: DateTime.utc(2025, 6, 10, 11, 5),
      hasFullForecast: false,
    );
  }

  test('survives a JSON round trip (cache)', () {
    final original = buildBundle();
    final restored = WeatherBundle.fromJson(original.toJson());

    expect(restored.isFromCache, isTrue);
    expect(restored.location.name, original.location.name);
    expect(restored.location.coordinates, original.location.coordinates);
    expect(restored.current.temperature, original.current.temperature);
    expect(restored.current.iconCode, original.current.iconCode);
    expect(restored.current.dewPoint, closeTo(original.current.dewPoint!, 0.0001));
    expect(restored.hourly.length, original.hourly.length);
    expect(restored.hourly[2].precipitationProbability, 0.6);
    expect(restored.daily.length, original.daily.length);
    expect(restored.daily.first.date, original.daily.first.date);
    expect(restored.airQuality?.index, 2);
    expect(restored.timezoneOffsetSeconds, 3600);
    expect(restored.fetchedAt, original.fetchedAt);
    expect(restored.hasFullForecast, isFalse);
  });

  test('staleness respects the TTL', () {
    final bundle = buildBundle();
    final now = bundle.fetchedAt.add(const Duration(minutes: 10));
    expect(bundle.isStale(const Duration(minutes: 30), now: now), isFalse);
    expect(bundle.isStale(const Duration(minutes: 5), now: now), isTrue);
  });

  test('copyWith toggles the cache flag only', () {
    final bundle = buildBundle();
    final cached = bundle.copyWith(isFromCache: true);
    expect(cached.isFromCache, isTrue);
    expect(cached.current, same(bundle.current));
    expect(cached.fetchedAt, bundle.fetchedAt);
  });
}
