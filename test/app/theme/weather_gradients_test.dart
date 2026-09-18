import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/app/theme/weather_gradients.dart';

void main() {
  group('WeatherGradients.conditionFromIcon', () {
    test('maps OpenWeatherMap icon codes to conditions', () {
      expect(WeatherGradients.conditionFromIcon('01d'), WeatherCondition.clearDay);
      expect(WeatherGradients.conditionFromIcon('01n'), WeatherCondition.clearNight);
      expect(WeatherGradients.conditionFromIcon('02d'), WeatherCondition.partlyCloudyDay);
      expect(WeatherGradients.conditionFromIcon('02n'), WeatherCondition.partlyCloudyNight);
      expect(WeatherGradients.conditionFromIcon('03d'), WeatherCondition.cloudy);
      expect(WeatherGradients.conditionFromIcon('04n'), WeatherCondition.cloudy);
      expect(WeatherGradients.conditionFromIcon('09d'), WeatherCondition.drizzle);
      expect(WeatherGradients.conditionFromIcon('10n'), WeatherCondition.rain);
      expect(WeatherGradients.conditionFromIcon('11d'), WeatherCondition.thunderstorm);
      expect(WeatherGradients.conditionFromIcon('13d'), WeatherCondition.snow);
      expect(WeatherGradients.conditionFromIcon('50n'), WeatherCondition.mist);
    });

    test('falls back to unknown for bad input', () {
      expect(WeatherGradients.conditionFromIcon(null), WeatherCondition.unknown);
      expect(WeatherGradients.conditionFromIcon(''), WeatherCondition.unknown);
      expect(WeatherGradients.conditionFromIcon('x'), WeatherCondition.unknown);
      expect(WeatherGradients.conditionFromIcon('99d'), WeatherCondition.unknown);
    });

    test('night detection', () {
      expect(WeatherCondition.clearNight.isNight, isTrue);
      expect(WeatherCondition.partlyCloudyNight.isNight, isTrue);
      expect(WeatherCondition.clearDay.isNight, isFalse);
      expect(WeatherCondition.rain.isNight, isFalse);
    });
  });

  group('WeatherGradients.forCondition', () {
    test('returns three colors for every condition', () {
      for (final condition in WeatherCondition.values) {
        final gradient = WeatherGradients.forCondition(condition);
        expect(gradient.colors.length, 3, reason: '$condition');
      }
    });

    test('dark brightness produces darker colors than light', () {
      final light = WeatherGradients.forCondition(WeatherCondition.clearDay);
      final dark = WeatherGradients.forCondition(
        WeatherCondition.clearDay,
        brightness: Brightness.dark,
      );
      for (var i = 0; i < light.colors.length; i++) {
        expect(
          dark.colors[i].computeLuminance(),
          lessThan(light.colors[i].computeLuminance()),
        );
      }
    });

    test('forIcon composes mapping and gradient', () {
      final fromIcon = WeatherGradients.forIcon('11d');
      final fromCondition = WeatherGradients.forCondition(WeatherCondition.thunderstorm);
      expect(fromIcon.colors, fromCondition.colors);
    });
  });
}
