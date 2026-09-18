import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../utils/unit_converter.dart';
import 'storage_service.dart';

/// User preferences – reactive and persisted.
///
/// Every setter updates the Rx value first (instant UI) and then writes to
/// storage.
class SettingsService extends GetxService {
  SettingsService(this._storage);

  final StorageService _storage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<TemperatureUnit> temperatureUnit = TemperatureUnit.celsius.obs;
  final Rx<WindSpeedUnit> windSpeedUnit = WindSpeedUnit.kmh.obs;
  final Rx<PressureUnit> pressureUnit = PressureUnit.hPa.obs;
  final RxBool use24HourClock = false.obs;

  // Notification preferences (consumed by NotificationService in a later module)
  final RxBool dailySummaryEnabled = false.obs;
  final RxBool severeAlertsEnabled = true.obs;
  final Rx<TimeOfDay> dailySummaryTime = const TimeOfDay(hour: 7, minute: 30).obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    themeMode.value = _enumFromName(
      ThemeMode.values,
      _storage.read<String>(StorageKeys.themeMode),
      ThemeMode.system,
    );
    temperatureUnit.value = _enumFromName(
      TemperatureUnit.values,
      _storage.read<String>(StorageKeys.temperatureUnit),
      TemperatureUnit.celsius,
    );
    windSpeedUnit.value = _enumFromName(
      WindSpeedUnit.values,
      _storage.read<String>(StorageKeys.windSpeedUnit),
      WindSpeedUnit.kmh,
    );
    pressureUnit.value = _enumFromName(
      PressureUnit.values,
      _storage.read<String>(StorageKeys.pressureUnit),
      PressureUnit.hPa,
    );
    use24HourClock.value = _storage.read<bool>(StorageKeys.use24HourClock) ?? false;
    dailySummaryEnabled.value =
        _storage.read<bool>(StorageKeys.dailySummaryEnabled) ?? false;
    severeAlertsEnabled.value =
        _storage.read<bool>(StorageKeys.severeAlertsEnabled) ?? true;
    dailySummaryTime.value =
        _parseTime(_storage.read<String>(StorageKeys.dailySummaryTime)) ??
            const TimeOfDay(hour: 7, minute: 30);
  }

  bool get isDarkMode => switch (themeMode.value) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => Get.isPlatformDarkMode,
      };

  /// True when the temperature unit implies imperial distances (miles).
  bool get usesImperialDistance =>
      temperatureUnit.value == TemperatureUnit.fahrenheit;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.write(StorageKeys.themeMode, mode.name);
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    temperatureUnit.value = unit;
    await _storage.write(StorageKeys.temperatureUnit, unit.name);
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    windSpeedUnit.value = unit;
    await _storage.write(StorageKeys.windSpeedUnit, unit.name);
  }

  Future<void> setPressureUnit(PressureUnit unit) async {
    pressureUnit.value = unit;
    await _storage.write(StorageKeys.pressureUnit, unit.name);
  }

  Future<void> setUse24HourClock(bool value) async {
    use24HourClock.value = value;
    await _storage.write(StorageKeys.use24HourClock, value);
  }

  Future<void> setDailySummaryEnabled(bool value) async {
    dailySummaryEnabled.value = value;
    await _storage.write(StorageKeys.dailySummaryEnabled, value);
  }

  Future<void> setSevereAlertsEnabled(bool value) async {
    severeAlertsEnabled.value = value;
    await _storage.write(StorageKeys.severeAlertsEnabled, value);
  }

  Future<void> setDailySummaryTime(TimeOfDay time) async {
    dailySummaryTime.value = time;
    await _storage.write(StorageKeys.dailySummaryTime, _formatTime(time));
  }

  Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.system);
    await setTemperatureUnit(TemperatureUnit.celsius);
    await setWindSpeedUnit(WindSpeedUnit.kmh);
    await setPressureUnit(PressureUnit.hPa);
    await setUse24HourClock(false);
    await setDailySummaryEnabled(false);
    await setSevereAlertsEnabled(true);
    await setDailySummaryTime(const TimeOfDay(hour: 7, minute: 30));
  }

  static T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
