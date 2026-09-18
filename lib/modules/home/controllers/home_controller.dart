import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/weather_condition.dart';
import '../../../data/models/coordinates.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../data/models/weather_location.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/weather_repository.dart';
import 'home_error.dart';

enum HomeStatus { loading, loaded, error }

/// Drives the dashboard: resolves the location, loads weather cache-first,
/// refreshes from the network, and exposes unit-aware formatting.
class HomeController extends GetxController {
  HomeController({
    required this.weatherRepository,
    required this.locationRepository,
    required this.locationService,
    required this.settings,
    required this.connectivity,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final LocationService locationService;
  final SettingsService settings;
  final ConnectivityService connectivity;

  final Rx<HomeStatus> status = HomeStatus.loading.obs;
  final Rxn<WeatherBundle> weather = Rxn<WeatherBundle>();
  final Rxn<HomeError> error = Rxn<HomeError>();
  final RxBool isRefreshing = false.obs;
  final RxString loadingMessage = 'Finding your location…'.obs;

  /// Bumped every minute so "Updated 5 min ago" and the sun arc stay current.
  final RxInt clockTick = 0.obs;

  /// True while the dashboard shows [fallbackLocation] because the device
  /// position could not be obtained.
  final RxBool usingFallbackLocation = false.obs;

  /// Where to look when GPS is unavailable. Name is empty so the repository
  /// reverse-geocodes it into a real city name.
  static const WeatherLocation fallbackLocation = WeatherLocation(
    name: '',
    country: '',
    coordinates: Coordinates(
      latitude: AppConstants.fallbackLatitude,
      longitude: AppConstants.fallbackLongitude,
    ),
  );

  RxBool get isOnline => connectivity.isOnline;

  Timer? _clock;
  Worker? _connectivityWorker;
  bool _loadInFlight = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => clockTick.value++);
    _connectivityWorker = ever<bool>(connectivity.isOnline, _onConnectivityChanged);
  }

  @override
  void onReady() {
    super.onReady();
    loadInitial();
  }

  @override
  void onClose() {
    _clock?.cancel();
    _connectivityWorker?.dispose();
    super.onClose();
  }

  void _onConnectivityChanged(bool online) {
    if (!online) return;
    final current = weather.value;
    final needsRefresh = current == null ||
        current.isFromCache ||
        current.isStale(AppConstants.weatherCacheTtl);
    if (status.value == HomeStatus.error || needsRefresh) {
      AppLogger.d('Back online – refreshing', tag: 'Home');
      refresh(silent: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  WeatherLocation? get activeLocation =>
      weather.value?.location ?? locationRepository.selectedLocation.value;

  bool get isShowingCurrentLocation => locationRepository.selectedLocation.value == null;

  bool get isFavorite {
    final location = activeLocation;
    return location != null && locationRepository.isFavorite(location);
  }

  WeatherCondition get condition =>
      weather.value?.current.condition ?? WeatherCondition.unknown;

  int get timezoneOffset => weather.value?.timezoneOffsetSeconds ?? 0;

  /// Shown when the data on screen may not be current.
  bool get showCachedBanner {
    final current = weather.value;
    if (current == null) return false;
    return !isOnline.value ||
        (current.isFromCache && current.isStale(AppConstants.weatherCacheTtl));
  }

  String get lastUpdatedLabel {
    clockTick.value; // subscribe
    final fetchedAt = weather.value?.fetchedAt;
    return fetchedAt == null ? '' : DateFormatter.relative(fetchedAt);
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> loadInitial() async {
    final selected = locationRepository.selectedLocation.value;
    if (selected != null) {
      await _load(selected);
    } else {
      await useCurrentLocation();
    }
  }

  /// Switches the dashboard to the device position.
  Future<void> useCurrentLocation({bool requestPermission = true}) async {
    if (weather.value == null) {
      status.value = HomeStatus.loading;
      loadingMessage.value = 'Finding your location…';
    }

    final result = await locationService.getCurrentLocation(
      requestPermission: requestPermission,
    );

    switch (result) {
      case LocationSuccess(:final coordinates):
        await locationRepository.select(null);
        usingFallbackLocation.value = false;
        await _load(
          WeatherLocation(
            name: '',
            country: '',
            coordinates: coordinates,
            isCurrentLocation: true,
          ),
        );
      case LocationPermissionDenied(:final permanently):
        await _handleLocationProblem(
          permanently ? HomeError.permissionDeniedForever : HomeError.permissionDenied,
        );
      case LocationServiceDisabled():
        await _handleLocationProblem(HomeError.locationServiceDisabled);
      case LocationFailure(:final message):
        await _handleLocationProblem(HomeError.locationFailed(message));
    }
  }

  /// Shows weather for a searched / favourite city and remembers the choice.
  Future<void> selectLocation(WeatherLocation location) async {
    await locationRepository.select(location);
    usingFallbackLocation.value = false;
    await _load(location);
  }

  /// Pull-to-refresh and "try again".
  Future<void> refresh({bool silent = false}) async {
    if (error.value?.isLocationProblem == true && weather.value == null) {
      return useCurrentLocation();
    }
    if (usingFallbackLocation.value && !silent) {
      // Give GPS another chance before refreshing the fallback city.
      return useCurrentLocation(requestPermission: false);
    }
    final location = activeLocation;
    if (location == null) return useCurrentLocation();
    await _load(location, silent: silent);
  }

  Future<void> _load(WeatherLocation location, {bool silent = false}) async {
    if (_loadInFlight) return;
    _loadInFlight = true;
    try {
      final cached = weatherRepository.getCached(location);
      if (cached != null) {
        weather.value = cached.copyWith(isFromCache: true);
        status.value = HomeStatus.loaded;
        error.value = null;
      } else if (!silent) {
        status.value = HomeStatus.loading;
        loadingMessage.value = 'Fetching the forecast…';
      }

      if (!connectivity.isOnline.value) {
        if (cached == null) {
          _fail(HomeError.fromApi(const NoInternetException()));
        } else if (!silent) {
          AppSnackbar.offline("You're offline – showing the last saved forecast.");
        }
        return;
      }

      isRefreshing.value = cached != null;
      final fresh = await weatherRepository.fetchWeather(location);
      weather.value = fresh;
      error.value = null;
      status.value = HomeStatus.loaded;
    } on ApiException catch (exception) {
      AppLogger.e('Weather fetch failed', error: exception, tag: 'Home');
      if (weather.value != null) {
        if (!silent) {
          AppSnackbar.error(
            exception.userMessage,
            actionLabel: exception.isRetryable ? 'Retry' : null,
            onAction: exception.isRetryable ? refresh : null,
          );
        }
      } else {
        _fail(HomeError.fromApi(exception));
      }
    } catch (exception, stackTrace) {
      AppLogger.e('Unexpected error', error: exception, stackTrace: stackTrace, tag: 'Home');
      if (weather.value == null) _fail(HomeError.generic(exception));
    } finally {
      isRefreshing.value = false;
      _loadInFlight = false;
    }
  }

  /// Device position unavailable – show the fallback location instead so the
  /// dashboard is never empty, and tell the user how to fix it.
  Future<void> _handleLocationProblem(HomeError problem) async {
    AppLogger.d('Location problem (${problem.kind}) – using fallback', tag: 'Home');
    usingFallbackLocation.value = true;
    if (weather.value == null) loadingMessage.value = 'Loading default location…';

    AppSnackbar.show(
      problem.message,
      icon: problem.icon,
      duration: const Duration(seconds: 5),
      actionLabel: _locationFixLabel(problem),
      onAction: _locationFixAction(problem),
    );

    await _load(fallbackLocation);
  }

  String? _locationFixLabel(HomeError problem) {
    if (problem.needsAppSettings) return 'Settings';
    if (problem.needsLocationSettings) return 'Turn on';
    if (problem.needsPermissionRequest) return 'Allow';
    return null;
  }

  VoidCallback? _locationFixAction(HomeError problem) {
    if (problem.needsAppSettings) return locationService.openAppSettings;
    if (problem.needsLocationSettings) return locationService.openLocationSettings;
    if (problem.needsPermissionRequest) return useCurrentLocation;
    return null;
  }

  void _fail(HomeError problem) {
    error.value = problem;
    status.value = HomeStatus.error;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> toggleFavorite() async {
    final location = activeLocation;
    if (location == null) return;
    if (!locationRepository.isFavorite(location) && !locationRepository.canAddFavorite) {
      AppSnackbar.error('You can save up to ${AppConstants.maxFavorites} locations.');
      return;
    }
    final added = await locationRepository.toggleFavorite(location);
    weather.refresh(); // re-evaluate isFavorite in Obx widgets
    AppSnackbar.success(
      added ? '${location.name} added to favorites' : '${location.name} removed from favorites',
    );
  }

  Future<void> openAppSettings() => locationService.openAppSettings();

  Future<void> openLocationSettings() => locationService.openLocationSettings();

  /// Navigates to a module route, or explains that it is not available yet.
  void openRoute(String route, {dynamic arguments}) {
    if (AppPages.isRegistered(route)) {
      Get.toNamed(route, arguments: arguments);
    } else {
      AppSnackbar.show('This screen is coming in the next update.');
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting (reactive to unit settings)
  // ---------------------------------------------------------------------------

  String temp(double celsius) =>
      UnitConverter.formatTemperature(celsius, settings.temperatureUnit.value);

  String tempWithUnit(double celsius) => UnitConverter.formatTemperature(
        celsius,
        settings.temperatureUnit.value,
        withSymbol: true,
      );

  String wind(double metersPerSecond) =>
      UnitConverter.formatWindSpeed(metersPerSecond, settings.windSpeedUnit.value);

  String windDirection(int degrees) => UnitConverter.windDirectionLabel(degrees);

  String pressure(double hPa) => UnitConverter.formatPressure(hPa, settings.pressureUnit.value);

  String visibility(int? meters) => meters == null
      ? '—'
      : UnitConverter.formatVisibility(meters, imperial: settings.usesImperialDistance);

  String time(DateTime utc) =>
      DateFormatter.time(utc, timezoneOffset, use24h: settings.use24HourClock.value);

  String hour(DateTime utc) =>
      DateFormatter.hour(utc, timezoneOffset, use24h: settings.use24HourClock.value);

  String dayName(DateTime utc, {bool full = false}) =>
      DateFormatter.dayName(utc, timezoneOffset, full: full);

  String shortDate(DateTime utc) => DateFormatter.shortDate(utc, timezoneOffset);

  String fullDate(DateTime utc) => DateFormatter.fullDate(utc, timezoneOffset);

  String dateTime(DateTime utc) =>
      DateFormatter.dateTime(utc, timezoneOffset, use24h: settings.use24HourClock.value);

  /// Location-local "now", used for the sun arc and hour highlighting.
  DateTime get nowUtc {
    clockTick.value; // subscribe
    return DateTime.now().toUtc();
  }

  Brightness get brightness => Get.theme.brightness;
}
