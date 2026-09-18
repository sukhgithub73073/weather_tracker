import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        settings: Get.find(),
        locationRepository: Get.find(),
        weatherRepository: Get.find(),
        locationService: Get.find(),
      ),
    );
  }
}
