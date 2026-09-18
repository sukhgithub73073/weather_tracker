import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/services/settings_service.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class WeatherTrackerApp extends StatelessWidget {
  const WeatherTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    // Obx here only reacts to themeMode – the ThemeData instances are cached.
    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode.value,
        initialBinding: InitialBinding(),
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
        unknownRoute: AppPages.unknown,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 320),
        builder: (context, child) {
          // Keep layouts predictable under very large accessibility font sizes.
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.3),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
