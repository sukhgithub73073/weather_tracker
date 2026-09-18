import '../../core/utils/json_utils.dart';
import '../../core/utils/weather_condition.dart';

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.iconCode,
    required this.description,
    required this.precipitationProbability,
    required this.humidity,
    required this.windSpeed,
    required this.windDegrees,
    this.uvIndex,
    this.cloudiness,
  });

  final DateTime time;
  final double temperature;
  final double feelsLike;
  final String iconCode;
  final String description;

  /// 0..1
  final double precipitationProbability;
  final int humidity;
  final double windSpeed;
  final int windDegrees;
  final double? uvIndex;
  final int? cloudiness;

  WeatherCondition get condition => WeatherCondition.fromIcon(iconCode);

  int get precipitationPercent => (precipitationProbability * 100).round();

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: JsonUtils.fromUnix(json['time']) ?? DateTime.now().toUtc(),
        temperature: JsonUtils.toDouble(json['temperature']) ?? 0,
        feelsLike: JsonUtils.toDouble(json['feelsLike']) ?? 0,
        iconCode: JsonUtils.toStr(json['iconCode']) ?? '01d',
        description: JsonUtils.toStr(json['description']) ?? '',
        precipitationProbability: JsonUtils.toDouble(json['pop']) ?? 0,
        humidity: JsonUtils.toInt(json['humidity']) ?? 0,
        windSpeed: JsonUtils.toDouble(json['windSpeed']) ?? 0,
        windDegrees: JsonUtils.toInt(json['windDegrees']) ?? 0,
        uvIndex: JsonUtils.toDouble(json['uvIndex']),
        cloudiness: JsonUtils.toInt(json['cloudiness']),
      );

  Map<String, dynamic> toJson() => {
        'time': JsonUtils.toUnix(time),
        'temperature': temperature,
        'feelsLike': feelsLike,
        'iconCode': iconCode,
        'description': description,
        'pop': precipitationProbability,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDegrees': windDegrees,
        'uvIndex': uvIndex,
        'cloudiness': cloudiness,
      };
}
