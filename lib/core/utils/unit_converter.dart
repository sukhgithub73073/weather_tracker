/// Units the user can pick in Settings.
///
/// The API is always queried in metric; conversions happen here so switching
/// units is instant and offline-safe.
enum TemperatureUnit {
  celsius('°C', 'Celsius'),
  fahrenheit('°F', 'Fahrenheit');

  const TemperatureUnit(this.symbol, this.label);
  final String symbol;
  final String label;
}

enum WindSpeedUnit {
  kmh('km/h', 'Kilometres per hour'),
  mph('mph', 'Miles per hour'),
  ms('m/s', 'Metres per second'),
  knots('kn', 'Knots');

  const WindSpeedUnit(this.symbol, this.label);
  final String symbol;
  final String label;
}

enum PressureUnit {
  hPa('hPa', 'Hectopascals'),
  mmHg('mmHg', 'Millimetres of mercury'),
  inHg('inHg', 'Inches of mercury');

  const PressureUnit(this.symbol, this.label);
  final String symbol;
  final String label;
}

class UnitConverter {
  UnitConverter._();

  static const List<String> _compassPoints = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];

  // ---- Temperature -------------------------------------------------------

  static double celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

  static double convertTemperature(double celsius, TemperatureUnit unit) =>
      switch (unit) {
        TemperatureUnit.celsius => celsius,
        TemperatureUnit.fahrenheit => celsiusToFahrenheit(celsius),
      };

  /// `21°` or `21°C` depending on [withSymbol].
  static String formatTemperature(
    double celsius,
    TemperatureUnit unit, {
    bool withSymbol = false,
  }) {
    final value = convertTemperature(celsius, unit).round();
    return withSymbol ? '$value${unit.symbol}' : '$value°';
  }

  // ---- Wind ---------------------------------------------------------------

  static double msToKmh(double ms) => ms * 3.6;
  static double msToMph(double ms) => ms * 2.2369362921;
  static double msToKnots(double ms) => ms * 1.9438444924;

  static double convertWindSpeed(double metersPerSecond, WindSpeedUnit unit) =>
      switch (unit) {
        WindSpeedUnit.ms => metersPerSecond,
        WindSpeedUnit.kmh => msToKmh(metersPerSecond),
        WindSpeedUnit.mph => msToMph(metersPerSecond),
        WindSpeedUnit.knots => msToKnots(metersPerSecond),
      };

  static String formatWindSpeed(double metersPerSecond, WindSpeedUnit unit) {
    final value = convertWindSpeed(metersPerSecond, unit);
    final text = value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }

  /// 16-point compass label for a meteorological wind direction (degrees the
  /// wind blows *from*).
  static String windDirectionLabel(num degrees) {
    final normalized = ((degrees % 360) + 360) % 360;
    final index = ((normalized / 22.5) + 0.5).floor() % 16;
    return _compassPoints[index];
  }

  // ---- Pressure -----------------------------------------------------------

  static double hPaToMmHg(double hPa) => hPa * 0.750061683;
  static double hPaToInHg(double hPa) => hPa * 0.02952998;

  static double convertPressure(double hPa, PressureUnit unit) => switch (unit) {
        PressureUnit.hPa => hPa,
        PressureUnit.mmHg => hPaToMmHg(hPa),
        PressureUnit.inHg => hPaToInHg(hPa),
      };

  static String formatPressure(double hPa, PressureUnit unit) {
    final value = convertPressure(hPa, unit);
    final text = unit == PressureUnit.inHg
        ? value.toStringAsFixed(2)
        : value.round().toString();
    return '$text ${unit.symbol}';
  }

  // ---- Distance -----------------------------------------------------------

  /// Visibility comes from the API in metres.
  static String formatVisibility(num meters, {bool imperial = false}) {
    if (imperial) {
      final miles = meters / 1609.344;
      return miles >= 10 ? '${miles.round()} mi' : '${miles.toStringAsFixed(1)} mi';
    }
    final km = meters / 1000;
    return km >= 10 ? '${km.round()} km' : '${km.toStringAsFixed(1)} km';
  }
}
