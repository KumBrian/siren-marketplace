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
    // Initialize with current status
    checkConnectivity().then((status) {
      if (!_controller.isClosed) {
        _controller.add(status);
      }
    });
  }

  Stream<NetworkStatus> get statusStream => _controller.stream;

  NetworkStatus _currentStatus = NetworkStatus.online;
  NetworkStatus get currentStatus => _currentStatus;

  void _checkStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _currentStatus = NetworkStatus.offline;
      _controller.add(NetworkStatus.offline);
    } else {
      _currentStatus = NetworkStatus.online;
      _controller.add(NetworkStatus.online);
    }
  }

  Future<NetworkStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _currentStatus = NetworkStatus.offline;
      return NetworkStatus.offline;
    } else {
      _currentStatus = NetworkStatus.online;
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
final connectivityStatusProvider = StreamProvider<NetworkStatus>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield service.currentStatus;
  yield* service.statusStream;
});

/// Convenience provider to get a boolean value of isOnline
/// Returns true if online (or loading initial state), false explicitly if offline
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).valueOrNull;
  // Assume online if we don't know yet (optimistic)
  return status != NetworkStatus.offline;
});
