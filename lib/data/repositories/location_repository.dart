import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/services/storage_service.dart';
import '../models/weather_location.dart';

/// Locally stored locations: the one currently shown, favourites and recent
/// searches. Reactive so Home, Favorites and Search stay in sync.
class LocationRepository {
  LocationRepository(this._storage) {
    _load();
  }

  final StorageService _storage;

  /// Null means "follow the device's GPS position".
  final Rxn<WeatherLocation> selectedLocation = Rxn<WeatherLocation>();
  final RxList<WeatherLocation> favorites = <WeatherLocation>[].obs;
  final RxList<WeatherLocation> recentSearches = <WeatherLocation>[].obs;

  void _load() {
    final selected = _storage.readJson(StorageKeys.selectedLocation);
    selectedLocation.value = selected == null ? null : WeatherLocation.fromJson(selected);
    favorites.assignAll(
      _storage.readJsonList(StorageKeys.favorites).map(WeatherLocation.fromJson),
    );
    recentSearches.assignAll(
      _storage.readJsonList(StorageKeys.recentSearches).map(WeatherLocation.fromJson),
    );
  }

  // ---- Selected -----------------------------------------------------------

  Future<void> select(WeatherLocation? location) async {
    selectedLocation.value = location;
    if (location == null || location.isCurrentLocation) {
      await _storage.remove(StorageKeys.selectedLocation);
    } else {
      await _storage.write(StorageKeys.selectedLocation, location.toJson());
    }
  }

  // ---- Favourites ---------------------------------------------------------

  bool isFavorite(WeatherLocation location) => favorites.any((f) => f.id == location.id);

  bool get canAddFavorite => favorites.length < AppConstants.maxFavorites;

  Future<bool> addFavorite(WeatherLocation location) async {
    if (isFavorite(location) || !canAddFavorite) return false;
    favorites.add(location.copyWith(isCurrentLocation: false));
    await _persistFavorites();
    return true;
  }

  /// Re-inserts a favourite at its previous position (undo after remove).
  Future<void> insertFavorite(int index, WeatherLocation location) async {
    if (isFavorite(location) || !canAddFavorite) return;
    favorites.insert(index.clamp(0, favorites.length), location.copyWith(isCurrentLocation: false));
    await _persistFavorites();
  }

  Future<void> removeFavorite(WeatherLocation location) async {
    favorites.removeWhere((f) => f.id == location.id);
    await _persistFavorites();
  }

  Future<bool> toggleFavorite(WeatherLocation location) async {
    if (isFavorite(location)) {
      await removeFavorite(location);
      return false;
    }
    return addFavorite(location);
  }

  Future<void> reorderFavorites(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = favorites.removeAt(oldIndex);
    favorites.insert(newIndex, item);
    await _persistFavorites();
  }

  Future<void> clearFavorites() async {
    favorites.clear();
    await _persistFavorites();
  }

  Future<void> _persistFavorites() =>
      _storage.write(StorageKeys.favorites, favorites.map((f) => f.toJson()).toList());

  // ---- Recent searches ----------------------------------------------------

  Future<void> addRecentSearch(WeatherLocation location) async {
    recentSearches.removeWhere((r) => r.id == location.id);
    recentSearches.insert(0, location.copyWith(isCurrentLocation: false));
    if (recentSearches.length > AppConstants.maxRecentSearches) {
      recentSearches.removeRange(AppConstants.maxRecentSearches, recentSearches.length);
    }
    await _persistRecent();
  }

  Future<void> removeRecentSearch(WeatherLocation location) async {
    recentSearches.removeWhere((r) => r.id == location.id);
    await _persistRecent();
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    await _persistRecent();
  }

  Future<void> _persistRecent() => _storage.write(
        StorageKeys.recentSearches,
        recentSearches.map((r) => r.toJson()).toList(),
      );
}
