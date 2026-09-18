import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';

enum HomeErrorKind {
  noInternet,
  permissionDenied,
  permissionDeniedForever,
  locationServiceDisabled,
  locationFailed,
  missingApiKey,
  invalidApiKey,
  notFound,
  rateLimited,
  server,
  generic,
}

/// What the dashboard shows when there is no weather to display at all.
/// Each kind maps to a title, message, icon and the action that fixes it.
class HomeError {
  const HomeError({
    required this.kind,
    required this.title,
    required this.message,
    required this.icon,
    this.canRetry = true,
  });

  final HomeErrorKind kind;
  final String title;
  final String message;
  final IconData icon;
  final bool canRetry;

  bool get needsAppSettings => kind == HomeErrorKind.permissionDeniedForever;
  bool get needsLocationSettings => kind == HomeErrorKind.locationServiceDisabled;
  bool get needsPermissionRequest => kind == HomeErrorKind.permissionDenied;
  bool get isLocationProblem =>
      needsAppSettings || needsLocationSettings || needsPermissionRequest ||
      kind == HomeErrorKind.locationFailed;

  factory HomeError.fromApi(ApiException exception) => switch (exception) {
        NoInternetException() => const HomeError(
            kind: HomeErrorKind.noInternet,
            title: "You're offline",
            message: 'Connect to the internet to load the latest forecast.',
            icon: Icons.wifi_off_rounded,
          ),
        NetworkTimeoutException() => const HomeError(
            kind: HomeErrorKind.generic,
            title: 'Taking too long',
            message: 'The weather service is slow to respond. Please try again.',
            icon: Icons.hourglass_bottom_rounded,
          ),
        MissingApiKeyException() => const HomeError(
            kind: HomeErrorKind.missingApiKey,
            title: 'API key missing',
            message:
                'Add OPENWEATHER_API_KEY to the .env file and restart the app.',
            icon: Icons.key_off_rounded,
            canRetry: false,
          ),
        InvalidApiKeyException() => const HomeError(
            kind: HomeErrorKind.invalidApiKey,
            title: 'API key rejected',
            message:
                'OpenWeatherMap rejected the key. New keys take up to two hours to activate.',
            icon: Icons.key_off_rounded,
          ),
        RateLimitException() => const HomeError(
            kind: HomeErrorKind.rateLimited,
            title: 'Too many requests',
            message: 'The API limit was reached. Please wait a minute and try again.',
            icon: Icons.speed_rounded,
          ),
        NotFoundException() => const HomeError(
            kind: HomeErrorKind.notFound,
            title: 'Location not found',
            message: "We couldn't find weather for this place. Try searching for another city.",
            icon: Icons.location_off_rounded,
          ),
        ServerException() => const HomeError(
            kind: HomeErrorKind.server,
            title: 'Service unavailable',
            message: 'The weather service is having trouble. Please try again shortly.',
            icon: Icons.cloud_off_rounded,
          ),
        EmptyResponseException() => const HomeError(
            kind: HomeErrorKind.generic,
            title: 'No data returned',
            message: 'The weather service returned an empty response. Please try again.',
            icon: Icons.inbox_rounded,
          ),
        RequestCancelledException() || UnknownApiException() => HomeError(
            kind: HomeErrorKind.generic,
            title: 'Something went wrong',
            message: exception.userMessage,
            icon: Icons.error_outline_rounded,
          ),
      };

  static const HomeError permissionDenied = HomeError(
    kind: HomeErrorKind.permissionDenied,
    title: 'Location access needed',
    message:
        'Allow location access to see the weather where you are, or search for a city instead.',
    icon: Icons.location_off_rounded,
  );

  static const HomeError permissionDeniedForever = HomeError(
    kind: HomeErrorKind.permissionDeniedForever,
    title: 'Location access blocked',
    message:
        'Location permission was denied permanently. Enable it in Settings, or search for a city.',
    icon: Icons.location_disabled_rounded,
  );

  static const HomeError locationServiceDisabled = HomeError(
    kind: HomeErrorKind.locationServiceDisabled,
    title: 'Location services are off',
    message: 'Turn on location services to use your current position.',
    icon: Icons.gps_off_rounded,
  );

  static HomeError locationFailed(String detail) => HomeError(
        kind: HomeErrorKind.locationFailed,
        title: "Couldn't get your location",
        message: detail.isEmpty ? 'Please try again.' : detail,
        icon: Icons.gps_not_fixed_rounded,
      );

  static HomeError generic(Object error) => HomeError(
        kind: HomeErrorKind.generic,
        title: 'Something went wrong',
        message: error.toString(),
        icon: Icons.error_outline_rounded,
      );
}
