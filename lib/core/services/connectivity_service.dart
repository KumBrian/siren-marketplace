import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to represent the network connection status
enum NetworkStatus { online, offline }

/// Service class to listen to connectivity changes
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkStatus(results);
    });
  }

  Stream<NetworkStatus> get statusStream => _controller.stream;

  void _checkStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      _controller.add(NetworkStatus.offline);
    } else {
      _controller.add(NetworkStatus.online);
    }
  }

  Future<NetworkStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      return NetworkStatus.offline;
    } else {
      return NetworkStatus.online;
    }
  }

  Future<bool> get hasConnection async {
    final status = await checkConnectivity();
    return status == NetworkStatus.online;
  }
}

/// Provider for the [ConnectivityService]
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider that emits the current [NetworkStatus]
/// Defaults to [NetworkStatus.online] to avoid startup jank if check takes time
final connectivityStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Convenience provider to get a boolean value of isOnline
/// Returns true if online (or loading initial state), false explicitly if offline
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).valueOrNull;
  // Assume online if we don't know yet (optimistic)
  return status != NetworkStatus.offline;
});
