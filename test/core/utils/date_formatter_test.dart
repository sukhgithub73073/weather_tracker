import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/core/utils/date_formatter.dart';

void main() {
  // 2025-06-10 11:00 UTC
  final instant = DateTime.utc(2025, 6, 10, 11);
  const tokyo = 9 * 3600;
  const newYork = -4 * 3600;

  test('formats times in the location timezone, not the device one', () {
    expect(DateFormatter.time(instant, tokyo), '8:00 PM');
    expect(DateFormatter.time(instant, tokyo, use24h: true), '20:00');
    expect(DateFormatter.time(instant, newYork), '7:00 AM');
    expect(DateFormatter.hour(instant, newYork), '7 AM');
  });

  test('day names are relative to the location-local date', () {
    final now = instant;
    expect(DateFormatter.dayName(instant, 0, nowUtc: now), 'Today');
    expect(
      DateFormatter.dayName(instant.add(const Duration(days: 1)), 0, nowUtc: now),
      'Tomorrow',
    );
    expect(
      DateFormatter.dayName(instant.add(const Duration(days: 2)), 0, nowUtc: now),
      'Thu',
    );
    expect(
      DateFormatter.dayName(instant.add(const Duration(days: 2)), 0, nowUtc: now, full: true),
      'Thursday',
    );
    // 11:00 UTC is already "tomorrow" in Auckland (+13) relative to 22:00 UTC yesterday.
    final lateYesterday = DateTime.utc(2025, 6, 9, 22);
    expect(DateFormatter.dayName(instant, 13 * 3600, nowUtc: lateYesterday), 'Tomorrow');
  });

  test('full and short dates', () {
    expect(DateFormatter.fullDate(instant, 0), 'Tuesday, 10 June');
    expect(DateFormatter.shortDate(instant, 0), '10 Jun');
    expect(DateFormatter.dateTime(instant, 0), '10 Jun, 11:00 AM');
  });

  test('relative labels', () {
    final now = DateTime(2025, 6, 10, 12);
    expect(DateFormatter.relative(now.subtract(const Duration(seconds: 20)), now: now), 'Just now');
    expect(DateFormatter.relative(now.subtract(const Duration(minutes: 5)), now: now), '5 min ago');
    expect(DateFormatter.relative(now.subtract(const Duration(hours: 3)), now: now), '3 h ago');
    expect(DateFormatter.relative(now.subtract(const Duration(days: 1)), now: now), 'Yesterday');
    expect(DateFormatter.relative(now.subtract(const Duration(days: 4)), now: now), '4 days ago');
  });

  test('same local day comparison honours the offset', () {
    final a = DateTime.utc(2025, 6, 10, 23, 30);
    final b = DateTime.utc(2025, 6, 11, 0, 30);
    expect(DateFormatter.isSameLocalDay(a, b, 0), isFalse);
    expect(DateFormatter.isSameLocalDay(a, b, -2 * 3600), isTrue);
  });
}
