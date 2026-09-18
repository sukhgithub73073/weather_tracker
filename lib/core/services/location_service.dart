import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../data/models/coordinates.dart';
import '../utils/app_logger.dart';

/// Outcome of a location request – exhaustive so the UI can show the right
/// message and action for every case.
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.coordinates);
  final Coordinates coordinates;
}

class LocationPermissionDenied extends LocationResult {
  const LocationPermissionDenied({required this.permanently});

  /// True when the user chose "Don't ask again" / denied in system settings;
  /// only the settings app can fix it.
  final bool permanently;
}

class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}

class LocationFailure extends LocationResult {
  const LocationFailure(this.message);
  final String message;
}

/// Wraps geolocator so controllers never touch platform types.
class LocationService extends GetxService {
  static const Duration _timeout = Duration(seconds: 15);

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Resolves the device position, requesting permission when allowed.
  Future<LocationResult> getCurrentLocation({bool requestPermission = true}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationServiceDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          return const LocationPermissionDenied(permanently: false);
        case LocationPermission.deniedForever:
          return const LocationPermissionDenied(permanently: true);
        case LocationPermission.unableToDetermine:
          return const LocationFailure('Unable to determine location permission.');
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          break;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: _timeout,
          ),
        );
      } on TimeoutException {
        AppLogger.d('GPS timed out, using last known position', tag: 'Location');
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return const LocationFailure('Could not determine your position. Try again outdoors.');
      }
      return LocationSuccess(
        Coordinates(latitude: position.latitude, longitude: position.longitude),
      );
    } catch (error, stackTrace) {
      AppLogger.e('Location lookup failed', error: error, stackTrace: stackTrace, tag: 'Location');
      return LocationFailure(error.toString());
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
