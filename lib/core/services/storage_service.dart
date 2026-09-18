import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

/// Single access point for persisted key/value data.
///
/// Wraps GetStorage so the storage engine can be swapped (Hive, shared
/// preferences…) without touching feature code.
class StorageService extends GetxService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage(StorageKeys.container);

  final GetStorage _box;

  /// Must be awaited once before the service is used.
  static Future<void> initContainer() => GetStorage.init(StorageKeys.container);

  T? read<T>(String key) {
    final value = _box.read<dynamic>(key);
    return value is T ? value : null;
  }

  Map<String, dynamic>? readJson(String key) {
    final value = _box.read<dynamic>(key);
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> readJsonList(String key) {
    final value = _box.read<dynamic>(key);
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  List<String> readStringList(String key) {
    final value = _box.read<dynamic>(key);
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  bool hasKey(String key) => _box.hasData(key);

  /// Removes every key starting with [prefix] – used to purge weather caches.
  Future<void> removeWhere(bool Function(String key) test) async {
    final keys = _box.getKeys<Iterable<String>>().where(test).toList();
    for (final key in keys) {
      await _box.remove(key);
    }
  }

  Future<void> clearAll() => _box.erase();
}
