import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/core/utils/unit_converter.dart';

void main() {
  group('Temperature', () {
    test('converts celsius to fahrenheit', () {
      expect(UnitConverter.celsiusToFahrenheit(0), 32);
      expect(UnitConverter.celsiusToFahrenheit(100), 212);
      expect(UnitConverter.celsiusToFahrenheit(-40), -40);
    });

    test('formats with and without symbol', () {
      expect(UnitConverter.formatTemperature(21.4, TemperatureUnit.celsius), '21°');
      expect(
        UnitConverter.formatTemperature(21.4, TemperatureUnit.celsius, withSymbol: true),
        '21°C',
      );
      expect(
        UnitConverter.formatTemperature(20, TemperatureUnit.fahrenheit, withSymbol: true),
        '68°F',
      );
    });

    test('rounds half away from zero like the UI expects', () {
      expect(UnitConverter.formatTemperature(20.5, TemperatureUnit.celsius), '21°');
      expect(UnitConverter.formatTemperature(-0.4, TemperatureUnit.celsius), '0°');
    });
  });

  group('Wind', () {
    test('converts m/s to other units', () {
      expect(UnitConverter.convertWindSpeed(10, WindSpeedUnit.ms), 10);
      expect(UnitConverter.convertWindSpeed(10, WindSpeedUnit.kmh), closeTo(36, 0.001));
      expect(UnitConverter.convertWindSpeed(10, WindSpeedUnit.mph), closeTo(22.37, 0.01));
      expect(UnitConverter.convertWindSpeed(10, WindSpeedUnit.knots), closeTo(19.44, 0.01));
    });

    test('formats slow winds with one decimal and fast winds as integers', () {
      expect(UnitConverter.formatWindSpeed(1.5, WindSpeedUnit.ms), '1.5 m/s');
      expect(UnitConverter.formatWindSpeed(10, WindSpeedUnit.kmh), '36 km/h');
    });

    test('maps degrees to 16-point compass labels', () {
      expect(UnitConverter.windDirectionLabel(0), 'N');
      expect(UnitConverter.windDirectionLabel(11), 'N');
      expect(UnitConverter.windDirectionLabel(12), 'NNE');
      expect(UnitConverter.windDirectionLabel(45), 'NE');
      expect(UnitConverter.windDirectionLabel(90), 'E');
      expect(UnitConverter.windDirectionLabel(180), 'S');
      expect(UnitConverter.windDirectionLabel(270), 'W');
      expect(UnitConverter.windDirectionLabel(348.75), 'N');
      expect(UnitConverter.windDirectionLabel(359), 'N');
      expect(UnitConverter.windDirectionLabel(360), 'N');
      expect(UnitConverter.windDirectionLabel(-90), 'W');
    });
  });

  group('Pressure', () {
    test('converts hPa', () {
      expect(UnitConverter.convertPressure(1013.25, PressureUnit.hPa), 1013.25);
      expect(UnitConverter.convertPressure(1013.25, PressureUnit.mmHg), closeTo(760, 0.1));
      expect(UnitConverter.convertPressure(1013.25, PressureUnit.inHg), closeTo(29.92, 0.01));
    });

    test('formats inHg with two decimals, others as integers', () {
      expect(UnitConverter.formatPressure(1013.25, PressureUnit.hPa), '1013 hPa');
      expect(UnitConverter.formatPressure(1013.25, PressureUnit.inHg), '29.92 inHg');
    });
  });

  group('Visibility', () {
    test('formats metres as km or miles', () {
      expect(UnitConverter.formatVisibility(10000), '10 km');
      expect(UnitConverter.formatVisibility(2500), '2.5 km');
      expect(UnitConverter.formatVisibility(16093.44, imperial: true), '10 mi');
      expect(UnitConverter.formatVisibility(1609.344, imperial: true), '1.0 mi');
    });
  });
}
