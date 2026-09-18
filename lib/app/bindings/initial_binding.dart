import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/services/location_service.dart';
import '../../data/providers/openweather/openweather_provider.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/openweather_repository.dart';
import '../../data/repositories/weather_cache.dart';
import '../../data/repositories/weather_repository.dart';

/// App-wide dependencies that are not bound to a single screen.
///
/// Core services that need async setup (storage, env, connectivity) are
/// registered earlier in [AppInitializer]. Everything here is created lazily
/// on first use and re-created if GetX ever disposes it (`fenix`).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(ApiClient.new, fenix: true);
    Get.lazyPut<OpenWeatherProvider>(() => OpenWeatherProvider(Get.find()), fenix: true);
    Get.lazyPut<WeatherCache>(() => WeatherCache(Get.find()), fenix: true);
    Get.lazyPut<WeatherRepository>(
      () => OpenWeatherRepository(provider: Get.find(), cache: Get.find()),
      fenix: true,
    );
    Get.lazyPut<LocationRepository>(() => LocationRepository(Get.find()), fenix: true);
    Get.lazyPut<LocationService>(LocationService.new, fenix: true);
  }
}
