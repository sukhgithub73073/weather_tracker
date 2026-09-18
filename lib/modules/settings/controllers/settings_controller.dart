import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../data/models/weather_location.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../home/controllers/home_controller.dart';

enum LocationAccessStatus { allowed, denied, servicesOff, unknown }

/// Settings screen logic. Preferences live in [SettingsService]; this
/// controller adds confirmations, permission status and data-clearing.
class SettingsController extends GetxController with WidgetsBindingObserver {
  SettingsController({
    required this.settings,
    required this.locationRepository,
    required this.weatherRepository,
    required this.locationService,
  });

  final SettingsService settings;
  final LocationRepository locationRepository;
  final WeatherRepository weatherRepository;
  final LocationService locationService;

  final RxString appVersion = ''.obs;
  final Rx<LocationAccessStatus> locationStatus = LocationAccessStatus.unknown.obs;

  RxList<WeatherLocation> get favorites => locationRepository.favorites;
  RxList<WeatherLocation> get recentSearches => locationRepository.recentSearches;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadVersion();
    refreshLocationStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from the system settings app – re-check permission.
    if (state == AppLifecycleState.resumed) refreshLocationStatus();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = '${info.version} (${info.buildNumber})';
    } catch (error) {
      AppLogger.e('Version lookup failed', error: error, tag: 'Settings');
      appVersion.value = '1.0.0';
    }
  }

  Future<void> refreshLocationStatus() async {
    try {
      if (!await locationService.isServiceEnabled()) {
        locationStatus.value = LocationAccessStatus.servicesOff;
      } else if (await locationService.hasPermission()) {
        locationStatus.value = LocationAccessStatus.allowed;
      } else {
        locationStatus.value = LocationAccessStatus.denied;
      }
    } catch (_) {
      locationStatus.value = LocationAccessStatus.unknown;
    }
  }

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  Future<void> setThemeMode(ThemeMode mode) => settings.setThemeMode(mode);
  Future<void> setTemperatureUnit(TemperatureUnit unit) => settings.setTemperatureUnit(unit);
  Future<void> setWindSpeedUnit(WindSpeedUnit unit) => settings.setWindSpeedUnit(unit);
  Future<void> setPressureUnit(PressureUnit unit) => settings.setPressureUnit(unit);
  Future<void> setUse24HourClock(bool value) => settings.setUse24HourClock(value);
  Future<void> setSevereAlertsEnabled(bool value) => settings.setSevereAlertsEnabled(value);

  Future<void> setDailySummaryEnabled(bool value) async {
    await settings.setDailySummaryEnabled(value);
    if (value) {
      AppSnackbar.show(
        'Daily summary at ${formatTime(settings.dailySummaryTime.value)}',
        icon: Icons.notifications_active_outlined,
      );
    }
  }

  Future<void> pickDailySummaryTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.dailySummaryTime.value,
      helpText: 'Morning summary time',
    );
    if (picked != null) await settings.setDailySummaryTime(picked);
  }

  String formatTime(TimeOfDay time) {
    if (settings.use24HourClock.value) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<void> openLocationFix() async {
    switch (locationStatus.value) {
      case LocationAccessStatus.servicesOff:
        await locationService.openLocationSettings();
      case LocationAccessStatus.denied:
      case LocationAccessStatus.allowed:
      case LocationAccessStatus.unknown:
        await locationService.openAppSettings();
    }
  }

  Future<void> useCurrentLocation() async {
    if (Get.isRegistered<HomeController>()) {
      Get.until((route) => route.settings.name == Routes.home);
      await Get.find<HomeController>().useCurrentLocation();
    } else {
      await locationRepository.select(null);
      Get.offAllNamed(Routes.home);
    }
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  Future<void> clearSearchHistory() async {
    if (locationRepository.recentSearches.isEmpty) {
      AppSnackbar.show('Search history is already empty.');
      return;
    }
    final confirmed = await AppDialogs.confirm(
      title: 'Clear search history?',
      message: 'Your recent city searches will be removed from this device.',
      confirmLabel: 'Clear',
      destructive: true,
      icon: Icons.history_rounded,
    );
    if (!confirmed) return;
    await locationRepository.clearRecentSearches();
    AppSnackbar.success('Search history cleared');
  }

  Future<void> clearFavorites() async {
    if (locationRepository.favorites.isEmpty) {
      AppSnackbar.show('You have no saved locations.');
      return;
    }
    final confirmed = await AppDialogs.confirm(
      title: 'Remove all saved locations?',
      message: 'All ${locationRepository.favorites.length} favourite cities will be removed. This cannot be undone.',
      confirmLabel: 'Remove all',
      destructive: true,
      icon: Icons.favorite_border_rounded,
    );
    if (!confirmed) return;
    await locationRepository.clearFavorites();
    AppSnackbar.success('Saved locations removed');
  }

  Future<void> clearCachedWeather() async {
    final confirmed = await AppDialogs.confirm(
      title: 'Clear cached weather?',
      message: 'Offline data will be removed and downloaded again on the next refresh.',
      confirmLabel: 'Clear',
      icon: Icons.cloud_off_rounded,
    );
    if (!confirmed) return;
    await weatherRepository.clearCache();
    AppSnackbar.success('Cached weather cleared');
  }

  Future<void> resetSettings() async {
    final confirmed = await AppDialogs.confirm(
      title: 'Reset settings?',
      message: 'Theme, units and notification preferences return to their defaults.',
      confirmLabel: 'Reset',
      icon: Icons.restart_alt_rounded,
    );
    if (!confirmed) return;
    await settings.resetToDefaults();
    AppSnackbar.success('Settings reset');
  }

  // ---------------------------------------------------------------------------
  // About
  // ---------------------------------------------------------------------------

  void openAbout() => Get.toNamed(Routes.about);

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) AppSnackbar.error('Could not open link.');
    } catch (error) {
      AppLogger.e('launchUrl failed', error: error, tag: 'Settings');
      AppSnackbar.error('Could not open link.');
    }
  }
}
