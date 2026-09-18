import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/coordinates.dart';

/// Raw access to the OpenWeatherMap endpoints. Returns decoded JSON only;
/// [OwmMapper] turns it into models and [OpenWeatherRepository] decides
/// which endpoints to combine.
class OpenWeatherProvider {
  OpenWeatherProvider(this._client);

  final ApiClient _client;

  Map<String, dynamic> _coords(Coordinates c) => {
        'lat': c.latitude,
        'lon': c.longitude,
      };

  Future<Map<String, dynamic>> fetchCurrentWeather(Coordinates coordinates) =>
      _client.getMap(
        ApiConstants.currentWeather,
        queryParameters: {..._coords(coordinates), 'units': ApiConstants.units},
      );

  Future<Map<String, dynamic>> fetchForecast5Day(Coordinates coordinates) =>
      _client.getMap(
        ApiConstants.forecast5Day,
        queryParameters: {..._coords(coordinates), 'units': ApiConstants.units},
      );

  Future<Map<String, dynamic>> fetchOneCall(Coordinates coordinates) =>
      _client.getMap(
        ApiConstants.oneCall,
        queryParameters: {
          ..._coords(coordinates),
          'units': ApiConstants.units,
          'exclude': 'minutely',
        },
      );

  Future<Map<String, dynamic>> fetchAirPollution(Coordinates coordinates) =>
      _client.getMap(ApiConstants.airPollution, queryParameters: _coords(coordinates));

  Future<List<dynamic>> geocode(
    String query, {
    int limit = 8,
    CancelToken? cancelToken,
  }) =>
      _client.getList(
        ApiConstants.geoDirect,
        queryParameters: {'q': query, 'limit': limit},
        cancelToken: cancelToken,
      );

  Future<List<dynamic>> reverseGeocode(Coordinates coordinates, {int limit = 1}) =>
      _client.getList(
        ApiConstants.geoReverse,
        queryParameters: {..._coords(coordinates), 'limit': limit},
      );
}
