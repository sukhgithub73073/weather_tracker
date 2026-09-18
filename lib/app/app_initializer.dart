import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../core/config/env.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/settings_service.dart';
import '../core/services/storage_service.dart';

/// Boots everything that must exist before the first frame.
class AppInitializer {
  AppInitializer._();

  static Future<void> init() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Animate.restartOnHotReload = true;

    await Env.load();
    await StorageService.initContainer();

    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<SettingsService>(SettingsService(Get.find()), permanent: true);
    await Get.putAsync<ConnectivityService>(
      () => ConnectivityService().init(),
      permanent: true,
    );
  }
}
