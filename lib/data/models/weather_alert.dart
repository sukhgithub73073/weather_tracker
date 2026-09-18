import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/json_utils.dart';

enum AlertSeverity {
  extreme('Extreme', AppColors.severityExtreme),
  severe('Severe', AppColors.severitySevere),
  moderate('Moderate', AppColors.severityModerate),
  minor('Minor', AppColors.severityMinor);

  const AlertSeverity(this.label, this.color);
  final String label;
  final Color color;
}

/// Government-issued warning (One Call 3.0 only).
class WeatherAlert {
  const WeatherAlert({
    required this.senderName,
    required this.event,
    required this.start,
    required this.end,
    required this.description,
    this.tags = const [],
  });

  final String senderName;
  final String event;
  final DateTime start;
  final DateTime end;
  final String description;
  final List<String> tags;

  /// OpenWeatherMap does not send an explicit severity – derive one from the
  /// event wording so the UI can colour-code alerts.
  AlertSeverity get severity {
    final text = '${event.toLowerCase()} ${tags.join(' ').toLowerCase()}';
    if (text.contains('extreme') || text.contains('emergency') || text.contains('tornado')) {
      return AlertSeverity.extreme;
    }
    if (text.contains('warning') || text.contains('severe') || text.contains('hurricane')) {
      return AlertSeverity.severe;
    }
    if (text.contains('watch') || text.contains('advisory')) {
      return AlertSeverity.moderate;
    }
    return AlertSeverity.minor;
  }

  bool isActiveAt(DateTime instant) => !instant.isBefore(start) && !instant.isAfter(end);

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
        senderName: JsonUtils.toStr(json['senderName']) ?? '',
        event: JsonUtils.toStr(json['event']) ?? 'Weather alert',
        start: JsonUtils.fromUnix(json['start']) ?? DateTime.now().toUtc(),
        end: JsonUtils.fromUnix(json['end']) ?? DateTime.now().toUtc(),
        description: JsonUtils.toStr(json['description']) ?? '',
        tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'event': event,
        'start': JsonUtils.toUnix(start),
        'end': JsonUtils.toUnix(end),
        'description': description,
        'tags': tags,
      };
}
