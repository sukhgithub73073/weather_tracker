import '../../core/utils/json_utils.dart';
import 'coordinates.dart';

/// A place the app can show weather for – the GPS position, a searched city
/// or a favourite.
class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.country,
    required this.coordinates,
    this.state,
    this.isCurrentLocation = false,
  });

  final String name;
  final String? state;
  final String country;
  final Coordinates coordinates;
  final bool isCurrentLocation;

  /// Identity used for favourites and caches.
  String get id => coordinates.key;

  /// `California, US` / `US`.
  String get subtitle =>
      [state, country].where((s) => s != null && s.isNotEmpty).join(', ');

  /// `San Francisco, California, US`.
  String get fullName =>
      [name, state, country].where((s) => s != null && s.isNotEmpty).join(', ');

  factory WeatherLocation.fromJson(Map<String, dynamic> json) => WeatherLocation(
        name: JsonUtils.toStr(json['name']) ?? '',
        state: JsonUtils.toStr(json['state']),
        country: JsonUtils.toStr(json['country']) ?? '',
        coordinates: Coordinates(
          latitude: JsonUtils.toDouble(json['lat']) ?? 0,
          longitude: JsonUtils.toDouble(json['lon']) ?? 0,
        ),
        isCurrentLocation: JsonUtils.toBool(json['isCurrentLocation']) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'state': state,
        'country': country,
        'lat': coordinates.latitude,
        'lon': coordinates.longitude,
        'isCurrentLocation': isCurrentLocation,
      };

  WeatherLocation copyWith({
    String? name,
    String? state,
    String? country,
    Coordinates? coordinates,
    bool? isCurrentLocation,
  }) =>
      WeatherLocation(
        name: name ?? this.name,
        state: state ?? this.state,
        country: country ?? this.country,
        coordinates: coordinates ?? this.coordinates,
        isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      );

  @override
  bool operator ==(Object other) => other is WeatherLocation && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WeatherLocation($fullName, $coordinates)';
}
