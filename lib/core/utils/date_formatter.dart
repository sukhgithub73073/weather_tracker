import 'package:intl/intl.dart';

/// Formats UTC timestamps in the *location's* local time (not the device's),
/// using the timezone offset that OpenWeatherMap returns with each response.
class DateFormatter {
  DateFormatter._();

  static DateTime toLocationTime(DateTime utc, int offsetSeconds) =>
      utc.toUtc().add(Duration(seconds: offsetSeconds));

  /// `7:45 AM` or `07:45`.
  static String time(DateTime utc, int offsetSeconds, {bool use24h = false}) {
    final local = toLocationTime(utc, offsetSeconds);
    return DateFormat(use24h ? 'HH:mm' : 'h:mm a').format(local);
  }

  /// `3 PM` or `15:00` – used in the hourly strip.
  static String hour(DateTime utc, int offsetSeconds, {bool use24h = false}) {
    final local = toLocationTime(utc, offsetSeconds);
    return DateFormat(use24h ? 'HH:mm' : 'h a').format(local);
  }

  /// `Today`, `Tomorrow` or `Wed`.
  static String dayName(
    DateTime utc,
    int offsetSeconds, {
    DateTime? nowUtc,
    bool full = false,
  }) {
    final local = toLocationTime(utc, offsetSeconds);
    final today = toLocationTime(nowUtc ?? DateTime.now().toUtc(), offsetSeconds);
    final dayDiff = _dateOnly(local).difference(_dateOnly(today)).inDays;
    if (dayDiff == 0) return 'Today';
    if (dayDiff == 1) return 'Tomorrow';
    return DateFormat(full ? 'EEEE' : 'EEE').format(local);
  }

  /// `Wednesday, 18 September`.
  static String fullDate(DateTime utc, int offsetSeconds) =>
      DateFormat('EEEE, d MMMM').format(toLocationTime(utc, offsetSeconds));

  /// `18 Sep`.
  static String shortDate(DateTime utc, int offsetSeconds) =>
      DateFormat('d MMM').format(toLocationTime(utc, offsetSeconds));

  /// `18 Sep, 3:00 PM`.
  static String dateTime(DateTime utc, int offsetSeconds, {bool use24h = false}) =>
      DateFormat(use24h ? 'd MMM, HH:mm' : 'd MMM, h:mm a')
          .format(toLocationTime(utc, offsetSeconds));

  /// `Just now`, `5 min ago`, `2 h ago`, `Yesterday`, `3 days ago`.
  static String relative(DateTime instant, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(instant);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  /// True when both instants fall on the same calendar day at the location.
  static bool isSameLocalDay(DateTime a, DateTime b, int offsetSeconds) =>
      _dateOnly(toLocationTime(a, offsetSeconds)) ==
      _dateOnly(toLocationTime(b, offsetSeconds));

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
