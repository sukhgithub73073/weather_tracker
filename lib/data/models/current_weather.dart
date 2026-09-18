import '../../core/utils/json_utils.dart';
import '../../core/utils/weather_condition.dart';

/// Conditions right now. All values are metric (°C, m/s, hPa, metres);
/// the UI converts to the user's units.
class CurrentWeather {
  const CurrentWeather({
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDegrees,
    required this.cloudiness,
    required this.conditionId,
    required this.conditionMain,
    required this.description,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    this.visibility,
    this.windGust,
    this.uvIndex,
    this.dewPoint,
    this.precipitationProbability,
    this.rainLastHour,
    this.snowLastHour,
  });

  final DateTime timestamp;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double pressure;
  final int? visibility;
  final double windSpeed;
  final int windDegrees;
  final double? windGust;
  final int cloudiness;
  final double? uvIndex;
  final double? dewPoint;

  /// 0..1, null when the API tier does not provide it.
  final double? precipitationProbability;
  final double? rainLastHour;
  final double? snowLastHour;

  final int conditionId;
  final String conditionMain;
  final String description;
  final String iconCode;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherCondition get condition => WeatherCondition.fromIcon(iconCode);

  bool get isNight => iconCode.endsWith('n');

  /// `Light rain` – the API returns lower-case descriptions.
  String get capitalizedDescription => description.isEmpty
      ? ''
      : '${description[0].toUpperCase()}${description.substring(1)}';

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        timestamp: JsonUtils.fromUnix(json['timestamp']) ?? DateTime.now().toUtc(),
        temperature: JsonUtils.toDouble(json['temperature']) ?? 0,
        feelsLike: JsonUtils.toDouble(json['feelsLike']) ?? 0,
        tempMin: JsonUtils.toDouble(json['tempMin']) ?? 0,
        tempMax: JsonUtils.toDouble(json['tempMax']) ?? 0,
        humidity: JsonUtils.toInt(json['humidity']) ?? 0,
        pressure: JsonUtils.toDouble(json['pressure']) ?? 0,
        visibility: JsonUtils.toInt(json['visibility']),
        windSpeed: JsonUtils.toDouble(json['windSpeed']) ?? 0,
        windDegrees: JsonUtils.toInt(json['windDegrees']) ?? 0,
        windGust: JsonUtils.toDouble(json['windGust']),
        cloudiness: JsonUtils.toInt(json['cloudiness']) ?? 0,
        uvIndex: JsonUtils.toDouble(json['uvIndex']),
        dewPoint: JsonUtils.toDouble(json['dewPoint']),
        precipitationProbability: JsonUtils.toDouble(json['pop']),
        rainLastHour: JsonUtils.toDouble(json['rain1h']),
        snowLastHour: JsonUtils.toDouble(json['snow1h']),
        conditionId: JsonUtils.toInt(json['conditionId']) ?? 0,
        conditionMain: JsonUtils.toStr(json['conditionMain']) ?? '',
        description: JsonUtils.toStr(json['description']) ?? '',
        iconCode: JsonUtils.toStr(json['iconCode']) ?? '01d',
        sunrise: JsonUtils.fromUnix(json['sunrise']) ?? DateTime.now().toUtc(),
        sunset: JsonUtils.fromUnix(json['sunset']) ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'timestamp': JsonUtils.toUnix(timestamp),
        'temperature': temperature,
        'feelsLike': feelsLike,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'humidity': humidity,
        'pressure': pressure,
        'visibility': visibility,
        'windSpeed': windSpeed,
        'windDegrees': windDegrees,
        'windGust': windGust,
        'cloudiness': cloudiness,
        'uvIndex': uvIndex,
        'dewPoint': dewPoint,
        'pop': precipitationProbability,
        'rain1h': rainLastHour,
        'snow1h': snowLastHour,
        'conditionId': conditionId,
        'conditionMain': conditionMain,
        'description': description,
        'iconCode': iconCode,
        'sunrise': JsonUtils.toUnix(sunrise),
        'sunset': JsonUtils.toUnix(sunset),
      };

  CurrentWeather copyWith({
    double? tempMin,
    double? tempMax,
    double? uvIndex,
    double? dewPoint,
    double? precipitationProbability,
  }) =>
      CurrentWeather(
        timestamp: timestamp,
        temperature: temperature,
        feelsLike: feelsLike,
        tempMin: tempMin ?? this.tempMin,
        tempMax: tempMax ?? this.tempMax,
        humidity: humidity,
        pressure: pressure,
        visibility: visibility,
        windSpeed: windSpeed,
        windDegrees: windDegrees,
        windGust: windGust,
        cloudiness: cloudiness,
        uvIndex: uvIndex ?? this.uvIndex,
        dewPoint: dewPoint ?? this.dewPoint,
        precipitationProbability: precipitationProbability ?? this.precipitationProbability,
        rainLastHour: rainLastHour,
        snowLastHour: snowLastHour,
        conditionId: conditionId,
        conditionMain: conditionMain,
        description: description,
        iconCode: iconCode,
        sunrise: sunrise,
        sunset: sunset,
      );
}
