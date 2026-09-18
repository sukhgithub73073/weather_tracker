import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logger. Silent in release builds.
class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'App'}) {
    if (kDebugMode) developer.log(message, name: tag);
  }

  static void e(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(message, name: tag, error: error, stackTrace: stackTrace);
    }
  }
}
