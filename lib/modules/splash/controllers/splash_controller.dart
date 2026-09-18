import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';

/// Runs start-up work while the splash animation plays, then moves to home.
///
/// The screen is always shown for at least [AppConstants.splashMinDuration]
/// so the entrance animation never gets cut off on fast devices, and never
/// blocks longer than the bootstrap actually takes on slow ones.
class SplashController extends GetxController {
  final RxString statusMessage = 'Preparing your forecast…'.obs;
  final RxString appVersion = ''.obs;

  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final minimumDisplay = Future<void>.delayed(AppConstants.splashMinDuration);

    try {
      await _loadVersion();
      statusMessage.value = Env.hasApiKey
          ? 'Fetching the skies…'
          : 'API key missing – check your .env file';
      // Later modules hook in here: warm the weather cache and resolve the
      // location permission so the dashboard opens with data ready.
    } catch (error, stackTrace) {
      AppLogger.e('Splash bootstrap failed', error: error, stackTrace: stackTrace);
    }

    await minimumDisplay;
    _goHome();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = 'v${info.version} (${info.buildNumber})';
  }

  void _goHome() {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(Routes.home);
  }
}
