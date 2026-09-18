import 'package:get/get.dart';

import '../controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        locationRepository: Get.find(),
        weatherRepository: Get.find(),
        settings: Get.find(),
        connectivity: Get.find(),
      ),
    );
  }
}
