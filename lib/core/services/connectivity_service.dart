import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../utils/app_logger.dart';

/// Tracks whether the device has a network route.
///
/// Note: a connected Wi-Fi network without internet still reports online –
/// the network layer's [NoInternetException] covers that case.
class ConnectivityService extends GetxService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    await refresh();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _update,
      onError: (Object error) => AppLogger.e('Connectivity stream error', error: error),
    );
    return this;
  }

  /// Re-checks the connection and returns the current state.
  Future<bool> refresh() async {
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (error) {
      AppLogger.e('Connectivity check failed', error: error);
      isOnline.value = true; // Fail open – the API call will surface a real error.
    }
    return isOnline.value;
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.any((result) => result != ConnectivityResult.none);
    if (online != isOnline.value) {
      AppLogger.d('Connectivity changed → ${online ? 'online' : 'offline'}', tag: 'Connectivity');
      isOnline.value = online;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
