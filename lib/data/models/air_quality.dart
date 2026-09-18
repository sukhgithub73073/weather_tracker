import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/weather_math.dart';

/// OpenWeatherMap Air Pollution API result. Concentrations are μg/m³.
class AirQuality {
  const AirQuality({
    required this.timestamp,
    required this.index,
    required this.pm2_5,
    required this.pm10,
    required this.ozone,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.carbonMonoxide,
  });

  final DateTime timestamp;

  /// 1 (good) … 5 (very poor)
  final int index;
  final double pm2_5;
  final double pm10;
  final double ozone;
  final double nitrogenDioxide;
  final double sulphurDioxide;
  final double carbonMonoxide;

  String get label => WeatherMath.aqiLabel(index);

  Color get color => switch (index) {
        1 => AppColors.success,
        2 => const Color(0xFF9CCC65),
        3 => AppColors.warning,
        4 => AppColors.severitySevere,
        5 => AppColors.severityExtreme,
        _ => AppColors.info,
      };

  factory AirQuality.fromJson(Map<String, dynamic> json) => AirQuality(
        timestamp: JsonUtils.fromUnix(json['timestamp']) ?? DateTime.now().toUtc(),
        index: JsonUtils.toInt(json['index']) ?? 0,
        pm2_5: JsonUtils.toDouble(json['pm2_5']) ?? 0,
        pm10: JsonUtils.toDouble(json['pm10']) ?? 0,
        ozone: JsonUtils.toDouble(json['o3']) ?? 0,
        nitrogenDioxide: JsonUtils.toDouble(json['no2']) ?? 0,
        sulphurDioxide: JsonUtils.toDouble(json['so2']) ?? 0,
        carbonMonoxide: JsonUtils.toDouble(json['co']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'timestamp': JsonUtils.toUnix(timestamp),
        'index': index,
        'pm2_5': pm2_5,
        'pm10': pm10,
        'o3': ozone,
        'no2': nitrogenDioxide,
        'so2': sulphurDioxide,
        'co': carbonMonoxide,
      };
}
