import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/weather_condition.dart';

/// Vector weather icon built from Material icons so every list and card in
/// the app shares one visual language (no dated PNGs from the API).
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 32,
    this.monochrome,
  });

  WeatherIcon.fromCode(String iconCode, {Key? key, double size = 32, Color? monochrome})
      : this(
          key: key,
          condition: WeatherCondition.fromIcon(iconCode),
          size: size,
          monochrome: monochrome,
        );

  final WeatherCondition condition;
  final double size;

  /// When set, every part of the icon uses this color (e.g. white on gradients).
  final Color? monochrome;

  static const Color _cloudColor = Color(0xFF9DB4CC);
  static const Color _cloudDark = Color(0xFF7B8FA6);
  static const Color _moonColor = Color(0xFFC9D2E3);

  Color _c(Color color) => monochrome ?? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (condition) {
        WeatherCondition.clearDay => Icon(Icons.wb_sunny_rounded, size: size, color: _c(AppColors.sun)),
        WeatherCondition.clearNight =>
          Icon(Icons.nightlight_round, size: size * 0.9, color: _c(_moonColor)),
        WeatherCondition.partlyCloudyDay => _composite(
            back: Icon(Icons.wb_sunny_rounded, size: size * 0.62, color: _c(AppColors.sun)),
            front: Icon(Icons.cloud_rounded, size: size * 0.72, color: _c(_cloudColor)),
          ),
        WeatherCondition.partlyCloudyNight => _composite(
            back: Icon(Icons.nightlight_round, size: size * 0.55, color: _c(_moonColor)),
            front: Icon(Icons.cloud_rounded, size: size * 0.72, color: _c(_cloudColor)),
          ),
        WeatherCondition.cloudy => Icon(Icons.cloud_rounded, size: size, color: _c(_cloudColor)),
        WeatherCondition.drizzle => _stacked(
            top: Icon(Icons.cloud_rounded, size: size * 0.8, color: _c(_cloudColor)),
            bottom: Icon(Icons.grain_rounded, size: size * 0.5, color: _c(AppColors.rain)),
          ),
        WeatherCondition.rain => _stacked(
            top: Icon(Icons.cloud_rounded, size: size * 0.8, color: _c(_cloudDark)),
            bottom: Icon(Icons.water_drop_rounded, size: size * 0.42, color: _c(AppColors.rain)),
          ),
        WeatherCondition.thunderstorm => _stacked(
            top: Icon(Icons.cloud_rounded, size: size * 0.8, color: _c(_cloudDark)),
            bottom: Icon(Icons.flash_on_rounded, size: size * 0.5, color: _c(AppColors.sunLight)),
          ),
        WeatherCondition.snow => _stacked(
            top: Icon(Icons.cloud_rounded, size: size * 0.8, color: _c(_cloudColor)),
            bottom: Icon(Icons.ac_unit_rounded, size: size * 0.46, color: _c(Colors.white)),
          ),
        WeatherCondition.mist => Icon(Icons.blur_on_rounded, size: size, color: _c(_cloudColor)),
        WeatherCondition.unknown =>
          Icon(Icons.cloud_outlined, size: size, color: _c(_cloudColor)),
      },
    );
  }

  /// Sun/moon peeking out behind a cloud.
  Widget _composite({required Widget back, required Widget front}) => Stack(
        children: [
          Positioned(top: 0, left: 0, child: back),
          Positioned(bottom: 0, right: 0, child: front),
        ],
      );

  /// Cloud with precipitation underneath.
  Widget _stacked({required Widget top, required Widget bottom}) => Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: Center(child: top)),
          Positioned(bottom: 0, left: 0, right: 0, child: Center(child: bottom)),
        ],
      );
}
