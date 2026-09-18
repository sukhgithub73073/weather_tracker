/// Tolerant JSON readers – weather APIs mix ints and doubles freely and
/// omit fields depending on the endpoint.
class JsonUtils {
  JsonUtils._();

  static double? toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  static String? toStr(dynamic value) => value?.toString();

  /// Unix seconds → UTC DateTime.
  static DateTime? fromUnix(dynamic seconds) {
    final value = toInt(seconds);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }

  static int? toUnix(DateTime? date) =>
      date == null ? null : date.toUtc().millisecondsSinceEpoch ~/ 1000;

  static Map<String, dynamic>? toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<Map<String, dynamic>> toMapList(dynamic value) {
    if (value is! List) return const [];
    return value.map(toMap).whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
