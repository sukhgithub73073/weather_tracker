import '../../core/utils/json_utils.dart';
import '../../core/utils/weather_condition.dart';

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.iconCode,
    required this.description,
    required this.conditionMain,
    required this.precipitationProbability,
    required this.humidity,
    required this.windSpeed,
    required this.windDegrees,
    this.tempDay,
    this.tempNight,
    this.feelsLikeDay,
    this.uvIndex,
    this.sunrise,
    this.sunset,
    this.rainVolume,
    this.snowVolume,
    this.cloudiness,
    this.pressure,
    this.summary,
  });

  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double? tempDay;
  final double? tempNight;
  final double? feelsLikeDay;
  final String iconCode;
  final String description;
  final String conditionMain;

  /// 0..1
  final double precipitationProbability;
  final int humidity;
  final double windSpeed;
  final int windDegrees;
  final double? uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? rainVolume;
  final double? snowVolume;
  final int? cloudiness;
  final double? pressure;
  final String? summary;

  WeatherCondition get condition => WeatherCondition.fromIcon(iconCode);

  int get precipitationPercent => (precipitationProbability * 100).round();

  String get capitalizedDescription => description.isEmpty
      ? ''
      : '${description[0].toUpperCase()}${description.substring(1)}';

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: JsonUtils.fromUnix(json['date']) ?? DateTime.now().toUtc(),
        tempMin: JsonUtils.toDouble(json['tempMin']) ?? 0,
        tempMax: JsonUtils.toDouble(json['tempMax']) ?? 0,
        tempDay: JsonUtils.toDouble(json['tempDay']),
        tempNight: JsonUtils.toDouble(json['tempNight']),
        feelsLikeDay: JsonUtils.toDouble(json['feelsLikeDay']),
        iconCode: JsonUtils.toStr(json['iconCode']) ?? '01d',
        description: JsonUtils.toStr(json['description']) ?? '',
        conditionMain: JsonUtils.toStr(json['conditionMain']) ?? '',
        precipitationProbability: JsonUtils.toDouble(json['pop']) ?? 0,
        humidity: JsonUtils.toInt(json['humidity']) ?? 0,
        windSpeed: JsonUtils.toDouble(json['windSpeed']) ?? 0,
        windDegrees: JsonUtils.toInt(json['windDegrees']) ?? 0,
        uvIndex: JsonUtils.toDouble(json['uvIndex']),
        sunrise: JsonUtils.fromUnix(json['sunrise']),
        sunset: JsonUtils.fromUnix(json['sunset']),
        rainVolume: JsonUtils.toDouble(json['rainVolume']),
        snowVolume: JsonUtils.toDouble(json['snowVolume']),
        cloudiness: JsonUtils.toInt(json['cloudiness']),
        pressure: JsonUtils.toDouble(json['pressure']),
        summary: JsonUtils.toStr(json['summary']),
      );

  Map<String, dynamic> toJson() => {
        'date': JsonUtils.toUnix(date),
        'tempMin': tempMin,
        'tempMax': tempMax,
        'tempDay': tempDay,
        'tempNight': tempNight,
        'feelsLikeDay': feelsLikeDay,
        'iconCode': iconCode,
        'description': description,
        'conditionMain': conditionMain,
        'pop': precipitationProbability,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDegrees': windDegrees,
        'uvIndex': uvIndex,
        'sunrise': JsonUtils.toUnix(sunrise),
        'sunset': JsonUtils.toUnix(sunset),
        'rainVolume': rainVolume,
        'snowVolume': snowVolume,
        'cloudiness': cloudiness,
        'pressure': pressure,
        'summary': summary,
      };
}
