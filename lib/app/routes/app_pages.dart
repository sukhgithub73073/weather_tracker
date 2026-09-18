import 'package:get/get.dart';

import '../../core/widgets/not_found_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/favorites/bindings/favorites_binding.dart';
import '../../modules/favorites/views/favorites_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/about_view.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

/// Route table. Each page gets its own binding so controllers are created
/// lazily when the route opens and disposed when it closes.
class AppPages {
  AppPages._();

  static const String initial = Routes.splash;

  /// True once a module has registered its page – lets earlier modules link
  /// to screens that are added later without crashing.
  static bool isRegistered(String route) => pages.any((page) => page.name == route);

  static final GetPage<dynamic> unknown = GetPage(
    name: Routes.notFound,
    page: () => const NotFoundView(),
  );

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutView(),
      // Shares SettingsController; the binding re-registers it if needed.
      binding: SettingsBinding(),
    ),
    // Search, forecast, details, map and alerts pages are registered here as
    // each module is implemented.
  ];
}
