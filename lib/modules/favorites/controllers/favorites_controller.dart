import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../data/models/weather_location.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../home/controllers/home_controller.dart';

/// Saved locations with a live weather summary for each.
class FavoritesController extends GetxController {
  FavoritesController({
    required this.locationRepository,
    required this.weatherRepository,
    required this.settings,
    required this.connectivity,
  });

  final LocationRepository locationRepository;
  final WeatherRepository weatherRepository;
  final SettingsService settings;
  final ConnectivityService connectivity;

  RxList<WeatherLocation> get favorites => locationRepository.favorites;

  /// Weather per favourite id – filled from cache first, then the network.
  final RxMap<String, WeatherBundle> summaries = <String, WeatherBundle>{}.obs;
  final RxSet<String> loadingIds = <String>{}.obs;
  final RxBool isRefreshing = false.obs;

  HomeController? get _home =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  /// The city currently shown on the dashboard, if it is not a favourite yet.
  WeatherLocation? get savableCurrentCity {
    final location = _home?.weather.value?.location;
    if (location == null || location.name.isEmpty) return null;
    return locationRepository.isFavorite(location) ? null : location;
  }

  /// Weather for the device position, shown on the "Current location" card.
  WeatherBundle? get currentLocationWeather {
    final bundle = _home?.weather.value;
    return bundle != null && bundle.location.isCurrentLocation ? bundle : null;
  }

  bool get isShowingCurrentLocation => locationRepository.selectedLocation.value == null;

  WeatherLocation? get selectedLocation => locationRepository.selectedLocation.value;

  @override
  void onInit() {
    super.onInit();
    loadSummaries();
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> loadSummaries({bool force = false}) async {
    final targets = favorites.toList();
    for (final location in targets) {
      final cached = weatherRepository.getCached(location);
      if (cached != null) summaries[location.id] = cached;
    }
    if (!connectivity.isOnline.value) return;

    final toFetch = targets.where((location) {
      final existing = summaries[location.id];
      return force || existing == null || existing.isStale(AppConstants.weatherCacheTtl);
    }).toList();
    if (toFetch.isEmpty) return;

    isRefreshing.value = true;
    loadingIds.addAll(toFetch.map((l) => l.id));
    await Future.wait(toFetch.map(_fetchSummary));
    isRefreshing.value = false;
  }

  Future<void> _fetchSummary(WeatherLocation location) async {
    try {
      summaries[location.id] = await weatherRepository.fetchWeather(location);
    } catch (error) {
      AppLogger.e('Summary failed for ${location.name}', error: error, tag: 'Favorites');
    } finally {
      loadingIds.remove(location.id);
    }
  }

  Future<void> refresh() => loadSummaries(force: true);

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> select(WeatherLocation location) async {
    final home = _home;
    if (home != null) {
      Get.back();
      await home.selectLocation(location);
    } else {
      await locationRepository.select(location);
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> useCurrentLocation() async {
    final home = _home;
    if (home != null) {
      Get.back();
      await home.useCurrentLocation();
    } else {
      await locationRepository.select(null);
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> saveCurrentCity() async {
    final location = savableCurrentCity;
    if (location == null) return;
    if (!locationRepository.canAddFavorite) {
      AppSnackbar.error('You can save up to ${AppConstants.maxFavorites} locations.');
      return;
    }
    await locationRepository.addFavorite(location);
    final cached = weatherRepository.getCached(location);
    if (cached != null) summaries[location.id] = cached;
    AppSnackbar.success('${location.name} saved');
  }

  Future<void> remove(WeatherLocation location) async {
    final index = favorites.indexWhere((f) => f.id == location.id);
    if (index < 0) return;
    await locationRepository.removeFavorite(location);
    AppSnackbar.show(
      '${location.name} removed',
      actionLabel: 'Undo',
      onAction: () => locationRepository.insertFavorite(index, location),
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) =>
      locationRepository.reorderFavorites(oldIndex, newIndex);

  void openSearch() {
    final home = _home;
    if (home != null) {
      home.openRoute(Routes.search);
    } else {
      Get.toNamed(Routes.search);
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String temp(double celsius) =>
      UnitConverter.formatTemperature(celsius, settings.temperatureUnit.value);
}
