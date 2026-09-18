import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app_initializer.dart';
import 'app/weather_tracker_app.dart';
import 'core/widgets/boot_error_view.dart';

Future<void> main() async {
  // Anything thrown outside the widget tree (async init, platform channels)
  // is logged instead of leaving the engine on a black screen.
  runZonedGuarded(
    _run,
    (error, stackTrace) => debugPrint('Uncaught zone error: $error\n$stackTrace'),
  );
}

Future<void> _run() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('PlatformDispatcher error: $error\n$stackTrace');
    return true;
  };

  try {
    await AppInitializer.init();
    runApp(const WeatherTrackerApp());
  } catch (error, stackTrace) {
    debugPrint('App failed to initialize: $error\n$stackTrace');
    runApp(BootErrorView(error: error, stackTrace: stackTrace, onRetry: main));
  }
}
