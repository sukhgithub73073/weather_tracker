import '../../core/utils/json_utils.dart';

class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        latitude: JsonUtils.toDouble(json['lat']) ?? 0,
        longitude: JsonUtils.toDouble(json['lon']) ?? 0,
      );

  Map<String, dynamic> toJson() => {'lat': latitude, 'lon': longitude};

  /// Stable key for caches – two decimals ≈ 1 km, enough to share a forecast.
  String get key => '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}
